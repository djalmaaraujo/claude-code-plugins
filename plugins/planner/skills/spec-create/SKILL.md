---
name: spec-create
description: Create a comprehensive specification file with deep codebase analysis. Generates detailed requirements, technical designs, and implementation logistics. The spec serves as the source of truth for related plans.
allowed-tools: Task, TaskOutput, Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
user-invocable: true
---

# Create Spec

You are now executing the spec-create skill. Follow these steps immediately:

## Step 0: Check Spec Configuration

First, verify that specs are enabled:

1. **Read configuration file**: Read `plans/planner.config.json`

   - If file exists and valid JSON:
     - Check if `uses_spec` field exists
     - If `uses_spec: false` or missing, proceed to Step 0b
     - If `uses_spec: true`, proceed to Step 1
     - Also read `spec_verbose` (default: false)

   - If file doesn't exist:
     - Proceed to Step 0b

## Step 0b: Prompt to Enable Specs

If specs are not enabled, use AskUserQuestion:

```
Question: "Specs are not enabled in your planner configuration. Would you like to enable them?"
Header: "Enable Specs"
Options: [
  "Yes - Enable specs (Recommended)",
  "No - Cancel spec creation"
]
multiSelect: false
```

**If "Yes"**:
1. Read `plans/planner.config.json`
2. Add `"uses_spec": true` and `"spec_verbose": false` to the config
3. Write updated config back
4. Continue to Step 1

**If "No"**:
Display message and exit:
```
════════════════════════════════════════
Spec Creation Cancelled

To enable specs later, either:
1. Run /planner:setup and answer the spec questions
2. Edit plans/planner.config.json and add:
   "uses_spec": true,
   "spec_verbose": false
════════════════════════════════════════
```

## Step 1: Parse Arguments and Get Prefix

1. **Check if prefix provided in arguments**: Look for prefix in $ARGUMENTS
2. **If prefix found**: Store it and continue to Step 2
3. **If not provided, use AskUserQuestion**:

```
Question: "What prefix should be used for this spec? (e.g., 'auth', 'checkout', 'user-mgmt')"
Header: "Prefix"
Options: [
  "[suggested prefix based on description]",
  "Other"
]
multiSelect: false
```

4. **Store the prefix** for file naming

## Step 2: Check for Existing Spec

1. **Use Glob to check**: `plans/[prefix]-spec.md`
2. **If spec exists, use AskUserQuestion**:

```
Question: "A spec already exists for prefix '[prefix]'. What would you like to do?"
Header: "Existing Spec"
Options: [
  "Update existing spec",
  "Cancel - keep existing spec"
]
multiSelect: false
```

3. **If "Cancel"**: Exit with message
4. **If "Update"**: Continue (will update existing spec)

## Step 3: Get Project Context

Gather codebase information to pass to the agent:

1. **Get git author**:
   ```bash
   git config user.name
   ```

2. **Detect project type**:
   - Check for package.json, Cargo.toml, go.mod, requirements.txt
   - Store detected type and technologies

3. **Read existing documentation**:
   - README.md (if exists)
   - .claude/CLAUDE.md (if exists)
   - Summarize key points

4. **Analyze project structure**:
   - Use Glob to understand directory layout
   - Identify patterns (src/, app/, lib/, etc.)

Store all findings as `project_context`.

## Step 4: Read Configuration Settings

From `plans/planner.config.json`:
- `spec_verbose`: boolean (default: false)

**This affects question frequency:**
- `true`: Agent asks more clarifying questions
- `false`: Agent maximizes inference from codebase

## Step 5: Detect Spec Template

Check for a spec template to ensure consistent structure:

1. **Check user's project first**: Use Glob to check if `plans/spec.TEMPLATE.md` exists
   - If found: Read and store as `template_content`
   - Set `template_source = "project"`

2. **Fall back to plugin default**: If not found in project:
   - The default template is built into the spec-creator agent
   - Set `template_source = "default"`

## Step 6: Find Existing Specs

1. Use Glob: `plans/*-spec.md`
2. Store as `existing_specs` for context
3. This helps the agent understand existing spec patterns

## Step 7: Spawn Spec-Creator Agent

Use the Task tool to spawn the spec-creator agent:

