# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code plugin marketplace containing two plugins:
- **planner**: Sub-agent-based plan execution system with dependency resolution and parallel execution
- **slack**: Slack integration for sending messages and searching users via browser session credentials

## Architecture

### Marketplace Structure
```
.claude-plugin/marketplace.json    # Marketplace metadata, lists all plugins
plugins/
├── planner/                       # Plan execution plugin
│   ├── .claude-plugin/plugin.json # Plugin metadata
│   ├── agents/                    # Subagent definitions (.md files)
│   ├── skills/                    # Skill definitions (each has SKILL.md)
│   └── hooks/hooks.json           # Hook configurations
└── slack/                         # Slack integration plugin
    ├── .claude-plugin/plugin.json # Plugin metadata
    ├── lib/                       # Shared bash libraries (config.sh, slack-api.sh)
    ├── skills/                    # Skill definitions (each has SKILL.md + shell scripts)
    └── tests/                     # Test scripts
```

### Plugin Component Types

**Skills** (`skills/*/SKILL.md`): User-invocable commands with frontmatter:
- `name`, `description`, `allowed-tools`, `user-invocable: true`
- Markdown body contains execution instructions

**Subagents** (`agents/*.md`): Spawned by skills via Task tool with `subagent_type: "planner:agent-name"`

**Shared Libraries** (Slack plugin): Bash scripts in `lib/` sourced by skill scripts

### Key Patterns

**Planner Plugin Flow**:
1. Skills (`planner-setup`, `planner-create`, etc.) receive user requests
2. Skills spawn subagents via Task tool with structured prompts
3. Subagents execute and return results
4. Skills format and report results to user

**Slack Plugin Flow**:
1. Skills validate config via `slack-status/check.sh`
2. Shared functions in `lib/slack-api.sh` handle API calls
3. Config stored in `config.json` (workspace, token, cookie)
4. User cache maintained for fast lookups

## Testing

### Slack Plugin
```bash
# Run all tests
plugins/slack/tests/run-all-tests.sh

# Individual tests
plugins/slack/tests/test-send-dm.sh
plugins/slack/tests/test-send-channel.sh

# Verify configuration
plugins/slack/scripts/verify.sh
plugins/slack/skills/slack-status/check.sh
```

## Configuration Files

- `plugins/slack/config.json`: Slack credentials (gitignored)
- `plugins/slack/example.config.json`: Template for config.json
- `plugins/planner/hooks/hooks.json`: Planner hook definitions
