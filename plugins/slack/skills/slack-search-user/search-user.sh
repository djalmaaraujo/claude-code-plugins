#!/bin/bash
#
# Slack User Search Script
# Searches for a Slack user by username, real name, or display name
# Uses cache-first strategy with API fallback
#
# Usage: ./search-user.sh <username>
# Returns: User ID on stdout, details on stderr

set -e

PLUGIN_ROOT="$HOME/.claude/plugins/slack"
source "$PLUGIN_ROOT/lib/config.sh"
source "$PLUGIN_ROOT/lib/slack-api.sh"

if [ -z "$1" ]; then
  echo "Usage: $0 <username>" >&2
  exit 1
fi

USERNAME="$1"

# Step 0: Check Slack status
STATUS_OUTPUT=$("$PLUGIN_ROOT/skills/slack-status/check.sh" 2>&1)
STATUS_CODE=$(echo "$STATUS_OUTPUT" | cut -d'|' -f1)

if [ "$STATUS_CODE" != "OK" ]; then
  echo "⚠️  Slack is not properly configured" >&2
  echo "$STATUS_OUTPUT" >&2
  echo "" >&2
  echo "Please run: slack-setup" >&2
  exit 1
fi

# Load config
load_config

CONFIG_PATH="$(get_config_path)"

# Step 1: Check cache using jq (efficient - doesn't load entire JSON into memory)
echo "🔍 Searching for user '$USERNAME' in cache..." >&2
USER_DATA=$(jq -r --arg username "$USERNAME" '
  .users[] |
  select(
    (.name | ascii_downcase) == ($username | ascii_downcase) or
    (.real_name | ascii_downcase) == ($username | ascii_downcase) or
    (.display_name | ascii_downcase) == ($username | ascii_downcase)
  ) |
  @json
' "$CONFIG_PATH" | head -1)

if [ -n "$USER_DATA" ]; then
  USER_ID=$(echo "$USER_DATA" | jq -r '.id')
  USER_NAME=$(echo "$USER_DATA" | jq -r '.name')
  DISPLAY_NAME=$(echo "$USER_DATA" | jq -r '.display_name // .name')
  REAL_NAME=$(echo "$USER_DATA" | jq -r '.real_name')

  echo "✓ Found user in cache:" >&2
  echo "  - User ID: $USER_ID" >&2
  echo "  - Username: $USER_NAME" >&2
  echo "  - Display name: $DISPLAY_NAME" >&2
  echo "  - Real name: $REAL_NAME" >&2

  # Output user ID to stdout for easy integration
  echo "$USER_ID"
  exit 0
fi

echo "✗ User not in cache, searching via Slack API..." >&2

# Step 2: Search via API and cache ALL users
# Pass variables via environment to Python
export CONFIG_PATH SLACK_WORKSPACE SLACK_TOKEN SLACK_COOKIE USERNAME

USER_RESULT=$(python3 << 'PYEOF'
import json
import urllib.request
import urllib.parse
import sys
import os

config_path = os.environ['CONFIG_PATH']
workspace = os.environ['SLACK_WORKSPACE']
token = os.environ['SLACK_TOKEN']
cookie = os.environ['SLACK_COOKIE']
username = os.environ['USERNAME']

try:
    # Read current cache
    with open(config_path, 'r') as f:
        config = json.load(f)

    users_cache = config.get('users', [])
    cached_user_ids = {u['id'] for u in users_cache}

    cursor = ""
    user_id = None
    user_data = None

    while not user_id:
        url = f"https://{workspace}/api/users.list?limit=1000"
        if cursor:
            url += f"&cursor={urllib.parse.quote(cursor)}"

        req = urllib.request.Request(url)
        req.add_header('Authorization', f'Bearer {token}')
        req.add_header('Cookie', f'd={cookie}')

        try:
            with urllib.request.urlopen(req) as response:
                data = json.loads(response.read())
        except Exception as e:
            print(f"ERROR|Error calling Slack API: {e}")
            sys.exit(1)

        if not data.get('ok'):
            print(f"ERROR|Slack API error: {data.get('error', 'unknown')}")
            sys.exit(1)

        members = data.get('members', [])
        new_users_cached = 0

        # Cache ALL users from this response
        for member in members:
            member_id = member.get('id')

            # Skip bots and deleted users
            if member.get('is_bot') or member.get('deleted'):
                continue

            # Skip if already in cache
            if member_id in cached_user_ids:
                continue

            # Add to cache
            user_entry = {
                'id': member_id,
                'name': member.get('name', ''),
                'real_name': member.get('real_name', ''),
                'display_name': member.get('profile', {}).get('display_name', '')
            }
            users_cache.append(user_entry)
            cached_user_ids.add(member_id)
            new_users_cached += 1

            # Check if this is the user we're looking for
            name = member.get('name', '').lower()
            real_name = member.get('real_name', '').lower()
            display_name = member.get('profile', {}).get('display_name', '').lower()

            if (name == username.lower() or
                real_name == username.lower() or
                display_name == username.lower()):
                user_id = member_id
                user_data = user_entry

        # Save updated cache
        if new_users_cached > 0:
            config['users'] = users_cache
            with open(config_path, 'w') as f:
                json.dump(config, f, indent=2)
            print(f"CACHED|{new_users_cached}")

        # Check for more pages
        next_cursor = data.get('response_metadata', {}).get('next_cursor', '')
        if not user_id and not next_cursor:
            break
        if not user_id:
            cursor = next_cursor

    if user_id and user_data:
        print(f"FOUND|{user_id}|{user_data['name']}|{user_data.get('display_name', '')}|{user_data.get('real_name', '')}")
    else:
        print(f"ERROR|User '{username}' not found in Slack workspace")
        sys.exit(1)

except Exception as e:
    print(f"ERROR|Unexpected error: {e}")
    sys.exit(1)
PYEOF
)

EXIT_CODE=$?

# Parse Python output
if [ $EXIT_CODE -ne 0 ]; then
  ERROR_MSG=$(echo "$USER_RESULT" | grep "^ERROR|" | cut -d'|' -f2-)
  echo "✗ $ERROR_MSG" >&2
  exit 1
fi

# Check for cache update message
if echo "$USER_RESULT" | grep -q "^CACHED|"; then
  CACHED_COUNT=$(echo "$USER_RESULT" | grep "^CACHED|" | cut -d'|' -f2)
  echo "✓ Cached $CACHED_COUNT new users from API response" >&2
fi

# Extract user info
if echo "$USER_RESULT" | grep -q "^FOUND|"; then
  USER_INFO=$(echo "$USER_RESULT" | grep "^FOUND|")
  USER_ID=$(echo "$USER_INFO" | cut -d'|' -f2)
  USER_NAME=$(echo "$USER_INFO" | cut -d'|' -f3)
  DISPLAY_NAME=$(echo "$USER_INFO" | cut -d'|' -f4)
  REAL_NAME=$(echo "$USER_INFO" | cut -d'|' -f5)

  echo "✓ Found user via API:" >&2
  echo "  - User ID: $USER_ID" >&2
  echo "  - Username: $USER_NAME" >&2
  echo "  - Display name: $DISPLAY_NAME" >&2
  echo "  - Real name: $REAL_NAME" >&2

  # Output user ID to stdout
  echo "$USER_ID"
  exit 0
fi

echo "✗ Failed to parse API response" >&2
exit 1
