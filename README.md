# Claude Code Plugins Marketplace

A collection of plugins for [Claude Code](https://claude.ai/code).

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [**planner**](plugins/planner/README.md) | Sub-agent-based plan execution with dependency resolution and parallelism |
| [**slack**](plugins/slack/README.md) | Send Slack messages and search users via browser session credentials |

## Dependencies

### Planner Plugin

**Optional dependencies for Linear integration:**
- [Linear MCP server](https://github.com/modelcontextprotocol/servers/tree/main/src/linear) - Required only if you want to use Linear integration features (`/planner:linear-project-create`, `/planner:linear-milestone-create`, `/planner:linear-issue-create`)

All other planner features work without any external dependencies.

### Slack Plugin

**System requirements:**
- jq 1.6+ (JSON processor)
- Python 3.6+ (for API calls)
- curl 7.0+ (for HTTP requests)

**Authentication requirements:**
- Slack browser session credentials (token and cookie)
- Obtained via `/slack:slack-setup` wizard from your browser's DevTools

See individual plugin READMEs for detailed setup instructions.

## Installation

### Add the Marketplace

From within Claude Code, run:

```bash
/plugin marketplace add djalmaaraujo/claude-code-plugins
```

Or add via GitHub URL:

```bash
/plugin marketplace add https://github.com/djalmaaraujo/claude-code-plugins
```

### Install Plugins

**Option 1: Interactive UI (Recommended)**

```bash
/plugin
```

Then navigate to the **Discover** tab, find the plugin you want, and press **Enter** to install.

**Option 2: Command line**

```bash
# Install the planner plugin
/plugin install planner@djalmaaraujo-claude-code-plugins

# Install the slack plugin
/plugin install slack@djalmaaraujo-claude-code-plugins
```

## Managing Plugins

### Update Marketplace

Refresh plugin listings from this marketplace:

```bash
/plugin marketplace update djalmaaraujo-claude-code-plugins
```

Or enable auto-updates via the UI:

```bash
/plugin
```

Go to **Marketplaces** tab and toggle **Enable auto-update** for this marketplace.

### Disable/Enable Plugins

```bash
# Disable a plugin (keep installed)
/plugin disable planner@djalmaaraujo-claude-code-plugins

# Re-enable a disabled plugin
/plugin enable planner@djalmaaraujo-claude-code-plugins
```

### Uninstall

```bash
# Remove a specific plugin
/plugin uninstall slack@djalmaaraujo-claude-code-plugins

# Remove the entire marketplace
/plugin marketplace remove djalmaaraujo-claude-code-plugins
```

## License

MIT

## Author

[Djalma Araujo](https://github.com/djalmaaraujo)

## Contributing

Issues and pull requests are welcome at [GitHub](https://github.com/djalmaaraujo/claude-code-plugins).
