---
name: slack-search-user
description: Search for Slack users by username with intelligent caching. Returns user IDs for DMs and maintains a local cache to avoid repeated API calls. Can answer questions about cached users.
user-invocable: true
---

# Slack Search User Skill

Search for Slack users by username, real name, or display name with intelligent caching. This skill maintains a local cache of users to speed up lookups and can answer questions about the cache.

**Features:**

- ✅ **Automatic status check** - Verifies Slack is configured before searching
- ✅ **Efficient cache lookup** - Uses `jq` for fast searches even with 50,000+ users
- ✅ **Automatic API fallback** - Searches via Slack API if user not in cache
- ✅ **Bulk caching** - Caches ALL users from API responses (up to 1000 per request)
- ✅ **Smart matching** - Exact match first, then partial/contains match as fallback
- ✅ **Cache introspection** - Can answer questions like "how many users are cached?"

## Usage

This skill provides two executable scripts:

### 1. `search-user.sh` - Find a specific user

Search for a Slack user by username, real name, or display name. Returns the user ID on stdout and details on stderr.

**When the user asks:**

- "Find user @fulano in Slack"
- "Search for Will in Slack"
- "Look up John Smith"
- "Is djalma in Slack?"

**Run:**

```bash
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-search-user/search-user.sh <username>
```

**Examples:**

```bash
# Find user by exact username
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-search-user/search-user.sh djalma
# Output: U01ULLNEM3Q

# Find user by real name
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-search-user/search-user.sh "John Smith"

# Capture user ID in a variable
USER_ID=$(~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-search-user/search-user.sh fulano)
echo "User ID: $USER_ID"
```

**How it works:**

1. Checks Slack status first (calls `slack-status`)
2. Checks cache first using `jq` (fast, even with 50,000+ users)
3. First tries exact match (case-insensitive) on `name`, `real_name`, `display_name`
4. If no exact match, tries partial match (startswith/contains)
5. If still not found, searches via Slack API with pagination
6. Automatically caches ALL users from API response (up to 1000 per request)
7. Excludes bots and deleted users
8. Returns user ID on stdout for easy integration

**Matching examples:**
- `djalma` matches user with username `djalma.araujo`
- `john` matches `John Smith` in real name
- `will` matches `William` in display name

### 2. `cache-utils.sh` - Cache management

Inspect and manage the user cache.

**When the user asks:**

- "How many users are cached?"
- "List all users with 'john' in their name"
- "Clear the Slack cache"

**Run:**

```bash
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-search-user/cache-utils.sh <command>
```

**Commands:**

```bash
# Count total cached users
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-search-user/cache-utils.sh count
# Output: Total cached users: 12000

# List all cached users
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-search-user/cache-utils.sh list

# Search for users matching a pattern
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-search-user/cache-utils.sh search will

# Clear the cache
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-search-user/cache-utils.sh clear
```

## Configuration

This skill uses the centralized Slack plugin configuration at:

```
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/config.json
```

The config file contains:

- `workspace` - Your Slack workspace domain
- `token` - Your session token (xoxc-...)
- `cookie` - Your session cookie (xoxd-...)
- `users` - Cached user array (auto-populated)

## Status Check

Before searching, the skill automatically checks Slack status. If not configured:

```
⚠️  Slack is not properly configured
MISSING_CONFIG|Config file not found|Create config at: ~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/config.json

Please run: /slack:slack-setup
```

## Integration with Other Skills

The `slack-send-message` skill uses this skill to find users for DMs.

## Important Notes

- **Automatic validation**: Checks configuration before every search
- **Shared cache**: Cache is shared across all Slack skills in the plugin
- **Efficient with large caches**: Uses `jq` for streaming, works well with 50,000+ users
- **Bulk caching**: One API call can populate hundreds or thousands of users
- **No duplicates**: Automatically skips users already in cache
- **Active users only**: Excludes bots and deleted users from cache
- **Requirements**:
  - `jq` is required (install with `brew install jq` on macOS)
  - Python 3.6+ is required for API calls
  - Slack plugin must be configured (run `/slack:slack-setup` if needed)

## Troubleshooting

| Error                              | Solution                                                            |
| ---------------------------------- | ------------------------------------------------------------------- |
| `Slack is not properly configured` | Run `/slack:slack-setup` to configure credentials                   |
| `invalid_auth`                     | Token or cookie expired. Re-run `/slack:slack-setup`                |
| `User 'X' not found`               | User doesn't exist or doesn't match any name fields                 |
| `jq: command not found`            | Install `jq`: `brew install jq` (macOS) or `apt install jq` (Linux) |
| Python JSON decode error           | Config file corrupted. Re-run `/slack:slack-setup`                  |
