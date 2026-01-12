# Planner Plugin for Claude Code

Sub-agent-based plan execution system with automatic dependency resolution, parallelism, and safety checks.

## Features

- ✅ **Plan creation** - Break down complex features into manageable plans
- ✅ **Dependency resolution** - Automatic ordering based on plan dependencies
- ✅ **Parallel execution** - Run independent plans simultaneously
- ✅ **Progress tracking** - PROGRESS.md tracks all plan statuses
- ✅ **Safety checks** - Validates dependencies before execution
- ✅ **Configuration options** - Auto-commit, CLAUDE.md updates, and more

## Methodology

### Philosophy: Small, Self-Contained Tasks

The planner is built on a core principle: **large tasks fail, small tasks succeed**.

When you ask Claude to implement a complex feature in one go, several things go wrong:

1. **Context Exhaustion**: Claude's context window fills up with code, conversation history, and intermediate results. By the time it reaches step 10, it has forgotten the nuances of step 1.

2. **Compounding Errors**: A small mistake in step 3 propagates through steps 4-10. Without checkpoints, you end up with a mess that's hard to debug.

3. **No Recovery**: If the session crashes, times out, or you need to stop - you lose everything. There's no way to resume from where you left off.

4. **Cognitive Overload**: Even Claude struggles to hold an entire feature's requirements, implementation details, edge cases, and testing strategy in mind simultaneously.

The solution is **decomposition**: break the feature into small, self-contained plans that each do one thing well.

### What Makes a Good Plan?

Each plan should be:

- **Single-purpose**: One clear objective (e.g., "Create user model" not "Create user model and auth routes and middleware")
- **Self-contained**: All context needed is in the plan file itself - no assumptions about what Claude "remembers"
- **Independently testable**: You can verify the plan worked without running other plans
- **~40% context usage**: Small enough that Claude has room to think, not just read

### Why Sub-Agents?

This is the key insight: **each plan runs in a fresh sub-agent with zero memory of previous plans**.

```
Main Session                    Sub-Agents (isolated)
─────────────                   ─────────────────────
┌─────────────┐
│ User: "run  │                 ┌─────────────────┐
│ batch"      │────────────────▶│ Agent 1: 001.md │ ← Fresh context
└─────────────┘                 │ (only sees 001) │
                                └─────────────────┘
                                         │
                                         ▼ completes
                                ┌─────────────────┐
                                │ Agent 2: 002.md │ ← Fresh context
                                │ (only sees 002) │
                                └─────────────────┘
                                         │
                                         ▼ completes
                                ┌─────────────────┐
                                │ Agent 3: 003.md │ ← Fresh context
                                │ (only sees 003) │
                                └─────────────────┘
```

**Why this matters:**

| Traditional Approach | Sub-Agent Approach |
|---------------------|-------------------|
| Context accumulates with each step | Each plan starts fresh |
| Errors from plan 1 confuse plan 5 | Plan 5 only knows about plan 5 |
| Can't resume - context is lost | Resume any plan anytime |
| Quality degrades as context fills | Consistent quality throughout |
| One bad plan ruins the session | Failed plans are isolated |

### The Context Problem (Solved)

Imagine implementing a 10-step feature:

**Without planner:**
```
Step 1:  [████░░░░░░░░░░░░░░░░] 20% context used
Step 5:  [████████████░░░░░░░░] 60% context used
Step 8:  [████████████████████] 100% context - degraded output
Step 10: [💥 OVERFLOW] - lost work, confused Claude
```

**With planner:**
```
Plan 001: [████░░░░░░░░░░░░░░░░] 20% → completes → discarded
Plan 002: [████░░░░░░░░░░░░░░░░] 20% → completes → discarded
Plan 003: [████░░░░░░░░░░░░░░░░] 20% → completes → discarded
...each plan has full context budget
```

Each sub-agent gets the **entire context window** for just its plan. This means:
- More room for reasoning and edge cases
- Better code quality
- Consistent performance from first plan to last

### How It Works

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  User Request   │────▶│  Plan Creator   │────▶│   Plan Files    │
│                 │     │   (analyzes     │     │  001-setup.md   │
│ "Add user auth" │     │    codebase)    │     │  002-models.md  │
└─────────────────┘     └─────────────────┘     │  003-routes.md  │
                                                └────────┬────────┘
                                                         │
                        ┌────────────────────────────────┘
                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  PROGRESS.md    │◀────│  Plan Executor  │◀────│ Dependency      │
│  (tracking)     │     │  (sub-agents)   │     │ Resolution      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

1. **Plan Creation**: The `plan-creator` agent analyzes your codebase and breaks down the feature into numbered plan files with clear dependencies.

2. **Dependency Resolution**: Each plan declares its dependencies (e.g., `depends_on: 001-setup`). The batch executor builds a dependency graph and determines execution order.

