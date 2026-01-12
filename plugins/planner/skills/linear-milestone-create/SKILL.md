---
name: linear-milestone-create
description: Create a milestone within an existing Linear project and optionally create issues from plans. Lists user's projects for selection, suggests milestone names, and can associate plan-based issues with the milestone. Use when user wants to add milestones to Linear projects.
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, mcp__linear-server__list_teams, mcp__linear-server__list_projects, mcp__linear-server__get_project, mcp__linear-server__update_project, mcp__linear-server__create_issue, mcp__linear-server__list_issues
user-invocable: true
---

# Create Linear Milestone

You are now executing the linear-milestone-create skill. Follow these steps immediately:

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

## Step 2: List User's Projects

1. **Fetch user's projects**: Call `mcp__linear-server__list_projects` with `member: "me"`
2. **Check if projects exist**: If no projects found, display error:

```
════════════════════════════════════════
No Projects Found

You don't have any Linear projects yet.

To create a project from plans, run:
  /planner:linear-project-create [prefix]

Or create a project directly in Linear.
════════════════════════════════════════
```

3. **Store projects list** for selection

## Step 3: Project Selection

1. **Use AskUserQuestion** to let user select a project:

```
Question: "Which project would you like to add a milestone to?"
Header: "Project"
Options: [
  "[Project 1 Name] - [Team Name]",
  "[Project 2 Name] - [Team Name]",
  "[Project 3 Name] - [Team Name]",
  ... (up to 4 options, with "Other" always available)
]
multiSelect: false
```

2. **Store selected project ID and details**

## Step 4: Analyze Project for Milestone Suggestion

1. **Get project details**: Call `mcp__linear-server__get_project` with project ID
2. **Analyze existing milestones** (if any):
   - Look for naming patterns (e.g., "v1.0", "Phase 1", "Sprint 1")
   - Identify the next logical milestone name
3. **Generate suggestion**:
   - If pattern found: Suggest next in sequence (e.g., "v1.1", "Phase 2", "Sprint 2")
   - If no pattern: Suggest "Milestone 1" or based on project context

## Step 5: Get Milestone Name

1. **Use AskUserQuestion** with suggested name:

```
Question: "What should the milestone be named?"
Header: "Milestone"
Options: [
  "[Suggested Name] (Recommended)",
  "[Alternative suggestion based on project]",
  "Other"
]
multiSelect: false
```

2. **Store milestone name**

## Step 6: Generate Milestone Description

Create a meaningful milestone description based on:
- Project context and goals
- Phase/sprint purpose
- Expected deliverables

Example:
```markdown
## Milestone: [Name]

**Purpose**: [Brief description of what this milestone accomplishes]

**Scope**: [What's included in this milestone]

**Success Criteria**:
- [Criterion 1]
- [Criterion 2]
- [Criterion 3]
```

## Step 7: Create Milestone

Linear handles milestones through project milestones or roadmap features. Use the appropriate method:

1. **Update project with milestone** using `mcp__linear-server__update_project`:
   - Add milestone to project roadmap/milestones if supported
   - Or create a label/tag for milestone tracking

2. **Alternative approach** if direct milestone not available:
   - Create a parent issue representing the milestone
   - Use labels to group milestone issues

3. **Store milestone identifier** for issue association

## Step 8: Ask About Plan-Based Issues

1. **Read plans/PROGRESS.md** to find available plan prefixes
2. **Parse prefixes**: Extract unique prefixes from plan names (e.g., "auth", "appt", "checkout")
3. **Use AskUserQuestion**:

```
Question: "Would you like to create issues from plans for this milestone?"
Header: "Issues"
Options: [
  "Yes - Select plans to include",
  "No - Milestone only"
]
multiSelect: false
```

4. **If "No"**: Skip to Step 11
5. **If "Yes"**: Continue to Step 9

## Step 9: Select Plan Prefix

1. **Use AskUserQuestion** to select prefix:

```
Question: "Which plan prefix should be used for milestone issues?"
Header: "Prefix"
Options: [
  "auth (5 plans)",
  "appt (3 plans)",
  "checkout (2 plans)",
  "Other"
]
multiSelect: false
```

2. **Store selected prefix**

## Step 10: Create Issues from Plans

For each plan with the selected prefix:

1. **Read plan file**: Read `plans/[prefix]-NN-name.md`
2. **Create issue**:
   ```
   mcp__linear-server__create_issue:
     title: [plan filename without .md]
     description: [full plan content]
     team: [project's team ID]
     project: [project ID]
     milestone: [milestone identifier if supported]
   ```
3. **Get issue URL** from response
4. **Update plan file** with `linear_issue: [url]`
5. **If project not already linked**: Add `linear_project: [project_url]` too

## Step 11: Update Plan Files

For each plan that had an issue created:

1. **Read the plan file**
2. **Find the `# Configuration` section**
3. **Add/update fields**:

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
Linear Milestone Created Successfully

Project: [project name]
Milestone: [milestone name]

[If issues created:]
Issues Created: [N]

Plan → Issue Mapping:
- auth-00-setup.md → AUTH-100
  https://linear.app/team/issue/AUTH-100
- auth-01-database.md → AUTH-101
  https://linear.app/team/issue/AUTH-101

Plan files updated with linear_issue URLs.
[End if]

View project: https://linear.app/team/project/PROJECT-ID
════════════════════════════════════════
```

---

## Reference Information

### What This Skill Does

This skill creates milestones in existing Linear projects:

1. **Validates MCP**: Ensures Linear MCP is available
2. **Lists Projects**: Shows user's projects for selection
3. **Analyzes Patterns**: Suggests milestone name based on existing milestones
4. **Creates Milestone**: Adds milestone to selected project
5. **Optional Issues**: Can create issues from plans for the milestone
6. **Updates Plans**: Adds linear_project and linear_issue URLs to plan files

### Milestone Naming Suggestions

The skill analyzes existing milestones to suggest the next one:

| Existing Pattern | Suggestion |
|------------------|------------|
| v1.0, v1.1 | v1.2 |
| Phase 1, Phase 2 | Phase 3 |
| Sprint 1 | Sprint 2 |
| Q1 2024 | Q2 2024 |
| None | Milestone 1 |

### Linear Milestone Support

Linear's milestone support may vary. The skill handles this by:
- Using project milestones if available
- Using roadmap features as alternative
- Creating parent issues with labels as fallback

### Configuration Format

Plan files are updated with:

```markdown
linear_project: https://linear.app/team/project/PROJECT-ID
linear_issue: https://linear.app/team/issue/ISSUE-ID
```

### Integration with Other Skills

- Works alongside `linear-project-create` for existing projects
- Uses same issue creation logic as `linear-issue-create`
- Can add issues to projects created by `linear-project-create`

### Error Handling

- **No Linear MCP**: Clear error with installation instructions
- **No projects found**: Suggests creating a project first
- **No plans found**: Continues with milestone-only creation
- **API errors**: Reports specific errors, continues where possible
