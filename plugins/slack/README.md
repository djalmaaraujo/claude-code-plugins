# Slack Plugin for Claude Code

Complete Slack integration for Claude Code - send messages, search users, with intelligent caching and automatic configuration validation.

## Features

- ✅ **Send messages to channels** - Post to any Slack channel you have access to
- ✅ **Send DMs to users** - Send direct messages using @username
- ✅ **Intelligent user search** - Fast user lookup with automatic caching
- ✅ **Automatic validation** - Checks configuration before every operation
- ✅ **Guided setup** - Interactive wizard for getting credentials
- ✅ **Large cache support** - Efficiently handles 50,000+ cached users
- ✅ **Case-insensitive matching** - Find users by username, real name, or display name
- ✅ **Bulk caching** - Caches up to 1000 users per API call

## Dependencies

### System Requirements

- **jq** 1.6+ - JSON processor for fast cache lookups
- **Python** 3.6+ - For Slack API calls
- **curl** 7.0+ - For HTTP requests

Install on macOS:

```bash
brew install jq python curl
```

### Slack Session Credentials

This plugin requires your browser's Slack session credentials (token and cookie) to authenticate API requests. You'll need to:

1. Be logged into Slack in your web browser
2. Extract your session token (xoxc-...) and cookie (xoxd-...) from browser DevTools
3. Provide these credentials during setup via `/slack:slack-setup`

**Important:** The plugin uses your existing browser session - no passwords are stored, and credentials remain local on your machine.

See the "How It Works" section below for detailed instructions on obtaining credentials.

## Installation

This plugin is part of the djalmaaraujo-claude-code-plugins marketplace.

To install, see the [main marketplace README](../../README.md#installation) for instructions on:
1. Adding the marketplace: `/plugin marketplace add djalmaaraujo/claude-code-plugins`
2. Installing this plugin: `/plugin install slack@djalmaaraujo-claude-code-plugins`

Or use the interactive UI: `/plugin` → **Discover** tab

## Quick Start

### 1. Setup (First Time Only)

Run the setup wizard:

```
/slack:slack-setup
```

Or check current status:

```
/slack:slack-status
```

### 2. Search for Users

Use the slash command:

```
/slack:slack-search-user djalma
```

Or via bash:

```bash
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-search-user/search-user.sh djalma
```

### 3. Send Messages

Use the slash command:

```
/slack:slack-send-message Send 'Hello team!' to #slack-ai-testing
```

**Send to a channel:**

```
/slack:slack-send-message Post 'Build complete!' to #dev-updates
```

**Send a DM:**

```
/slack:slack-send-message DM @djalma saying: Can you review my PR?
```

## Available Slash Commands

| Command                     | Description                                   |
| --------------------------- | --------------------------------------------- |
| `/slack:slack-setup`        | Interactive setup wizard for credentials      |
| `/slack:slack-status`       | Check configuration and authentication status |
| `/slack:slack-search-user`  | Search for users by name                      |
| `/slack:slack-send-message` | Send messages to channels or DMs              |

## Skills

### slack-status

Validates Slack configuration and credentials. Automatically called by other skills.

```bash
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-status/check.sh
```

**Output:**

- `OK` - Everything is working
- `MISSING_CONFIG` - Config file doesn't exist
- `MISSING_CREDENTIALS` - Required fields missing
- `INVALID_AUTH` - Credentials are invalid
- `EXPIRED_TOKEN` - Token has expired

### slack-setup

Interactive setup wizard that guides you through obtaining Slack credentials.

See `skills/slack-setup/SKILL.md` for detailed instructions.

### slack-search-user

Search for Slack users with intelligent caching.

**Usage:**

```bash
# Find user
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-search-user/search-user.sh <username>

# Cache utilities
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-search-user/cache-utils.sh <command>
# Commands: count, list, search <pattern>, clear
```

**Features:**

- Cache-first strategy (fast lookups)
- API fallback (finds any user)
- Bulk caching (1000 users per request)
- Case-insensitive matching

### slack-send-message

Send messages to channels or DMs to users.

**Features:**

- Automatic channel/DM detection
- Integrates with slack-search-user
- Validates configuration first
- Clear error messages

## Configuration

All configuration is stored in a single file:

```
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/config.json
```

**Structure:**

```json
{
  "workspace": "a8c.slack.com",
  "token": "xoxc-...",
  "cookie": "xoxd-...",
  "users": [],
  "setup_date": "2026-01-11T02:00:00Z",
  "last_validated": "2026-01-11T02:00:00Z"
}
```

- **workspace**: Your Slack domain
- **token**: Session token from browser (xoxc-...)
- **cookie**: Session cookie from browser (xoxd-...)
- **users**: Cached user data (auto-populated)

## Architecture

```
slack/
├── plugin.json              # Plugin metadata
├── config.json              # Centralized config
├── README.md                # This file
│
├── lib/                     # Shared libraries
│   ├── config.sh            # Config loader
│   └── slack-api.sh         # API functions
│
├── skills/                  # Skills
│   ├── slack-status/        # Configuration validator
│   ├── slack-setup/         # Setup wizard
│   ├── slack-search-user/   # User search
│   └── slack-send-message/  # Message sending
│
├── scripts/                 # Utility scripts
└── tests/                   # Test scripts
```

## How It Works

### Credentials

The plugin uses your browser's Slack session credentials (token and cookie). These are the same credentials your browser uses when you're logged into Slack.

**Getting credentials:**

1. Open Slack in Chrome
2. Open DevTools (Cmd+Option+J)
3. Network tab → Send a message → Find `chat.postMessage`
4. Extract token and cookie from the request

**Security:**

- Credentials are stored locally only
- Config file has 600 permissions (only you can read)
- No passwords are stored
- Uses existing browser session

### Caching

User searches are cached to avoid repeated API calls.

**How it works:**

1. First search checks cache (using `jq` - very fast)
2. If not found, calls Slack API
3. API returns up to 1000 users per request
4. ALL users are cached automatically
5. Future searches are instant

**Performance:**

- Cache lookup: ~10ms even with 50,000 users
- API call: ~500ms + caching time
- Subsequent lookups: instant

## Troubleshooting

### "Slack is not properly configured"

Run the slack-status check to see what's wrong:

```bash
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/skills/slack-status/check.sh
```

### "invalid_auth" or "token_expired"

Your credentials expired. Get fresh ones:

1. Log out and log back into Slack in browser
2. Follow setup instructions again
3. Update config.json

### "User not found"

The user might not exist or the username doesn't match:

- Try searching by real name instead
- Check spelling
- User might be in a different workspace

### "channel_not_found"

- Check channel name spelling
- Make sure you're a member of the channel
- Private channels require membership

## Development

### Testing

```bash
# Test status
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/tests/test-status.sh

# Test search
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/tests/test-search.sh djalma

# Test send
~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/tests/test-send.sh
```

### Adding New Skills

1. Create skill directory in `skills/`
2. Add `SKILL.md` with documentation
3. Add executable scripts
4. Use shared libraries from `lib/`
5. Call `slack-status` before operations
6. Update `plugin.json`

## License

MIT

## Author

Djalma Araujo

## Support

For issues, questions, or contributions:

- GitHub: https://github.com/djalmaaraujo/claude-code-plugins
- Report bugs in Issues section
