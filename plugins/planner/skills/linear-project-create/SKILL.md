---
name: linear-project-create
description: Create a Linear project from a set of plans with a specific prefix. Generates a comprehensive project spec from all related plans, creates the project in Linear, and optionally creates issues for each plan. Use when user wants to sync plans to a Linear project.
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, mcp__linear-server__list_teams, mcp__linear-server__list_projects, mcp__linear-server__create_project, mcp__linear-server__create_issue, mcp__linear-server__get_project, mcp__linear-server__get_issue
user-invocable: true
---

# Create Linear Project from Plans

You are now executing the linear-project-create skill. Follow these steps immediately:

## Step 1: Verify Linear MCP Installation

Before proceeding, verify the Linear MCP server is available:

1. **Attempt to list teams**: Call `mcp__linear-server__list_teams`
2. **If successful**: Store teams list and proceed to Step 2
3. **If fails or unavailable**: Display error and exit:

```
════════════════════════════════════════
Linear MCP Not Available

The Linear MCP server (linear-server) is not installed or not configured.

To use Linear integration features:
1. Install the Linear MCP server
2. Configure your Linear API credentials
3. Restart Claude Code

For installation instructions, see:
https://github.com/anthropics/linear-mcp
════════════════════════════════════════
```

## Step 2: Get Plan Prefix

1. **Check if prefix provided in arguments**: Look for prefix in $ARGUMENTS
2. **If not provided, use AskUserQuestion**:

```
Question: "What is the plan prefix you want to create a project for? (e.g., 'auth', 'appt', 'checkout')"
Header: "Prefix"
Options: [detected prefixes from PROGRESS.md if any, plus "Other" option]
multiSelect: false
```

3. **Store the prefix** for filtering plans

## Step 3: Find Related Plans

1. **Read PROGRESS.md**: Read `plans/PROGRESS.md`
2. **Find matching section**: Look for table containing plans with the prefix
3. **Extract plan filenames**: Get all plans matching `[prefix]-*.md` pattern
4. **Verify files exist**: Use Glob to confirm `plans/[prefix]-*.md` files exist

If no plans found:

```
════════════════════════════════════════
No Plans Found

No plans found with prefix "[prefix]" in plans/PROGRESS.md.

Available prefixes detected:
- auth (5 plans)
- api (3 plans)

To create plans first, run:
  /planner:create "your feature description"
════════════════════════════════════════
```

## Step 4: Read All Plan Contents

For each plan file matching the prefix:

1. **Read the plan file**: Read `plans/[prefix]-NN-name.md`
2. **Extract key sections**:
   - **Objective**: What the plan accomplishes
   - **Steps**: Implementation steps
   - **Files to Modify**: Affected files
   - **Testing**: How to verify changes
3. **Store content** for spec generation

## Step 5: Generate Project Spec

Create a comprehensive project description by synthesizing all plan contents:

```markdown
## Overview

[Synthesized summary of what this feature does based on all plan objectives]

## Business Logic

[Combined business logic from all plan objectives, organized logically]

## Implementation Steps

### Phase 1: [First plan name]
[Steps from first plan]

### Phase 2: [Second plan name]
[Steps from second plan]

... [continue for all plans]

## Files Affected

[Combined unique list of all files from all plans]
- path/to/file1.ts: [description]
- path/to/file2.ts: [description]

## Testing Guide

### [First plan name]
[Testing instructions]

### [Second plan name]
[Testing instructions]

... [continue for all plans]

## Plan Dependencies

[Execution order based on plan dependencies]
- Round 1 (parallel): plan-00, plan-04
- Round 2: plan-01 (depends on 00)
- Round 3: plan-02 (depends on 01)
```

## Step 6: Get Team Selection

1. **Use teams from Step 1** (already fetched)
2. **Use AskUserQuestion** for team selection:

```
Question: "Which team should this project be created in?"
Header: "Team"
Options: [list of team names]
multiSelect: false
```

3. **Store selected team ID**

## Step 7: Get Project Name

1. **Suggest a name** based on the prefix (e.g., "Auth Implementation", "Appointment System")
2. **Use AskUserQuestion**:

