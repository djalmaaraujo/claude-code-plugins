---
name: planner-create
description: Create implementation plan files with dependency analysis and parallel execution support. Breaks down complex features into multiple self-contained plans with proper dependency tracking. Use when user wants to create plans, break down features, or plan implementation.
allowed-tools: Task, TaskOutput, Read, Write, Edit, Glob, Grep
user-invocable: true
---

# Create Plans

You are now executing the planner-create skill. Follow these steps immediately:

## Step 1: Read Smart Parallelism Configuration

Read the user's project configuration to understand the plan creation strategy:

1. **Read configuration file**: Read `plans/planner.config.json`

   - If successful and valid JSON:
     - Parse: `smart_parallelism`
     - Store the value and proceed to Step 2

2. **Use default**: If file not found or invalid:
   - `smart_parallelism = false`

**This affects dependency creation:**

- `true`: Aggressive parallelization (fewer dependencies, more parallel plans)
- `false`: Conservative dependencies (safer sequential execution)

## Step 2: Detect Plan Template

Check for a plan template to ensure consistent plan structure:

1. **Check user's project first**: Use Glob to check if `plans/task.TEMPLATE.md` exists
   - If found: Read and store as `template_content`
   - Set `template_source = "project"`

2. **Fall back to plugin default**: If not found in project:
   - The default template is built into the plan-creator agent
   - Set `template_source = "default"`

3. **Check for convention files**: Use Glob to check if `plans/standards/*.md` exists
   - If found: Store paths as `convention_files`
   - If not found: Agent will use built-in conventions

**Template affects plan structure:**
- Plans will follow the template's section structure
- Placeholders (`{{PLACEHOLDER}}`) guide content placement
- Convention `@mentions` are preserved for reference

## Step 3: Analyze Existing Plans

Understand the current project structure:

1. Use Glob: `plans/*.md` (exclude PROGRESS.md, example.md, task.TEMPLATE.md)
2. Store as `existing_plans` for context
3. Detect naming conventions:
   - Prefix patterns (e.g., "auth-", "api-")
   - Numbering schemes (e.g., "01-", "02-")
   - Naming styles (e.g., kebab-case, descriptive names)

## Step 4: Spawn Plan-Creator Agent

Use the Task tool to spawn the plan-creator agent:

```
Task tool:
  description: "Create plans for: [short summary]"
  subagent_type: "planner:plan-creator"
  prompt: |
    description: "[user's full feature description]"
    prefix: "[provided prefix or inferred from description]"

    smart_parallelism: [true/false from Step 1]

    template_source: [project/default]
    template_content: |
      [TEMPLATE CONTENT IF FROM PROJECT, OR "use built-in default"]

    convention_files:
      [LIST OF CONVENTION FILE PATHS, OR "use built-in conventions"]

    existing_plans:
    [LIST OF EXISTING PLAN FILES]

    naming_conventions:
    [DETECTED PATTERNS FROM EXISTING PLANS]

    IMPORTANT: Follow the template structure when creating plans.
    Include @mentions to convention files in the Standards section.

    BEGIN CREATION.
```

## Step 5: Report Results

After the agent completes, show the creation result:

```
════════════════════════════════════════
Plans Created Successfully

Feature: [feature description]
Prefix: [prefix used]
Plans created: [N]
Template: [project custom / plugin default]

Plan Execution Order:
Round 1 (parallel): [list of independent plans]
Round 2: [plans depending on Round 1]
Round 3: [plans depending on Round 2]
...

Files created:
- plans/[plan-01].md
- plans/[plan-02].md
- plans/[plan-03].md
- Updated plans/PROGRESS.md

To execute:
  /planner:batch --prefix=[prefix]
  OR
  /planner:batch [plan-01].md [plan-02].md ...

Smart Parallelism: [enabled/disabled]
════════════════════════════════════════
```

**If extra sections were needed:**

```
Note: The following sections were added beyond the template:
- [section name]: [reason]
```

---

## Reference Information

### What This Skill Does

When creating plans for a feature, this skill:

1. **Reads Configuration**: Gets smart parallelism setting from `plans/planner.config.json`
2. **Detects Templates**: Checks for custom template or uses plugin default
3. **Analyzes Requirements**: Breaks down the feature into manageable plans
4. **Creates Plan Files**: Each plan is self-contained (~40% context usage)
5. **Determines Dependencies**: Identifies sequential vs. parallel execution needs
6. **Updates Tracking**: Adds new plans to `plans/PROGRESS.md`

### Key Features

- **Template Support**: Uses project template or plugin default for consistent structure
- **Convention References**: Includes @mentions to coding standards
- **Smart Breakdown**: Splits complex features into small, focused plans
- **Dependency Analysis**: Identifies which plans must run sequentially vs. in parallel
- **Context Optimization**: Each plan uses ~40% context to leave room for implementation
- **Naming Conventions**: Follows existing project patterns or creates sensible defaults
- **Automatic Tracking**: Updates PROGRESS.md with all new plans
- **Configurable Strategy**: Uses smart parallelism setting for dependency decisions

### Template System

The planner uses a template system for consistent plan creation:

**Project Template** (`plans/task.TEMPLATE.md`):
- Custom template for your project
- Created via `/planner:eject-template plan`
- Takes priority over plugin default

**Plugin Default Template**:
- Built into the plan-creator agent
- Used when no project template exists
- Includes all standard sections

**Convention Files** (`plans/standards/*.md`):
- Referenced via `@templates/standards/[name].md`
- Provide coding standards and best practices
- Can be customized per project

### Smart Parallelism

The `smart_parallelism` setting in `plans/planner.config.json` affects how aggressively plans are parallelized:

**When `true` (Aggressive):**

- Minimizes dependencies
- Maximizes parallel execution
- Faster overall execution
- Requires careful conflict management

**When `false` (Conservative):**

- More sequential dependencies
- Safer execution order
- Slower but more predictable
- Better for complex interdependencies

### Plan Structure

Each created plan follows the template structure and includes:

```markdown
# Configuration

depends_on: "prefix-00-setup.md"

# Plan: prefix-01-database.md

## Objective

[What this plan accomplishes]

## Context

[Relevant codebase context]

## Implementation Steps

### Step 1: [Title]
[Details]

## Files to Modify

| File | Action | Description |
|------|--------|-------------|

## Standards & Conventions

@templates/standards/coding-style.md
@templates/standards/error-handling.md

## Testing Instructions

[How to verify the changes work]

## Completion

Update plans/PROGRESS.md to mark this plan as COMPLETED.
```

### Example

```
User: Create plans for user authentication with JWT

Step 1: Read smart_parallelism
→ Found: smart_parallelism: true

Step 2: Detect template
→ Found: plans/task.TEMPLATE.md (project custom)
→ Found: plans/standards/*.md (8 convention files)

Step 3: Analyze existing plans
→ Found naming pattern: "feature-NN-name.md"
→ Detected numbering scheme: 00, 01, 02, etc.

Step 4: Spawn plan-creator agent
→ Passes config, description, template, and conventions

Agent creates:
→ auth-00-setup.md (no deps)
→ auth-01-database.md (depends on: 00)
→ auth-02-jwt-service.md (depends on: 01)
→ auth-03-api.md (depends on: 02)
→ auth-04-tests.md (no deps - can run in parallel)

Updates PROGRESS.md:
→ Added 5 new plans

Report:
→ Round 1: auth-00-setup.md, auth-04-tests.md
→ Round 2: auth-01-database.md
→ Round 3: auth-02-jwt-service.md
→ Round 4: auth-03-api.md

Suggested command: /planner:batch --prefix=auth
```
