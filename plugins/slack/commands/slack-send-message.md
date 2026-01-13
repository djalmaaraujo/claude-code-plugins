---
allowed-tools: Bash
---

# Send Slack Message Command

User provided: $ARGUMENTS

Parse the arguments to extract the target (channel or user) and message content.

## Instructions

1. **Extract target and message** from $ARGUMENTS:
   - Look for `#channel-name` or `@username` patterns
   - Everything else is the message content

2. **Check Slack configuration** by running:
   ```bash
   $HOME/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-status/check.sh
   ```
   - If status is not OK, tell user to run `/slack:slack-setup`

3. **Determine message type**:
   - If target starts with `#`: Send to channel (Step 4)
   - If target starts with `@`: Send DM to user (Step 5)

4. **For channel messages**, create and run a bash script:
   ```bash
   #!/bin/bash
   PLUGIN_ROOT="$HOME/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack"
   source "$PLUGIN_ROOT/lib/config.sh"
   source "$PLUGIN_ROOT/lib/slack-api.sh"

   load_config

   CHANNEL_NAME="channel-name"  # Remove # prefix
   MESSAGE="message content"

   SEND_RESPONSE=$(slack_chat_post_message "$CHANNEL_NAME" "$MESSAGE")

   if slack_check_response "$SEND_RESPONSE"; then
     echo "✓ Message sent to #$CHANNEL_NAME"
   else
     echo "✗ Error: $(slack_get_error "$SEND_RESPONSE")"
     exit 1
   fi
   ```

5. **For user DMs**, create and run a bash script:
   ```bash
   #!/bin/bash
   PLUGIN_ROOT="$HOME/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack"
   source "$PLUGIN_ROOT/lib/config.sh"
   source "$PLUGIN_ROOT/lib/slack-api.sh"

   load_config

   USERNAME="username"  # Remove @ prefix
   MESSAGE="message content"

   # Find user
   USER_ID=$("$PLUGIN_ROOT/skills/slack-search-user/search-user.sh" "$USERNAME")
   if [ $? -ne 0 ] || [ -z "$USER_ID" ]; then
     echo "✗ User not found: $USERNAME"
     exit 1
   fi

   # Open DM
   DM_RESPONSE=$(slack_conversations_open "$USER_ID")
   CHANNEL_ID=$(echo "$DM_RESPONSE" | jq -r '.channel.id')

   if [ "$CHANNEL_ID" = "null" ] || [ -z "$CHANNEL_ID" ]; then
     echo "✗ Failed to open DM"
     exit 1
   fi

   # Send message
   SEND_RESPONSE=$(slack_chat_post_message "$CHANNEL_ID" "$MESSAGE")

   if slack_check_response "$SEND_RESPONSE"; then
     echo "✓ Message sent to @$USERNAME"
   else
     echo "✗ Error: $(slack_get_error "$SEND_RESPONSE")"
     exit 1
   fi
   ```
