---
allowed-tools: Bash
---

# Slack Search User Command

User provided: $ARGUMENTS

Search for a Slack user by username, real name, or display name.

## Instructions

Parse $ARGUMENTS to extract the username to search for.

### For User Search

Run the search-user script:

```bash
PLUGIN_ROOT="$HOME/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack"

USERNAME="<extracted from arguments>"

USER_ID=$("$PLUGIN_ROOT/skills/slack-search-user/search-user.sh" "$USERNAME")

if [ $? -eq 0 ] && [ -n "$USER_ID" ]; then
  echo "✓ Found user: $USERNAME"
  echo "User ID: $USER_ID"
else
  echo "✗ User not found: $USERNAME"
fi
```

### For Cache Management

If the user asks about cache (e.g., "how many users", "list users", "clear cache"):

```bash
PLUGIN_ROOT="$HOME/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack"

# Count users
"$PLUGIN_ROOT/skills/slack-search-user/cache-utils.sh" count

# List all users
"$PLUGIN_ROOT/skills/slack-search-user/cache-utils.sh" list

# Search cache
"$PLUGIN_ROOT/skills/slack-search-user/cache-utils.sh" search "<pattern>"

# Clear cache
"$PLUGIN_ROOT/skills/slack-search-user/cache-utils.sh" clear
```

Present the results to the user in a friendly format.
