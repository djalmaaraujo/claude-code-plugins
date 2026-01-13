---
allowed-tools: Bash, AskUserQuestion
---

# Slack Setup Command

Interactive setup wizard to configure Slack credentials.

## Instructions

Follow these steps to set up the Slack plugin:

### Step 1: Initialize Config File

Create the config file from template if it doesn't exist:

```bash
PLUGIN_ROOT="$HOME/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack"
if [ ! -f "$PLUGIN_ROOT/config.json" ]; then
  cp "$PLUGIN_ROOT/example.config.json" "$PLUGIN_ROOT/config.json"
  chmod 600 "$PLUGIN_ROOT/config.json"
  echo "✓ Created config.json from template"
fi
```

### Step 2: Check Current Status

```bash
PLUGIN_ROOT="$HOME/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack"
"$PLUGIN_ROOT/skills/slack-status/check.sh"
```

### Step 3: Guide User

Explain to the user:

"I'll guide you through getting your Slack credentials from your browser. This is safe - we're using your existing Slack session credentials.

**Steps to get credentials:**

1. Open Slack in Chrome and go to your workspace
2. Open DevTools (Mac: Cmd+Option+J, Windows: Ctrl+Shift+J)
3. Go to the "Network" tab
4. Send any message in Slack
5. Find a request called "chat.postMessage" or "api"
6. Click it and look for:
   - **token** (Payload/Form Data): Copy value starting with `xoxc-`
   - **cookie** (Headers → Cookie → d=): Copy value starting with `xoxd-`
   - **workspace**: Your workspace domain (e.g., `a8c.slack.com`)"

### Step 4: Collect Credentials

Use AskUserQuestion tool to collect three pieces of information:

1. **Workspace**: "What is your Slack workspace URL? (e.g., a8c.slack.com)"
2. **Token**: "Please paste your Slack token (starts with xoxc-)"
3. **Cookie**: "Please paste your Slack cookie (starts with xoxd-)"

### Step 5: Save and Validate

```bash
PLUGIN_ROOT="$HOME/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack"
source "$PLUGIN_ROOT/lib/config.sh"

WORKSPACE="<from user>"
TOKEN="<from user>"
COOKIE="<from user>"

save_config "$WORKSPACE" "$TOKEN" "$COOKIE"

# Verify
STATUS=$("$PLUGIN_ROOT/skills/slack-status/check.sh")
if echo "$STATUS" | grep -q "^OK"; then
  echo "✅ Slack setup complete!"
  echo "$STATUS"
else
  echo "❌ Setup failed. Please try again."
  echo "$STATUS"
fi
```

### Step 6: Confirm Success

Tell the user:

"✅ Slack plugin is now configured!

You can now use:
- /slack:slack-search-user - Find Slack users
- /slack:slack-send-message - Send messages and DMs

Your credentials are stored securely at:
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/config.json"
