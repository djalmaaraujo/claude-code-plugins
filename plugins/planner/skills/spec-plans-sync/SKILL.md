---
name: spec-plans-sync
description: Synchronize plans from a spec file. Reads the spec, generates or updates related plans, marks deprecated plans, and updates the spec's Milestones section. Use when user changes a spec and wants to regenerate plans.
allowed-tools: Task, TaskOutput, Read, Write, Edit, Glob, Grep, AskUserQuestion
user-invocable: true
agent: plan-creator
---

# Sync Plans from Spec

You are now executing the spec-plans-sync skill. Follow these steps immediately:

**Agent Reference**: This skill uses the plan-creator agent (@agents/plan-creator.md) to generate plans from the spec.

**Template Reference**: The default plan template is available at @templates/plan.TEMPLATE.md

**Standards Reference**: Convention files are available at @templates/standards/

## Step 1: Parse Arguments and Get Prefix

1. **Check if prefix provided in arguments**: Look for prefix in $ARGUMENTS
2. **If prefix found**: Store it and continue
3. **If not provided**:
   - Use Glob to find all `plans/*-spec.md` files
   - If multiple found, use AskUserQuestion to select
   - If only one found, use that prefix
   - If none found, show error

```
Question: "Which spec would you like to sync plans from?"
Header: "Spec"
Options: [
  "[prefix1]-spec.md (5 existing plans)",
  "[prefix2]-spec.md (3 existing plans)",
  "[prefix3]-spec.md (no plans yet)",
  "Other"
]
multiSelect: false
```

## Step 2: Verify Spec Exists

1. Check if `plans/[prefix]-spec.md` exists
2. If not found, display error:

```
════════════════════════════════════════
Spec Not Found

No spec file found at: plans/[prefix]-spec.md

To create a spec first, run:
  /planner:spec-create [prefix] "[description]"

Available specs:
- checkout-spec.md
- user-spec.md
════════════════════════════════════════
```

## Step 3: Read Spec Content

1. **Read the spec file**: Read `plans/[prefix]-spec.md`
2. **Extract key sections**:
   - Functional Requirements (Section 3)
   - Use Cases (Section 3.3)
   - Feature Descriptions (Section 3.2)
   - Technical Details (Section 5)
   - Assumptions & Dependencies (Section 6.1)
3. **Store for plan generation context**

## Step 4: Find Existing Plans

1. Use Glob: `plans/[prefix]-*.plan.md` (only plan files with .plan.md suffix)
2. For each plan found:
   - Read plan content
   - Extract objective
   - Store plan filename and summary
3. **Store existing plans list** for comparison

## Step 5: Read Configuration

Read `plans/planner.config.json`:
- `smart_parallelism`: boolean (default: false)
- `spec_verbose`: boolean (default: false)

## Step 6: Detect Plan Template

1. Check if `plans/plan.TEMPLATE.md` exists
   - If found: `template_source = "project"`, read content using Read tool
   - If not: Read plugin's default template `templates/plan.TEMPLATE.md`, `template_source = "default"`

## Step 7: Analyze Required Plans

Based on the spec content, determine:

1. **Plans to create**: New plans needed based on spec requirements
2. **Plans to keep**: Existing plans that still align with spec
3. **Plans to deprecate**: Existing plans no longer in spec scope

Use AskUserQuestion to confirm deprecation:

```
Question: "The following plans are no longer referenced in the spec. How should they be handled?"
Header: "Deprecated"
Options: [
  "Mark as DEPRECATED in PROGRESS.md (Recommended)",
  "Keep as-is (no changes)",
  "Delete plan files"
]
multiSelect: false
```

## Step 8: Spawn Plan-Creator Agent

**CRITICAL: You MUST spawn the plan-creator agent now using the Task tool.**

This is NOT optional - the agent performs the actual plan creation work.

Use the Task tool with these exact parameters:

```
Task tool parameters:
  description: "Generate plans from spec: [prefix]"
  subagent_type: "planner:plan-creator"
  prompt: |
    description: |
      Generate implementation plans based on this specification.

      SPEC CONTENT:
      [Full spec content from Step 3]

    prefix: "[prefix]"

    smart_parallelism: [true/false]

    template_source: [project/default]
    template_content: |
      [TEMPLATE CONTENT IF FROM PROJECT]

    existing_plans:
    [LIST OF EXISTING PLAN FILES TO KEEP]

    plans_to_create:
    [LIST OF PLANS IDENTIFIED IN STEP 7]

    IMPORTANT:
    - Create plans based on spec requirements
    - Each plan should cover one logical unit of work
    - Reference the spec in plan objectives
    - Maintain existing plan naming patterns where possible
    - Use ~40% context per plan

    BEGIN PLAN CREATION.
```

