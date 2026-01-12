---
name: planner-setup
description: Setup or reconfigure planner settings. ALWAYS asks configuration questions so users can update their preferences. Creates plans/ and PROGRESS.md only if they don't exist.
allowed-tools: Task, TaskOutput, Read, Write, Edit, Bash, Glob, AskUserQuestion
user-invocable: true
---

# Setup Planner

You are now executing the planner-setup skill.

**CRITICAL**: This skill ALWAYS asks configuration questions, even if planner is already set up. This allows users to update their configuration anytime.

Follow these steps immediately:

## Step 1: Check Existing State (for defaults only)

Check what exists to determine default values for questions and what files need creating:

1. **Read config file**: Try to read `plans/planner.config.json`
   - If exists: Store current values as defaults for the questions
   - Note: `config_exists = true`

2. **Check for files**:
   - Check if `plans/` directory exists
   - Check if `plans/PROGRESS.md` exists

**DO NOT SKIP ANY STEPS** - proceed to Step 2 regardless of what exists.

## Step 2: Ask Configuration Questions (ALWAYS)

**YOU MUST ASK THESE QUESTIONS** - do not skip this step even if configuration already exists.

Use AskUserQuestion to ask ALL of the following questions:

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

    existing_files:
      plans_dir_exists: [true/false]
      progress_exists: [true/false]
      config_exists: [true/false]

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

Files:
- plans/ (directory) [created / already exists]
- plans/PROGRESS.md [created / already exists]
- plans/planner.config.json [created / updated]

Configuration [saved / updated]:
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

Run /planner:planner-setup anytime to update configuration.
════════════════════════════════════════
```

---

## Reference Information

### What This Skill Does

When setting up planner in a project, this skill:

1. **Checks Existing State**: Looks for existing config, plans directory, and PROGRESS.md
2. **Always Asks Questions**: Configuration questions are always presented (with current values pre-selected if config exists)
3. **Migrates if Needed**: Auto-migrates from old CLAUDE.md format to new JSON format
4. **Creates Missing Files**: Only creates `plans/` directory and `PROGRESS.md` if they don't exist
5. **Always Updates Config**: Writes new configuration to `plans/planner.config.json`

### Key Behaviors

- **Re-runnable**: Users can run `/planner:planner-setup` anytime to update configuration
- **Non-destructive**: Existing plans, specs, and PROGRESS.md content are preserved
- **Config Updates**: Configuration is always updated with the user's new answers
- **Pre-filled Defaults**: When config exists, current values are shown as the recommended options

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

### Example: First-time Setup

```
User: /planner:planner-setup

Step 1: Check existing state
→ plans/planner.config.json: not found
→ plans/ directory: not found
→ plans/PROGRESS.md: not found
→ config_exists = false

Step 2: Ask configuration questions
→ Auto-commit? Yes (Recommended)
→ Auto-update CLAUDE.md? No (Recommended)
→ Smart Parallelism? Aggressive (Recommended)
→ Re-plan on Executing? No (Recommended)
→ Use Specs? Yes (Recommended)
→ Spec Verbosity? Maximum inference (Recommended)

Step 3: Get project name
→ Using current directory: "my-app"

Step 4: Spawn setup agent
→ Creates plans/ directory
→ Creates plans/PROGRESS.md
→ Creates plans/planner.config.json

Step 5: Report results
→ Setup complete, configuration saved
```

### Example: Updating Configuration

```
User: /planner:planner-setup

Step 1: Check existing state
→ plans/planner.config.json: found (auto_commit: true, uses_spec: true, ...)
→ plans/ directory: exists
→ plans/PROGRESS.md: exists
→ config_exists = true

Step 2: Ask configuration questions (pre-filled with current values)
→ Auto-commit? Yes (current) → User selects "No"
→ Auto-update CLAUDE.md? No (current) → User keeps
→ Smart Parallelism? Aggressive (current) → User keeps
→ Re-plan on Executing? No (current) → User keeps
→ Use Specs? Yes (current) → User keeps
→ Spec Verbosity? Maximum inference (current) → User selects "Interactive"

Step 3: Get project name
→ Using current directory: "my-app"

Step 4: Spawn setup agent
→ plans/ directory: already exists (skipped)
→ plans/PROGRESS.md: already exists (skipped)
→ plans/planner.config.json: updated with new values

Step 5: Report results
→ Configuration updated (auto_commit: false, spec_verbose: true)
```