```
Task tool:
  description: "Create spec for: [short summary]"
  subagent_type: "planner:spec-creator"
  prompt: |
    description: "[user's full feature description from $ARGUMENTS]"
    prefix: "[prefix from Step 1]"

    spec_verbose: [true/false from Step 4]

    template_source: [project/default]
    template_content: |
      [TEMPLATE CONTENT IF FROM PROJECT, OR "use built-in default"]

    existing_specs:
    [LIST OF EXISTING SPEC FILES]

    author: "[git username from Step 3]"

    project_context: |
      [PROJECT CONTEXT FROM STEP 3]
      - Project type: [detected type]
      - Technologies: [detected technologies]
      - README summary: [key points]
      - Structure: [directory patterns]

    IMPORTANT:
    - Analyze the codebase DEEPLY before writing
    - MAXIMIZE INFERENCE - only ask if truly necessary or spec_verbose is true
    - Follow the template structure exactly
    - Create comprehensive, detailed content

    BEGIN SPEC CREATION.
```

## Step 8: Report Results

After the agent completes, show the creation result:

```
════════════════════════════════════════
Spec Created Successfully

Spec: plans/[prefix]-spec.md
Title: [spec title]
Status: DRAFT

Configuration:
- Verbose Mode: [enabled/disabled]
- Template: [project custom / plugin default]

Codebase Analysis Performed:
- Project type: [detected type]
- Technologies: [technologies found]

Next Steps:
1. Review the spec: Open plans/[prefix]-spec.md
2. Update status to ACTIVE when approved
3. Generate plans from spec:
   /planner:spec-plans-sync [prefix]
   OR
   /planner:create "implement [prefix]-spec.md"

To change verbose mode:
Edit plans/planner.config.json → "spec_verbose": true/false
════════════════════════════════════════
```

---

## Reference Information

### What This Skill Does

When creating a spec, this skill:

1. **Verifies Configuration**: Checks if specs are enabled, prompts to enable if not
2. **Gets Prefix**: From arguments or prompts user
3. **Checks Existing**: Handles existing spec for same prefix
4. **Gathers Context**: Deep codebase analysis for agent
5. **Detects Template**: Uses custom or default template
6. **Spawns Agent**: Spec-creator agent does the heavy lifting
7. **Reports Results**: Shows what was created and next steps

### Spec vs Plan

| Aspect | Spec | Plan |
|--------|------|------|
| Purpose | Define WHAT to build | Define HOW to build |
| Content | Requirements, designs | Implementation steps |
| Granularity | Feature-level | Task-level |
| Lifecycle | DRAFT → ACTIVE → DEPRECATED | NOT STARTED → IN PROGRESS → COMPLETED |
| File naming | prefix-spec.md | prefix-001-taskname.md |

### Configuration Options

**uses_spec** (boolean):
- `true`: Spec workflow enabled
- `false`: Traditional plan-only workflow

**spec_verbose** (boolean):
- `true`: Agent asks more clarifying questions
- `false`: Agent maximizes inference (recommended)

### Template System

**Project Template** (`plans/spec.TEMPLATE.md`):
- Custom template for your project
- Created via `/planner:eject-template spec`
- Takes priority over plugin default

**Plugin Default Template**:
- Built into the spec-creator agent
- Used when no project template exists
- Comprehensive 7-section structure

### Example

```
User: /planner:spec-create auth "User authentication with JWT"

Step 0: Check configuration
→ Found uses_spec: true
→ Found spec_verbose: false

Step 1: Parse arguments
→ Prefix: auth
→ Description: "User authentication with JWT"

Step 2: Check existing
→ No existing auth-spec.md

Step 3: Get project context
→ Author: "John Doe"
→ Project type: Node.js + TypeScript
→ README: API server with Express

Step 4: Read settings
→ spec_verbose: false (maximize inference)

Step 5: Detect template
→ No project template, using default

Step 6: Find existing specs
→ Found: checkout-spec.md, user-spec.md

Step 7: Spawn spec-creator agent
→ Agent analyzes codebase deeply
→ Agent creates plans/auth-spec.md
→ Agent updates PROGRESS.md

Step 8: Report results
→ Spec created: plans/auth-spec.md
→ Status: DRAFT
```
