---
name: slack-send-message
description: Send Slack messages and DMs as yourself directly from Claude Code using your browser session credentials. Extracts the target channel or user and message content directly from natural language prompts. Supports @username for DMs and #channel-name for channels.
user-invocable: true
---

# Slack Send Message Skill

Send Slack messages and DMs as yourself using your authenticated browser session credentials. The target (channel or user) is inferred directly from your prompt — no pre-configuration required.

**Features:**
- ✅ Send messages to channels using `#channel-name`
- ✅ Send DMs to users using `@username`
- ✅ Automatic status verification before sending
- ✅ Integrates with `slack-search-user` for user lookups
- ✅ Supports matching by username, real name, or display name (case-insensitive)

## Usage

When the user asks to send a Slack message, follow these steps:

### Step 0: Verify Slack is configured

ALWAYS check status first:

```bash
STATUS_OUTPUT=$(~/.claude/plugins/slack/skills/slack-status/check.sh)
STATUS_CODE=$(echo "$STATUS_OUTPUT" | cut -d'|' -f1)

if [ "$STATUS_CODE" != "OK" ]; then
  echo "⚠️ Slack is not properly configured"
  echo "Please run: /slack:slack-setup"
  exit 1
fi
```

### Step 1: Extract target and message from prompt

Parse the user's prompt to identify:

- **Target**: Look for channel references like `#channel-name` or user references like `@username`
- **Message**: The content the user wants to send

Examples of target extraction:

- "Send 'hello' to #general" → target: `#general`, message: `hello`
- "Post in slack-ai-testing: build complete" → target: `#slack-ai-testing`, message: `build complete`
- "Message @fulano saying good morning" → target: `@fulano`, message: `good morning`
- "DM @john: are you ready?" → target: `@john`, message: `are you ready?`

### Step 2: Determine if target is a channel or user

Check if the target starts with `@` (user DM) or `#` (channel):

- **If target starts with `@`**: This is a DM, proceed to Step 2a
- **If target starts with `#` or is a plain channel name**: This is a channel, proceed to Step 2b

### Step 2a: For DMs - Find user and send message

When the target is a user (starts with `@`), you need to:

1. **Use the slack-search-user skill** to find the user ID
2. **Open a DM channel** using `conversations.open` API
3. **Send the message** to that channel

Here's the complete flow:

```bash
#!/bin/bash

PLUGIN_ROOT="$HOME/.claude/plugins/slack"
source "$PLUGIN_ROOT/lib/config.sh"
source "$PLUGIN_ROOT/lib/slack-api.sh"

USERNAME="fulano"  # extracted from @fulano
MESSAGE="Your message here"

# Load config
load_config

# Step 1: Use slack-search-user to find the user
echo "Searching for user '$USERNAME'..."
USER_ID=$("$PLUGIN_ROOT/skills/slack-search-user/search-user.sh" "$USERNAME" 2>&1 | tail -1)

if [ $? -ne 0 ]; then
  echo "✗ User not found: $USERNAME"
  exit 1
fi

echo "✓ Found user ID: $USER_ID"

# Step 2: Open DM channel
echo "Opening DM channel..."
DM_RESPONSE=$(slack_conversations_open "$USER_ID")

CHANNEL_ID=$(echo "$DM_RESPONSE" | jq -r '.channel.id')

if [ "$CHANNEL_ID" = "null" ] || [ -z "$CHANNEL_ID" ]; then
  echo "✗ Failed to open DM channel"
  exit 1
fi

# Step 3: Send message
echo "Sending message..."
SEND_RESPONSE=$(slack_chat_post_message "$CHANNEL_ID" "$MESSAGE")

if slack_check_response "$SEND_RESPONSE"; then
  echo "✓ Message sent successfully!"
else
  ERROR=$(slack_get_error "$SEND_RESPONSE")
  echo "✗ Error sending message: $ERROR"
  exit 1
fi
```

