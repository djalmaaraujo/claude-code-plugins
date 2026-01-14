# Planner Plugin for Claude Code

Sub-agent-based plan execution system with specification workflow, automatic dependency resolution, parallelism, and safety checks.

## Features

- ✅ **Specification workflow** - Create detailed specs before generating plans
- ✅ **Plan creation** - Break down complex features into manageable plans
- ✅ **Dependency resolution** - Automatic ordering based on plan dependencies
- ✅ **Parallel execution** - Run independent plans simultaneously
- ✅ **Progress tracking** - PROGRESS.md tracks all plan statuses
- ✅ **Safety checks** - Validates dependencies before execution
- ✅ **Configuration options** - Auto-commit, CLAUDE.md updates, and more
- ✅ **Linear integration** - Sync specs and plans with Linear projects

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

### Non-Opinionated: Your Workflow, Your Way

The planner doesn't force you into a rigid structure. **It adapts to how you and your team already work.**

Unlike verbose enterprise solutions that require you to learn their methodology, the planner gives you a simple template that you can customize entirely:

```
/planner:planner-eject-template plan
```

Once ejected, the template is yours:

- **Change the structure**: Add sections your team needs, remove what you don't
- **Match your conventions**: Use your naming patterns, your checklist items, your standards
- **Integrate with your tools**: Add Linear issue links, custom fields, whatever fits your workflow
- **Keep it minimal**: The default template is lean - no bloated requirements docs

**The goal is simple**: plug the planner into your project and start shipping. No training required, no workflow changes, no lengthy setup processes.

What you get in return:
- **Higher quality execution**: Each plan gets Claude's full attention
- **Better documentation**: Plans become living docs that match your style
- **Faster iteration**: Small plans = faster feedback loops
- **Team alignment**: Everyone follows the same template

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

## Dependencies

### Linear Integration (Optional)

The planner includes Linear integration features that allow you to:
- Create Linear projects from specs (`/planner:linear-project-create`)
- Create milestones within projects (`/planner:linear-milestone-create`)
- Create Linear issues from plan files (`/planner:linear-issue-create`)