3. **Sub-Agent Execution**: Each plan is executed by a dedicated sub-agent (`plan-executor`) that:
   - Reads only the plan file (fresh context)
   - Implements the steps exactly as written
   - Updates PROGRESS.md on completion
   - Has no memory of other plans

4. **Parallel Execution**: Independent plans (no shared dependencies) run simultaneously, reducing total execution time.

### Plans as Documentation

A side benefit: your plans become permanent documentation of *how* the feature was built.

- **Onboarding**: New team members can read plans to understand the feature
- **Debugging**: When something breaks, check which plan implemented it
- **Auditing**: Clear record of what changed and why
- **Reusability**: Similar features can reuse plan structures

### Dependency Graph Example

```
001-setup-database (no deps)
    │
    ├──▶ 002-user-model (depends: 001)
    │        │
    │        └──▶ 004-auth-routes (depends: 002, 003)
    │                     │
    └──▶ 003-session-store (depends: 001)
                          │
              005-middleware (depends: 004)
```

**Execution rounds:**
- Round 1: `001-setup-database` (parallel: none)
- Round 2: `002-user-model`, `003-session-store` (parallel: yes)
- Round 3: `004-auth-routes` (parallel: none)
- Round 4: `005-middleware` (parallel: none)

### When to Use Planner

**Good fit:**
- Multi-file features (auth, API endpoints, UI components)
- Refactoring across many files
- Features with clear sequential steps
- Team handoffs (plans are documentation)

**Not needed:**
- Single-file changes
- Bug fixes
- Quick tweaks

## Quick Start

### 1. Initialize Planner

```
/planner:planner-setup
```

This creates the `plans/` directory and `PROGRESS.md` tracking file.

### 2. Create Plans

```
/planner:planner-create Add user authentication feature
```

This breaks down the feature into multiple plan files with proper dependencies.

### 3. Check Status

```
/planner:planner-status
```

Shows progress bar, completed plans, in-progress plans, and suggested next actions.

### 4. Execute Plans

**Single plan:**
```
/planner:planner-exec plans/001-setup-database.md
```

**All plans (with dependency resolution):**
```
/planner:planner-batch
```

## Available Slash Commands

| Command | Description |
|---------|-------------|
| `/planner:planner-setup` | Initialize planner in a project |
| `/planner:planner-create` | Create plan files for a feature |
| `/planner:planner-status` | Show overview of all plans |
| `/planner:planner-exec` | Execute a single plan file |
| `/planner:planner-batch` | Execute multiple plans with dependency resolution |
| `/planner:planner-eject-template` | Export plan template for customization |

## Directory Structure

After setup, your project will have:

```
project/
├── plans/
│   ├── PROGRESS.md           # Status tracking
│   ├── planner.config.json   # Configuration
│   ├── 001-first-plan.md     # Plan files
│   ├── 002-second-plan.md
│   └── ...
```

## Plan File Format

Each plan file includes:

```markdown
# Configuration

depends_on: none
linear_project:
linear_issue:

# Plan: 001-feature-name

## Objective
What this plan accomplishes and the expected outcome.

## Context
Relevant context from the codebase, patterns to follow.

## Implementation Steps
### Step 1: First step
Detailed instructions...

### Step 2: Second step
Continue with additional steps...

## Files to Modify
| File | Action | Description |
|------|--------|-------------|
| src/file.ts | CREATE | New file description |

## Testing Instructions
1. Verify step 1
2. Verify step 2

## Completion Checklist
- [ ] All implementation steps completed
- [ ] Tests pass
- [ ] No linting errors
```

### Configuration Fields

- **depends_on**: Plan dependencies (e.g., `none`, `001-setup`, `001-setup, 002-models`)
- **linear_project**: Optional Linear project association
- **linear_issue**: Optional Linear issue link

## Configuration

`plans/planner.config.json`:

```json
{
  "auto_commit": false,
  "auto_update_claude_md": false,
  "smart_parallelism": true
}
```

- **auto_commit**: Automatically commit after each plan
- **auto_update_claude_md**: Update project CLAUDE.md with changes
- **smart_parallelism**: Run independent plans in parallel

## Template Customization

Customize how plans are generated by ejecting the default template:

```
/planner:planner-eject-template plan
```

This creates:
- `plans/task.TEMPLATE.md` - Main plan template with `{{PLACEHOLDER}}` syntax
- `plans/standards/` - Convention files referenced by plans

The template uses `{{PLACEHOLDER}}` syntax that the plan-creator agent replaces with actual content. Edit the ejected template to match your project's conventions.

### Placeholder Reference

| Placeholder | Description |
|-------------|-------------|
| `{{DEPENDENCIES}}` | Plan dependencies |
| `{{PLAN_FILENAME}}` | The plan's filename |
| `{{OBJECTIVE_DESCRIPTION}}` | What the plan accomplishes |
| `{{STEP_TITLE}}` | Title for each step |
| `{{STEP_DETAILS}}` | Detailed instructions |
| `{{FILE_PATH}}` | Path to file being modified |

## License

MIT

## Author

Djalma Araujo