**Key points:**
- Uses `slack-search-user` script - no inline user search code
- Uses shared API functions from `lib/slack-api.sh`
- Clean and maintainable
- Easy to debug

### Step 2b: For channels - Send directly

When the target is a channel (starts with `#` or is a plain channel name):

```bash
#!/bin/bash

PLUGIN_ROOT="$HOME/.claude/plugins/slack"
source "$PLUGIN_ROOT/lib/config.sh"
source "$PLUGIN_ROOT/lib/slack-api.sh"

# Remove # prefix if present
CHANNEL_NAME="slack-ai-testing"  # extracted from #slack-ai-testing
MESSAGE="Your message here"

# Load config
load_config

# Send message directly (Slack resolves channel names automatically)
echo "Sending message to #$CHANNEL_NAME..."
SEND_RESPONSE=$(slack_chat_post_message "$CHANNEL_NAME" "$MESSAGE")

if slack_check_response "$SEND_RESPONSE"; then
  echo "✓ Message sent successfully to #$CHANNEL_NAME!"
else
  ERROR=$(slack_get_error "$SEND_RESPONSE")
  echo "✗ Error sending message: $ERROR"
  exit 1
fi
```

**Important**: Pass the channel name directly (e.g., `general`, `slack-ai-testing`). The Slack API accepts both channel names and channel IDs.

### Step 3: Verify the response

The response will be JSON. Check for `"ok": true` to confirm the message was sent successfully.

A successful response looks like:

```json
{
  "ok": true,
  "channel": "C0A7V415BKQ",
  "ts": "1234567890.123456",
  "message": { ... }
}
```

An error response looks like:

```json
{
  "ok": false,
  "error": "channel_not_found"
}
```

## Examples

### Example 1: Channel message

**User prompt:** "Send a message to #slack-ai-testing saying hello from Claude Code"

1. Check Slack status
2. Extract target: `#slack-ai-testing`, message: `hello from Claude Code`
3. Detect it's a channel (starts with `#`)
4. Send message using `slack_chat_post_message`

### Example 2: DM to a user

**User prompt:** "Send a DM to @djalma saying: can you review my PR?"

1. Check Slack status
2. Extract target: `@djalma`, message: `can you review my PR?`
3. Detect it's a user DM (starts with `@`)
4. Search for user "djalma" using `slack-search-user`
5. Get the user ID (e.g., `U01ULLNEM3Q`)
6. Open DM channel using `conversations.open`
7. Get the channel ID (e.g., `D98765XYZ`)
8. Send the message to that channel

## Configuration

This skill uses the centralized Slack plugin configuration at:
```
~/.claude/plugins/slack/config.json
```

## Integration

This skill integrates with:
- **slack-status** - Validates configuration before sending
- **slack-search-user** - Finds users for DMs
- **lib/config.sh** - Loads shared configuration
- **lib/slack-api.sh** - Uses shared API functions

## Important Notes

- **Automatic validation**: Checks Slack status before every message
- **Channels vs DMs**:
  - **Channels** (starting with `#` or plain names): No channel ID lookup needed
  - **DMs** (starting with `@`): Uses `slack-search-user` to find user, then opens DM channel
- **User search integration**: Delegates all user lookups to `slack-search-user` skill
- **Messages appear as you**: These messages are sent as your authenticated user, not as a bot
- **Requirements**:
  - `jq` is required
  - Python 3.6+ is required
  - Slack plugin must be configured (run `/slack:slack-setup` if needed)

## Troubleshooting

| Error                        | Solution                                                                                                          |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `Slack is not properly configured` | Run `/slack:slack-setup` to configure credentials |
| `invalid_auth`               | Token or cookie expired. Re-run `/slack:slack-setup` |
| `channel_not_found`          | Check the channel name spelling or verify you have access |
| `not_in_channel`             | You need to join the channel first |
| `User 'X' not found`         | The username doesn't exist or doesn't match any name fields |
| DM channel ID is null/empty  | The `conversations.open` response failed. Check user ID validity |