**Requirements:**
To use these features, you must have the [Linear MCP server](https://github.com/modelcontextprotocol/servers/tree/main/src/linear) installed and configured in your Claude Code setup.

If you don't need Linear integration, you can use all other planner features without installing the Linear MCP server.

### Slack Plugin (Separate Plugin)

This marketplace also includes a Slack plugin for sending messages and searching users.

**Requirements:**
To use the Slack plugin (`/slack:slack-send-message`, `/slack:slack-search-user`), you need to:
1. Run `/slack:slack-setup` to configure credentials
2. Provide your Slack workspace token and cookie from your browser session

The Slack plugin is completely separate from the planner and is optional.

## Quick Start

### 1. Initialize Planner

```
/planner:planner-setup
```

This interactively asks 6 configuration questions:
1. **Auto-commit** - Commit after successful plan execution?
2. **CLAUDE.md updates** - Auto-update project documentation?
3. **Parallelism** - Aggressive or conservative dependency handling?
4. **Re-plan** - Re-analyze plans before execution?
5. **Use Specs** - Enable specification workflow?
6. **Spec Verbosity** - Maximum inference or interactive mode?

Then creates the `plans/` directory, `PROGRESS.md` tracking file, and `planner.config.json`.

### 2. Create a Spec (Optional but Recommended)

```
/planner:spec-create auth "User authentication with JWT tokens"
```

This creates a comprehensive specification file (`plans/auth-spec.md`) with:
- Purpose, goals, and scope
- Functional and non-functional requirements
- Technical design and data models
- Implementation logistics

The spec-creator agent deeply analyzes your codebase to infer context automatically.

### 3. Generate Plans from Spec

```
/planner:spec-plans-sync auth
```

This reads the spec and generates plan files with proper dependencies. It also:
- Marks deprecated plans if the spec changed
- Updates the spec's Milestones section with the plan list

### 4. Or Create Plans Directly

```
/planner:planner-create Add user authentication feature
```

This breaks down the feature into multiple plan files with proper dependencies (skipping the spec step).

### 5. Check Status

```
/planner:planner-status
```

Shows specs (DRAFT/ACTIVE/DEPRECATED), progress bar, completed plans, in-progress plans, and suggested next actions.

### 6. Execute Plans

**Single plan:**
```
/planner:planner-exec plans/auth-001-setup.md
```

**All plans (with dependency resolution):**
```
/planner:planner-batch --prefix=auth
```

## Specification Workflow

Specs are optional but provide significant benefits for complex features.

### Why Use Specs?

| Without Spec | With Spec |
|--------------|-----------|
| Jump straight to implementation | Document requirements first |
| Easy to miss edge cases | Comprehensive coverage |
| Hard to review before coding | Review spec before any code |
| Plans may drift from intent | Plans always align with spec |
| No central reference | Single source of truth |

### Spec Lifecycle

```
DRAFT ──────▶ ACTIVE ──────▶ DEPRECATED
  │              │               │
  │              │               │
  ▼              ▼               ▼
Review &      Generate        Superseded
 Refine        Plans          by new spec
```

### Spec File Structure

Specs follow a comprehensive 7-section template:

1. **Front Matter** - Title, version, author, revision history
2. **Introduction & Overview** - Purpose, goals, scope, audience
3. **Functional Requirements** - User stories, features, use cases
4. **Non-Functional Requirements** - Performance, security, scalability
5. **Design & Technical Details** - Architecture, APIs, data models
6. **Implementation & Logistics** - Assumptions, milestones, deployment
7. **Appendix** - Supporting documents, research

### Spec Commands

| Command | Description |
|---------|-------------|
| `/planner:spec-create [prefix] "[description]"` | Create a new spec |
| `/planner:spec-plans-sync [prefix]` | Generate/sync plans from spec |
| `/planner:planner-eject-template spec` | Export spec template for customization |

### Maximum Inference Mode

By default (`spec_verbose: false`), the spec-creator agent:
- Deeply analyzes your codebase, README, and existing patterns
- Infers everything possible without asking questions
- Only prompts when truly ambiguous

Enable `spec_verbose: true` in config for more interactive spec creation.

## Available Slash Commands

### Spec Commands

| Command | Description |
|---------|-------------|
| `/planner:spec-create` | Create a specification file |
| `/planner:spec-plans-sync` | Generate/sync plans from a spec |

### Plan Commands

| Command | Description |
|---------|-------------|
| `/planner:planner-setup` | Initialize planner in a project |
| `/planner:planner-create` | Create plan files for a feature |
| `/planner:planner-status` | Show overview of specs and plans |
| `/planner:planner-exec` | Execute a single plan file |
| `/planner:planner-batch` | Execute multiple plans with dependency resolution |
| `/planner:planner-eject-template` | Export plan or spec template for customization |

## Directory Structure

After setup, your project will have:

```
project/
├── plans/
│   ├── PROGRESS.md           # Status tracking
│   ├── planner.config.json   # Configuration
│   ├── auth-spec.md          # Spec file (if using specs)
│   ├── auth-001-setup.md     # Plan files
│   ├── auth-002-models.md
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
  "version": "2.0.0",
  "auto_commit": true,
  "auto_update_claude_md": false,
  "smart_parallelism": true,
  "replan_on_exec": false,
  "uses_spec": true,
  "spec_verbose": false
}
```

| Option | Description |
|--------|-------------|
| **auto_commit** | Automatically commit after each successful plan execution |
| **auto_update_claude_md** | Update project `.claude/CLAUDE.md` when code changes make docs inaccurate |
| **smart_parallelism** | Aggressive (more parallel) vs conservative (more sequential) dependency handling |
| **replan_on_exec** | Re-analyze and draft fresh implementation outline before executing |
| **uses_spec** | Enable specification workflow (create specs before plans) |
| **spec_verbose** | Interactive mode (more questions) vs maximum inference (infer from codebase) |

## Template Customization

Customize how plans or specs are generated by ejecting the default templates:

**For plans:**
```
/planner:planner-eject-template plan
```

Creates:
- `plans/plan.TEMPLATE.md` - Plan template with `{{PLACEHOLDER}}` syntax
- `plans/standards/` - Convention files referenced by plans

**For specs:**
```
/planner:planner-eject-template spec
```

Creates:
- `plans/spec.TEMPLATE.md` - Spec template with 7 comprehensive sections
- `plans/standards/` - Convention files (if not already created)

Templates use `{{PLACEHOLDER}}` syntax that the creator agents replace with actual content. Edit ejected templates to match your project's conventions.

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
