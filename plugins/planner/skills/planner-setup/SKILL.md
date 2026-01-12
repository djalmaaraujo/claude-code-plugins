---
name: planner-setup
description: Initialize planner in a project by creating plans/ directory, and PROGRESS.md tracking file. Use when user wants to set up planning, initialize planner, or start using the planner system.
allowed-tools: Task, TaskOutput, Read, Write, Edit, Bash, Glob, AskUserQuestion
user-invocable: true
---

# Setup Planner

You are now executing the planner-setup skill. Follow these steps immediately:

## Step 1: Check for Existing Configuration

Check if configuration has already been set up:

1. **First, check for new format**: Try to read `plans/planner.config.json`

   - If exists and valid JSON:
     - Parse: `auto_commit`, `auto_update_claude_md`, `smart_parallelism`, `replan_on_exec`
     - Store as: `config_exists = true`, `migration_needed = false`
     - Skip to Step 3 (don't ask questions)

2. **Then, check for old format**: Try to read `.claude/CLAUDE.md`

   - Search for "## Planner Execution Configuration" section
   - If found:
     - Parse existing values for: auto_commit, auto_update_claude_md, smart_parallelism, replan_on_exec
     - Store as: `config_exists = true`, `migration_needed = true`
     - Skip to Step 3 (will migrate to JSON format)
     - Note: If replan_on_exec is not found in old config, default to `false`

3. **If neither found**:
   - Set `config_exists = false`, `migration_needed = false`
   - Continue to Step 2 (ask questions)

## Step 2: Ask Configuration Questions (Only if config_exists = false)

Use AskUserQuestion to ask the user about configuration preferences:

**Question 1: Auto-commit**

```
header: "Auto-commit"
question: "Should plans automatically create a git commit after successful execution?"
options:
  - label: "Yes (Recommended)"
    description: "Automatically commit changes after each plan completes successfully"
  - label: "No"
    description: "Manual commits only - you'll commit changes yourself"
```

**Question 2: Auto-update CLAUDE.md**

```
header: "CLAUDE.md"
question: "Should plans automatically update .claude/CLAUDE.md if plan changes make project documentation inaccurate?"
options:
  - label: "Yes"
    description: "Keep project CLAUDE.md up-to-date with code changes automatically"
  - label: "No (Recommended)"
    description: "Manual updates only - you'll update project documentation yourself"
```

**Question 3: Smart Parallelism**

```
header: "Parallelism"
question: "How should plans handle dependencies when creating new plans?"
options:
  - label: "Aggressive (Recommended)"
    description: "Maximize parallel execution with fewer dependencies (faster)"
  - label: "Conservative"
    description: "More sequential dependencies for safer execution (slower)"
```

**Question 4: Re-plan on Executing**

```
header: "Re-plan"
question: "Should plans be re-analyzed before execution?"
options:
  - label: "No (Recommended)"
    description: "Execute plans as written for faster execution"
  - label: "Yes"
    description: "Enable for fine-grained executions (slows the execution)"
```

**Question 5: Use Specs**

```
header: "Specs"
question: "Would you like to use specification files before creating plans?"
options:
  - label: "Yes (Recommended)"
    description: "Create detailed specs first, then generate plans from specs"
  - label: "No"
    description: "Create plans directly without spec files"
```

**Question 6: Spec Verbosity** (Only ask if uses_spec = true)

```
header: "Verbosity"
question: "How interactive should spec creation be?"
options:
  - label: "Maximum inference (Recommended)"
    description: "Infer everything possible from codebase, minimal questions"
  - label: "Interactive"
    description: "Ask more clarifying questions during spec creation"
```

Store the answers as:

- `config.auto_commit = true/false`
- `config.auto_update_claude_md = true/false`
- `config.smart_parallelism = true/false`
- `config.replan_on_exec = true/false`
- `config.uses_spec = true/false`
- `config.spec_verbose = true/false` (only if uses_spec = true, otherwise false)

## Step 3: Get Project Name

Determine project name:

- If user provided a name, use it
- Otherwise, use current directory name
- Store as: `project_name`

## Step 4: Spawn Setup Agent

Use the Task tool to spawn the setup-agent:

```
Task tool:
  description: "Initialize planner in project"
  subagent_type: "planner:setup-agent"
  prompt: |
    project_name: "[project_name from Step 3]"

    migration_needed: [true/false from Step 1]

    config:
      auto_commit: [true/false]
      auto_update_claude_md: [true/false]
      smart_parallelism: [true/false]
      replan_on_exec: [true/false]
      uses_spec: [true/false]
      spec_verbose: [true/false]

    BEGIN SETUP.
```

## Step 5: Report Results

After the agent completes, report to the user:

```
════════════════════════════════════════
Planner Setup Complete

Project: [project_name]

Files created:
- plans/ (directory)
- plans/PROGRESS.md (tracking file)
- plans/planner.config.json (configuration)

Configuration:
- Auto-commit: [enabled/disabled]
- Auto-update CLAUDE.md: [enabled/disabled]
- Smart Parallelism: [aggressive/conservative]
- Re-plan on Executing: [enabled/disabled]
- Use Specs: [enabled/disabled]
- Spec Verbosity: [maximum inference/interactive] (if specs enabled)

Next steps:
[If uses_spec enabled:]
1. Create a spec: /planner:spec-create [prefix] "[description]"
2. Generate plans from spec: /planner:spec-plans-sync [prefix]
3. Execute plans: /planner:batch --prefix=[prefix]

[If uses_spec disabled:]
1. Create plans: Tell Claude "Create plans for [feature]"
2. Execute plans: Tell Claude "Execute all [prefix] plans"

You can change configuration anytime by editing plans/planner.config.json
════════════════════════════════════════
```

---

## Reference Information

### What This Skill Does

When setting up planner in a project, this skill:

1. **Checks Existing Config**: Looks for configuration in `plans/planner.config.json` or `.claude/CLAUDE.md` (old format)
2. **Migrates if Needed**: Auto-migrates from old CLAUDE.md format to new JSON format
3. **Asks Configuration Questions**: Only if config doesn't exist (first-time setup)
4. **Creates Directory Structure**: Sets up `plans/` directory
5. **Creates Tracking File**: Initializes `plans/PROGRESS.md`
6. **Saves Configuration**: Writes config to `plans/planner.config.json`

### Safety Features

- **Idempotent**: Safe to run multiple times without overwriting existing content
- **Configuration Persistence**: Once set, config is not asked again
- **Append-only**: Adds planner instructions with separators if file exists

### Configuration Options

**Auto-commit:**

- When enabled: Automatically creates git commits after successful plans
- When disabled: You manually commit changes
- Recommended: Enabled (for automatic tracking)

**Auto-update CLAUDE.md:**

- When enabled: Plans update project `.claude/CLAUDE.md` if code changes make it inaccurate
- When disabled: You manually update project documentation
- Recommended: Disabled (for manual control)

**Smart Parallelism:**

- When aggressive: Fewer dependencies, more parallel execution (faster)
- When conservative: More sequential dependencies (safer)
- Recommended: Aggressive (for speed)

**Re-plan on Executing:**

- When enabled: Re-analyzes and drafts fresh implementation outline before executing (slower but more accurate)
- When disabled: Executes plans as written without re-planning (faster execution)
- Recommended: Disabled (for speed)

**Use Specs (uses_spec):**

- When enabled: Spec workflow is active - create specs before plans
- When disabled: Traditional plan-only workflow
- Recommended: Enabled (for comprehensive documentation)

**Spec Verbosity (spec_verbose):**

- Maximum inference: Infers everything possible from codebase, minimal user questions
- Interactive: Asks more clarifying questions during spec creation
- Recommended: Maximum inference (for speed)

### Directory Structure Created

```
project-root/
└── plans/
    ├── planner.config.json          # Planner configuration
    └── PROGRESS.md                  # Plan execution tracking
```

### PROGRESS.md Format

```markdown
# Implementation Progress

## Feature Name

| Plan                         | Status      | Date |
| ---------------------------- | ----------- | ---- |
| feature-00-setup.md          | NOT STARTED |      |
| feature-01-implementation.md | NOT STARTED |      |
```

### Changing Configuration Later

Users can edit `plans/planner.config.json` directly:

```json
{
  "version": "2.0.0",
  "auto_commit": true,
  "auto_update_claude_md": false,
  "smart_parallelism": true,
  "replan_on_exec": false,
  "uses_spec": true,
  "spec_verbose": false
}
```

Simply change boolean values and save the file.

### Example

```
User: Initialize planner in this project

Step 1: Check existing config
→ Not found in plans/planner.config.json
→ Not found in .claude/CLAUDE.md
→ config_exists = false, migration_needed = false

Step 2: Ask configuration questions
→ Auto-commit? Yes (Recommended)
→ Auto-update CLAUDE.md? No (Recommended)
→ Smart Parallelism? Aggressive (Recommended)

Step 3: Get project name
→ Using current directory: "my-app"

Step 4: Spawn setup agent
→ Creates plans/ directory
→ Creates plans/PROGRESS.md
→ Creates plans/planner.config.json

Step 5: Report results
→ Setup complete
→ Configuration saved
→ Ready to create plans
```