```
Question: "What should the project be named?"
Header: "Name"
Options: ["[Suggested Name] (Recommended)", "Use prefix: [prefix]", "Other"]
multiSelect: false
```

3. **Store project name**

## Step 8: Create Project in Linear

1. **Create the project**:
   ```
   mcp__linear-server__create_project:
     name: [project name]
     description: [generated spec from Step 5]
     team: [selected team ID]
   ```
2. **Get project details**: Extract project ID and URL from response
3. **Store project URL** for plan updates

## Step 9: Ask About Issue Creation

1. **Use AskUserQuestion**:

```
Question: "Would you like to create Linear issues for each plan in this project?"
Header: "Issues"
Options: [
  "Yes - Create issues for all plans (Recommended)",
  "No - Project only"
]
multiSelect: false
```

2. **If "No"**: Skip to Step 11
3. **If "Yes"**: Continue to Step 10

## Step 10: Create Issues for Each Plan

For each plan file:

1. **Read plan content** (already in memory from Step 4)
2. **Create issue**:
   ```
   mcp__linear-server__create_issue:
     title: [plan filename without .md, e.g., "auth-01-database"]
     description: [full plan content as markdown]
     team: [selected team ID]
     project: [project ID from Step 8]
   ```
3. **Get issue URL** from response
4. **Store issue URL** for plan file update

## Step 11: Update All Plan Files

For each plan file:

1. **Read the plan file** if needed
2. **Find the `# Configuration` section**
3. **Add linear_project and linear_issue fields**:

**Before:**
```markdown
# Configuration

depends_on: "auth-00-setup.md"

# Plan: auth-01-database.md
```

**After:**
```markdown
# Configuration

depends_on: "auth-00-setup.md"
linear_project: https://linear.app/team/project/PROJECT-ID
linear_issue: https://linear.app/team/issue/AUTH-123

# Plan: auth-01-database.md
```

4. **Write updated content** back to file

## Step 12: Report Results

Display creation summary:

```
════════════════════════════════════════
Linear Project Created Successfully

Project: [project name]
URL: https://linear.app/team/project/PROJECT-ID
Team: [team name]
Plans included: [N]

[If issues created:]
Issues Created: [N]

Plan → Issue Mapping:
- auth-00-setup.md → AUTH-100
  https://linear.app/team/issue/AUTH-100
- auth-01-database.md → AUTH-101
  https://linear.app/team/issue/AUTH-101
- auth-02-api.md → AUTH-102
  https://linear.app/team/issue/AUTH-102

[End if]

Plan files updated with:
- linear_project: [project URL]
[If issues:] - linear_issue: [individual issue URLs]

View project: https://linear.app/team/project/PROJECT-ID
════════════════════════════════════════
```

---

## Reference Information

### What This Skill Does

This skill creates a Linear project from a set of related plans:

1. **Validates MCP**: Ensures Linear MCP is available
2. **Finds Plans**: Locates all plans with the specified prefix
3. **Generates Spec**: Creates comprehensive project description from all plans
4. **Creates Project**: Creates the project in Linear with the spec
5. **Optional Issues**: Can create issues for each plan in the project
6. **Updates Plans**: Adds linear_project and linear_issue URLs to plan files

### Project Spec Generation

The project spec is a comprehensive document synthesizing all plan contents:

- **Overview**: What the feature accomplishes (from objectives)
- **Business Logic**: Combined requirements and rules
- **Implementation Steps**: Aggregated from all plan steps
- **Files Affected**: Deduplicated list of all files
- **Testing Guide**: Combined testing instructions
- **Dependencies**: Execution order visualization

### Configuration Format

Plan files are updated with:

```markdown
linear_project: https://linear.app/team/project/PROJECT-ID
linear_issue: https://linear.app/team/issue/ISSUE-ID
```

These fields are added to the `# Configuration` section following the same format as `depends_on`.

### Integration with Other Skills

- Uses same issue creation logic as `linear-issue-create`
- Projects can be referenced by `linear-milestone-create`

### Error Handling

- **No Linear MCP**: Clear error with installation instructions
- **No plans found**: Shows available prefixes, suggests planner-create
- **API errors**: Reports specific error, continues where possible
- **Partial failures**: Reports successful and failed items separately
