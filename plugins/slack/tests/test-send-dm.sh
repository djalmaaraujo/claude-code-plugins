#!/bin/bash
#
# Test sending DM to a Slack user
#

set -e

PLUGIN_ROOT="$HOME/.claude/plugins/slack"
source "$PLUGIN_ROOT/lib/config.sh"
source "$PLUGIN_ROOT/lib/slack-api.sh"

# Test parameters
USERNAME="${1:-djalma}"
MESSAGE="${2:-✅ Plugin test: Sending DM at $(date)}"

echo "Testing slack-send-message (DM mode)"
echo "====================================="
echo "User: @$USERNAME"
echo "Message: $MESSAGE"
echo ""

# Step 0: Check status
echo "Step 0: Checking Slack status..."
STATUS_OUTPUT=$("$PLUGIN_ROOT/skills/slack-status/check.sh")
STATUS_CODE=$(echo "$STATUS_OUTPUT" | cut -d'|' -f1)

if [ "$STATUS_CODE" != "OK" ]; then
  echo "✗ Slack is not properly configured"
  echo "$STATUS_OUTPUT"
  exit 1
fi

echo "✓ Status check passed"
echo ""

# Step 1: Load config
echo "Step 1: Loading configuration..."
load_config
echo "✓ Config loaded: $SLACK_WORKSPACE"
echo ""

# Step 2: Find user
echo "Step 2: Finding user @$USERNAME..."
USER_ID=$("$PLUGIN_ROOT/skills/slack-search-user/search-user.sh" "$USERNAME" 2>&1 | tail -1)

if [ $? -ne 0 ]; then
  echo "✗ User not found: $USERNAME"
  exit 1
fi

echo "✓ Found user ID: $USER_ID"
echo ""

# Step 3: Open DM channel
echo "Step 3: Opening DM channel..."
DM_RESPONSE=$(slack_conversations_open "$USER_ID")

CHANNEL_ID=$(echo "$DM_RESPONSE" | jq -r '.channel.id')

if [ "$CHANNEL_ID" = "null" ] || [ -z "$CHANNEL_ID" ]; then
  echo "✗ Failed to open DM channel"
  echo "Response: $DM_RESPONSE"
  exit 1
fi

echo "✓ DM channel opened: $CHANNEL_ID"
echo ""

# Step 4: Send message
echo "Step 4: Sending message..."
SEND_RESPONSE=$(slack_chat_post_message "$CHANNEL_ID" "$MESSAGE")

if slack_check_response "$SEND_RESPONSE"; then
  TIMESTAMP=$(echo "$SEND_RESPONSE" | jq -r '.ts')
  echo "✓ Message sent successfully!"
  echo "  Timestamp: $TIMESTAMP"
  echo ""
  echo "✅ TEST PASSED: DM sent to @$USERNAME"
else
  ERROR=$(slack_get_error "$SEND_RESPONSE")
  echo "✗ Error sending message: $ERROR"
  echo "Response: $SEND_RESPONSE"
  echo ""
  echo "❌ TEST FAILED"
  exit 1
fi
