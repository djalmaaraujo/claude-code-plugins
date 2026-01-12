# Claude Code Plugins Marketplace

A collection of plugins for [Claude Code](https://claude.ai/code) providing planning, execution, and Slack integration tools.

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| **planner** | Sub-agent-based plan execution with dependency resolution and parallelism | 2.0.0 |
| **slack** | Send Slack messages and search users via browser session credentials | 1.0.0 |

## Installation

### Add the Marketplace

```bash
claude plugins:add-marketplace https://github.com/djalmaaraujo/claude-code-plugins
```

### Install Individual Plugins

```bash
# Install the planner plugin
claude plugins:install djalmaaraujo-claude-code-plugins:planner

# Install the slack plugin
claude plugins:install djalmaaraujo-claude-code-plugins:slack
```

### Install All Plugins

```bash
claude plugins:install djalmaaraujo-claude-code-plugins:*
```

## Architecture

Each plugin uses a **command → skill** pattern:
- **Commands** (`/plugin:command`): Thin wrappers users invoke directly
- **Skills**: Core logic that commands delegate to

This allows commands to appear in the slash menu while keeping logic in reusable skills.

---

## Planner Plugin

Break down complex features into manageable plans with automatic dependency resolution and parallel execution.

### Features

- Plan creation with dependency tracking
- Automatic dependency resolution and ordering
- Parallel execution of independent plans
- Progress tracking via `PROGRESS.md`
- Configuration options (auto-commit, CLAUDE.md updates)

### Commands

| Command | Description |
|---------|-------------|
| `/planner:planner-setup` | Initialize planner in your project |
| `/planner:planner-create` | Create plan files for a feature |
| `/planner:planner-status` | Show overview of all plans and progress |
| `/planner:planner-exec` | Execute a single plan file |
| `/planner:planner-batch` | Execute all plans with dependency resolution |

### Quick Start

```
# 1. Initialize planner in your project
/planner:planner-setup

# 2. Create plans for a feature
/planner:planner-create Add user authentication with OAuth

# 3. Check status
/planner:planner-status

# 4. Execute all plans
/planner:planner-batch
```

### Directory Structure Created

```
your-project/
└── plans/
    ├── planner.config.json    # Configuration
    ├── PROGRESS.md            # Execution tracking
    ├── 001-first-plan.md      # Plan files
    └── 002-second-plan.md
```

## Slack Plugin

Send messages to Slack channels and DMs directly from Claude Code using your browser session credentials.

### Features

- Send messages to any channel you have access to
- Send DMs using @username
- Intelligent user search with caching
- Automatic configuration validation
- Support for large workspaces (50,000+ users)

### Commands

| Command | Description |
|---------|-------------|
| `/slack:slack-setup` | Interactive setup wizard for credentials |
| `/slack:slack-status` | Check configuration and auth status |
| `/slack:slack-search-user` | Search for users by name |
| `/slack:slack-send-message` | Send messages to channels or DMs |

### Quick Start

```
# 1. Run setup wizard (first time only)
/slack:slack-setup

# 2. Send a message to a channel
/slack:slack-send-message Post 'Hello team!' to #general

# 3. Send a DM
/slack:slack-send-message DM @username saying: Can you review my PR?

# 4. Search for a user
/slack:slack-search-user john
```

### Configuration

The plugin stores credentials in `~/.claude/plugins/marketplaces/djalmaaraujo-claude-code-plugins/plugins/slack/config.json`:

```json
{
  "workspace": "your-workspace.slack.com",
  "token": "xoxc-...",
  "cookie": "xoxd-...",
  "users": []
}
```

### Getting Credentials

1. Open Slack in Chrome
2. Open DevTools (Cmd+Option+J / Ctrl+Shift+J)
3. Go to Network tab
4. Send any message in Slack
5. Find `chat.postMessage` request
6. Extract `token` from request body and `d` cookie value

Run `/slack:slack-setup` for guided instructions.

### Requirements

- **jq** 1.6+ - JSON processor
- **Python** 3.6+ - For API calls
- **curl** 7.0+ - For HTTP requests

Install on macOS:
```bash
brew install jq python curl
```

## Updating Plugins

```bash
# Update all plugins from this marketplace
claude plugins:update djalmaaraujo-claude-code-plugins

# Update a specific plugin
claude plugins:update djalmaaraujo-claude-code-plugins:planner
```

## Uninstalling

```bash
# Remove a specific plugin
claude plugins:remove djalmaaraujo-claude-code-plugins:slack

# Remove the entire marketplace
claude plugins:remove-marketplace djalmaaraujo-claude-code-plugins
```

## License

MIT

## Author

[Djalma Araujo](https://github.com/djalmaaraujo)

## Contributing

Issues and pull requests are welcome at [GitHub](https://github.com/djalmaaraujo/claude-code-plugins).