**Important**: Do NOT just analyze the spec - you MUST call the Task tool to spawn the agent.

## Step 9: Handle Deprecated Plans

Based on user selection in Step 7:

**If "Mark as DEPRECATED"**:
1. For each deprecated plan:
   - Read `plans/PROGRESS.md`
   - Change status from current to `DEPRECATED`
   - Add note: `(deprecated - not in current spec)`

**If "Delete plan files"**:
1. For each deprecated plan:
   - Delete the plan file
   - Remove from PROGRESS.md

**If "Keep as-is"**:
- No changes to deprecated plans

## Step 10: Update Spec Milestones Section

Update Section 6.2 (Milestones) in the spec file with the current plan list:

1. Read the spec file
2. Find Section 6.2 (Milestones)
3. Replace content with:

```markdown
### 6.2 Milestones (Plans)

<!-- Auto-generated by spec-plans-sync -->
<!-- Last synced: [ISO date] -->

| Plan | Description | Status |
|------|-------------|--------|
| [prefix]-001-setup.md | [objective from plan] | NOT STARTED |
| [prefix]-002-models.md | [objective from plan] | NOT STARTED |
| [prefix]-003-api.md | [objective from plan] | NOT STARTED |

**Execution Order**:
- Round 1 (parallel): [plans with no deps]
- Round 2: [plans depending on Round 1]
- Round 3: [plans depending on Round 2]
```

4. Write updated spec back

## Step 11: Report Results

Display sync summary:

```
════════════════════════════════════════
Spec-Plans Sync Complete

Spec: plans/[prefix]-spec.md
Synced: [timestamp]

Plans Summary:
- Created: [N] new plans
- Kept: [M] existing plans
- Deprecated: [X] plans

New Plans:
- [prefix]-001-setup.md
- [prefix]-002-models.md
- [prefix]-003-api.md

Deprecated Plans:
- [prefix]-old-feature.md → DEPRECATED

Spec Updated:
- Section 6.2 (Milestones) now lists [total] plans

Execution Order:
Round 1 (parallel): [list]
Round 2: [list]
Round 3: [list]

Next Steps:
1. Review plans in plans/[prefix]-*.md
2. Execute: /planner:batch --prefix=[prefix]
3. Or execute one: /planner:exec [prefix]-001-setup.md

To re-sync after spec changes:
  /planner:spec-plans-sync [prefix]
════════════════════════════════════════
```

---

## Reference Information

### What This Skill Does

This skill synchronizes plans with a spec:

1. **Reads Spec**: Parses the spec file for requirements
2. **Finds Existing Plans**: Checks what plans already exist
3. **Compares**: Identifies new, keep, and deprecated plans
4. **Generates Plans**: Uses plan-creator agent for new plans
5. **Handles Deprecation**: Marks or deletes outdated plans
6. **Updates Spec**: Syncs Milestones section with plan list

### Sync Behavior

| Scenario | Action |
|----------|--------|
| New requirement in spec | Create new plan |
| Existing plan matches spec | Keep plan |
| Existing plan not in spec | Mark as deprecated |
| Spec section removed | Related plans deprecated |

### Bi-directional Sync

**Spec → Plans**: This skill generates plans from spec
**Plans → Spec**: This skill updates spec's Milestones section

The Milestones section becomes a live reference of all related plans.

### Deprecation Handling

Plans are deprecated (not deleted by default) because:
- They may contain valuable implementation notes
- They can be referenced for historical context
- They can be un-deprecated if needed

### Example

```
User: /planner:spec-plans-sync auth

Step 1: Parse arguments
→ Prefix: auth

Step 2: Verify spec
→ Found: plans/auth-spec.md

Step 3: Read spec
→ Extracted requirements for:
  - User login
  - JWT token management
  - Session handling
  - Password reset

Step 4: Find existing plans
→ Found: auth-001-setup.md, auth-002-old-oauth.md

Step 5: Read config
→ smart_parallelism: true

Step 7: Analyze
→ Keep: auth-001-setup.md (matches spec)
→ Create: auth-002-jwt.md, auth-003-session.md, auth-004-password-reset.md
→ Deprecate: auth-002-old-oauth.md (not in spec)

Step 8: Create new plans
→ Created 3 new plans

Step 9: Handle deprecated
→ Marked auth-002-old-oauth.md as DEPRECATED

Step 10: Update spec
→ Section 6.2 now lists 4 plans

Step 11: Report
→ Sync complete!
```
