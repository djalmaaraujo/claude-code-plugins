#!/bin/bash
#
# Slack Status Checker
# Validates Slack configuration and credentials
#
# Returns: STATUS|MESSAGE|DETAILS
#   OK|Ready to use|Workspace: ..., User: ...
#   MISSING_CONFIG|Config file not found|...
#   MISSING_CREDENTIALS|Missing required fields|...
#   INVALID_AUTH|Authentication failed|...
#   EXPIRED_TOKEN|Token expired|...
#

set -e

# Determine plugin root dynamically (this script is in skills/slack-status/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$PLUGIN_ROOT/lib/config.sh"
source "$PLUGIN_ROOT/lib/slack-api.sh"

# Step 1: Check if config exists
if ! config_exists; then
  echo "MISSING_CONFIG|Config file not found|Create config at: $(get_config_path)"
  exit 1
fi

# Step 2: Try to load config
if ! load_config 2>/dev/null; then
  echo "MISSING_CREDENTIALS|Missing required fields|Check workspace, token, and cookie in config"
  exit 1
fi

# Step 3: Test authentication with Slack API
AUTH_RESPONSE=$(slack_auth_test 2>/dev/null)

if ! slack_check_response "$AUTH_RESPONSE"; then
  ERROR=$(slack_get_error "$AUTH_RESPONSE")

  case "$ERROR" in
    "invalid_auth"|"token_revoked")
      echo "INVALID_AUTH|Authentication failed|Error: $ERROR - Please refresh your credentials"
      exit 1
      ;;
    "token_expired")
      echo "EXPIRED_TOKEN|Token expired|Please refresh your credentials"
      exit 1
      ;;
    *)
      echo "API_ERROR|Slack API error|Error: $ERROR"
      exit 1
      ;;
  esac
fi

# Step 4: Extract user info from auth response
USER_NAME=$(echo "$AUTH_RESPONSE" | jq -r '.user // "unknown"')
USER_ID=$(echo "$AUTH_RESPONSE" | jq -r '.user_id // "unknown"')
TEAM_NAME=$(echo "$AUTH_RESPONSE" | jq -r '.team // "unknown"')
CACHE_SIZE=$(get_cache_size)

# Success
echo "OK|Ready to use|Workspace: $SLACK_WORKSPACE, Team: $TEAM_NAME, User: $USER_NAME ($USER_ID), Cached users: $CACHE_SIZE"
exit 0
