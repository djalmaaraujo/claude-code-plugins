#!/bin/bash
#
# Test sending message to a Slack channel
#

set -e

PLUGIN_ROOT="$HOME/.claude/plugins/slack"
source "$PLUGIN_ROOT/lib/config.sh"
source "$PLUGIN_ROOT/lib/slack-api.sh"

# Test parameters
CHANNEL="${1:-slack-ai-testing}"
MESSAGE="${2:-✅ Plugin test: Sending to channel at $(date)}"

echo "Testing slack-send-message (channel mode)"
echo "==========================================="
echo "Channel: #$CHANNEL"
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

# Step 2: Send message
echo "Step 2: Sending message to #$CHANNEL..."
SEND_RESPONSE=$(slack_chat_post_message "$CHANNEL" "$MESSAGE")

if slack_check_response "$SEND_RESPONSE"; then
  TIMESTAMP=$(echo "$SEND_RESPONSE" | jq -r '.ts')
  echo "✓ Message sent successfully!"
  echo "  Timestamp: $TIMESTAMP"
  echo ""
  echo "✅ TEST PASSED: Channel message sent"
else
  ERROR=$(slack_get_error "$SEND_RESPONSE")
  echo "✗ Error sending message: $ERROR"
  echo "Response: $SEND_RESPONSE"
  echo ""
  echo "❌ TEST FAILED"
  exit 1
fi
