---
name: linear-issue-create
description: Create Linear issues from plan files. Reads plans from PROGRESS.md, lets user select which plans to create issues for, and updates plan files with Linear issue URLs. Use when user wants to create Linear issues from their plans.
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, mcp__linear-server__list_teams, mcp__linear-server__list_issues, mcp__linear-server__create_issue, mcp__linear-server__get_issue, mcp__linear-server__list_projects
user-invocable: true
---

# Create Linear Issues from Plans

You are now executing the linear-issue-create skill. Follow these steps immediately:

## Step 1: Verify Linear MCP Installation

Before proceeding, verify the Linear MCP server is available:

1. **Attempt to list teams**: Call `mcp__linear-server__list_teams`
2. **If successful**: Proceed to Step 2
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

## Step 2: Get Team Selection

1. **List available teams**: Use `mcp__linear-server__list_teams`
2. **Use AskUserQuestion** to let user select the target team:

```
Question: "Which team should the issues be created in?"
Header: "Team"
Options: [list of team names from Linear]
multiSelect: false
```

3. **Store selected team ID** for issue creation

## Step 3: Read Available Plans

1. **Read PROGRESS.md**: Read `plans/PROGRESS.md`
2. **Parse plan tables**: Extract all plan filenames from markdown tables
   - Look for table rows with format: `| plan-name.md | STATUS | DATE |`
   - Extract plan names from the first column
3. **Filter out completed issues**: Check each plan file for existing `linear_issue:` field
   - Read each plan's `# Configuration` section
   - If `linear_issue:` already exists, mark as "already synced"
4. **Build selectable list**: Prepare list of plans that can be synced

## Step 4: Plan Selection

1. **Check if plans exist**: If no plans found, display error and exit:

```
════════════════════════════════════════
No Plans Found

No plans were found in plans/PROGRESS.md.

To create plans first, run:
  /planner:create "your feature description"
════════════════════════════════════════
```

2. **Use AskUserQuestion** for plan selection:

```
Question: "Which plans would you like to create Linear issues for?"
Header: "Plans"
Options: [list of plan filenames, mark already-synced ones with "(already synced)"]
multiSelect: true
```

3. **Store selected plans** for processing

## Step 5: Create Issues for Each Selected Plan

For each selected plan:

1. **Read plan file**: Read `plans/[plan-name].md`
2. **Extract content**:
   - Title: Use plan filename without `.md` extension (e.g., "auth-01-database")
   - Description: Use the full plan content (Objective, Steps, Files to Modify, Testing sections)
3. **Create issue in Linear**:
   ```
   mcp__linear-server__create_issue:
     title: [plan filename without .md]
     description: [plan content as markdown]
     team: [selected team ID]
   ```
4. **Get issue URL**: Extract the issue URL from the creation response
5. **Update plan file**: Add `linear_issue: [issue_url]` to the `# Configuration` section

## Step 6: Update Plan Files

For each created issue:

1. **Read the plan file** if not already in memory
2. **Find the `# Configuration` section**
3. **Add linear_issue field**:
   - If other fields exist (like `depends_on`), add after them
   - Format: `linear_issue: https://linear.app/team/issue/ISSUE-123`
4. **Write updated content** back to the file

Example transformation:

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
linear_issue: https://linear.app/team/issue/AUTH-123

# Plan: auth-01-database.md
```

## Step 7: Report Results

Display creation summary:

```
════════════════════════════════════════
Linear Issues Created Successfully

Team: [team name]
Issues created: [N]

Created Issues:
- auth-00-setup.md → AUTH-100
  https://linear.app/team/issue/AUTH-100
- auth-01-database.md → AUTH-101
  https://linear.app/team/issue/AUTH-101
- auth-02-api.md → AUTH-102
  https://linear.app/team/issue/AUTH-102

Plan files updated with linear_issue URLs.
════════════════════════════════════════
```

If any errors occurred:

```
════════════════════════════════════════
Linear Issues Created (with errors)

Team: [team name]
Issues created: [N successful]
Issues failed: [N failed]

Successful:
- auth-00-setup.md → AUTH-100

Failed:
- auth-01-database.md: [error message]

Check the error messages and try again.
════════════════════════════════════════
```

---

## Reference Information

### What This Skill Does

This skill creates Linear issues from existing plan files:

1. **Validates MCP**: Ensures Linear MCP is available
2. **Lists Plans**: Reads PROGRESS.md to find available plans
3. **User Selection**: Lets user choose which plans to sync
4. **Creates Issues**: Creates Linear issues with plan content as description
5. **Updates Plans**: Adds linear_issue URLs to plan Configuration sections

### Configuration Format

The `# Configuration` section in plan files is updated with:

```markdown
linear_issue: https://linear.app/team/issue/ISSUE-ID
```

This follows the same format as `depends_on` - a simple key: value pair.

### Integration with Other Skills

This skill is used by:
- `linear-project-create`: Creates issues for all plans in a project
- `linear-milestone-create`: Creates issues associated with a milestone

It can also be invoked directly via `/planner:linear-issue-create`.

### Error Handling

- **No Linear MCP**: Clear error with installation instructions
- **No plans found**: Suggests running planner-create first
- **API errors**: Reports specific error, continues with other plans
- **Already synced**: Shows "(already synced)" in plan list, allows re-selection
