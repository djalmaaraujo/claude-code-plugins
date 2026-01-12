# Claude Code Plugins Marketplace

A collection of plugins for [Claude Code](https://claude.ai/code).

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [**planner**](plugins/planner/README.md) | Sub-agent-based plan execution with dependency resolution and parallelism |
| [**slack**](plugins/slack/README.md) | Send Slack messages and search users via browser session credentials |

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
