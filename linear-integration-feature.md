# Linear Integration Feature Specification

This document describes the implementation of Linear integration for the planner plugin, enabling users to create Linear projects, milestones, and issues directly from their plans.

## Prerequisites

All Linear-related skills MUST verify that the Linear MCP server (`linear-server`) is installed before proceeding. If not installed, display a helpful error message.

---

## 1. New Skill: `planner:linear-issue-create`

**Location:** `plugins/planner/skills/linear-issue-create/SKILL.md`

### Purpose
Create Linear issues from plan files. This is a foundational skill used by other Linear skills.

### Behavior

1. **Check Linear MCP**: Verify `linear-server` MCP is available. If not, display error and exit.

2. **List Available Plans**:
   - Read `plans/PROGRESS.md`
   - Parse all plan tables to extract plan filenames
   - Use `AskUserQuestion` tool to display available plans as selectable options
   - Allow user to search/filter and select one or multiple plans

3. **For Each Selected Plan**:
   - Read the plan markdown file content
   - Use the plan content as the issue description
   - Use the plan filename (without .md) as the issue title
   - Create issue in Linear using MCP `mcp__linear-server__create_issue`

4. **Update Plan File**:
   - Add `linear_issue: <issue_url>` to the `# Configuration` section
   - Format: Same line format as `depends_on`

5. **Return**: Issue URLs and confirmation

### Allowed Tools
- Read, Write, Edit, Glob, Grep, AskUserQuestion
- MCP tools: mcp__linear-server__* (all Linear MCP tools)

### User-Invocable
Yes - can be called directly or by other skills

---

## 2. New Skill: `planner:linear-project-create`

**Location:** `plugins/planner/skills/linear-project-create/SKILL.md`

### Purpose
Create a Linear project from a set of plans with a specific prefix, with a comprehensive spec as the project description.

### Behavior

1. **Check Linear MCP**: Verify `linear-server` MCP is available. If not, display error and exit.

2. **Get Prefix from User**:
   - If prefix not provided in arguments, use `AskUserQuestion` to ask
   - Example prompts: "appt", "auth", "checkout"

3. **Find Related Plans**:
   - Read `plans/PROGRESS.md`
   - Find the table section containing plans with the specified prefix
   - List all plan files matching the prefix pattern (e.g., `appt-*.md`)

4. **Read All Plan Contents**:
   - For each plan file, read its full content
   - Extract: Objective, Steps, Files to Modify, Testing sections

5. **Generate Project Spec**:
   - Create a comprehensive project description including:
     - **Overview**: Synthesized summary of what the feature does
     - **Business Logic**: Combined from all plan objectives
     - **Implementation Steps**: Aggregated steps from all plans
     - **Files Affected**: Combined list of all files to modify
     - **Testing Guide**: Combined testing instructions
     - **Milestones**: Logical groupings if applicable (based on plan dependencies)

6. **List Teams**:
   - Use `mcp__linear-server__list_teams` to get available teams
   - Use `AskUserQuestion` to let user select target team

7. **Create Project in Linear**:
   - Use `mcp__linear-server__create_project` with generated spec
   - Project name: Use the prefix or ask user for name

8. **Ask About Issues**:
   - Use `AskUserQuestion`: "Would you like to create issues for each plan in this project?"
   - Options: Yes / No

9. **If Yes - Create Issues**:
   - For each plan file, call the logic from `linear-issue-create`:
     - Create issue with plan content as description
     - Link issue to the project
     - Update plan file with `linear_issue: <url>`

10. **Update All Plan Files**:
    - Add `linear_project: <project_url>` to the `# Configuration` section of each plan

11. **Return**: Project URL, issue URLs (if created), confirmation

### Allowed Tools
- Read, Write, Edit, Glob, Grep, AskUserQuestion
- MCP tools: mcp__linear-server__* (all Linear MCP tools)

### User-Invocable
Yes

---

## 3. New Skill: `planner:linear-milestone-create`

**Location:** `plugins/planner/skills/linear-milestone-create/SKILL.md`

### Purpose
Create a milestone within an existing Linear project and optionally create issues from plans.

### Behavior

1. **Check Linear MCP**: Verify `linear-server` MCP is available. If not, display error and exit.

2. **List User's Projects**:
   - Use `mcp__linear-server__list_projects` with `member: "me"`
   - Format projects as selectable list

3. **Project Selection**:
   - Use `AskUserQuestion` to display projects
   - Allow user to search/filter and select one project

4. **Analyze Existing Milestones**:
   - Use `mcp__linear-server__get_project` to get project details
   - Check existing milestones to understand naming pattern
   - Determine what "next" milestone should be (e.g., if "v1.0" exists, suggest "v1.1")

5. **Ask for Milestone Name**:
   - Use `AskUserQuestion` with suggested name based on analysis
   - Allow user to accept suggestion or provide custom name

6. **Generate Milestone Description**:
   - Create description based on:
     - Project context
     - Purpose of this milestone phase
     - Expected deliverables

7. **Create Milestone**:
   - Use appropriate Linear MCP call to create milestone
   - Note: Linear uses "Project Milestones" - may need to use project update or roadmap features

8. **Ask About Plan Issues**:
   - Read `plans/PROGRESS.md` to find available plan prefixes
   - Use `AskUserQuestion`: "Would you like to create issues from plans for this milestone?"
   - If yes, show available prefixes and let user select

9. **If Yes - Create Issues**:
   - Get plans matching selected prefix
   - For each plan:
     - Create issue with plan content as description
     - Associate with milestone
     - Update plan file with `linear_issue: <url>`

10. **Return**: Milestone details, issue URLs (if created), confirmation

### Allowed Tools
- Read, Write, Edit, Glob, Grep, AskUserQuestion
- MCP tools: mcp__linear-server__* (all Linear MCP tools)

### User-Invocable
Yes

---

## 4. New Commands

### 4.1 Command: `/planner:linear-project-create`

**Location:** `plugins/planner/commands/linear-project-create.md`

```markdown
---
allowed-tools: Skill
---

Run the `planner:linear-project-create` skill with any arguments the user provided: $ARGUMENTS
```

### 4.2 Command: `/planner:linear-milestone-create`

**Location:** `plugins/planner/commands/linear-milestone-create.md`

```markdown
---
allowed-tools: Skill
---

Run the `planner:linear-milestone-create` skill with any arguments the user provided: $ARGUMENTS
```

### 4.3 Command: `/planner:linear-issue-create`

**Location:** `plugins/planner/commands/linear-issue-create.md`

```markdown
---
allowed-tools: Skill
---

Run the `planner:linear-issue-create` skill with any arguments the user provided: $ARGUMENTS
```

---

## 5. Plan File Updates

When a plan is synced to Linear, update its `# Configuration` section:

### Before
```markdown
# Configuration

depends_on: "appt-00-setup.md"

# Plan: appt-01-database.md
...
```

### After
```markdown
# Configuration

depends_on: "appt-00-setup.md"
linear_project: https://linear.app/team/project/PROJECT-ID
linear_issue: https://linear.app/team/issue/ISSUE-123

# Plan: appt-01-database.md
...
```

### Format Rules
- `linear_project`: URL to the Linear project (same for all plans in a project)
- `linear_issue`: URL to the specific Linear issue for this plan
- Both fields are optional and only added when synced
- Format matches `depends_on` style (key: value on its own line)

---

## 6. Linear MCP Check Function

All skills should implement this check at the start:

```
Step 1: Verify Linear MCP Installation
- Check if linear-server MCP tools are available
- Attempt to call mcp__linear-server__list_teams or similar
- If call fails or MCP not found:
  - Display error: "Linear MCP (linear-server) is not installed or not configured."
  - Display help: "Please install the Linear MCP server to use this feature."
  - Exit without proceeding
```

---

## 7. Implementation Order

1. **First**: Create `linear-issue-create` skill (foundational, used by others)
2. **Second**: Create `linear-issue-create` command
3. **Third**: Create `linear-project-create` skill
4. **Fourth**: Create `linear-project-create` command
5. **Fifth**: Create `linear-milestone-create` skill
6. **Sixth**: Create `linear-milestone-create` command
7. **Finally**: Update `plugin.json` to register new commands

---

## 8. Files to Create

| File | Type | Description |
|------|------|-------------|
| `plugins/planner/skills/linear-issue-create/SKILL.md` | Skill | Create issues from plans |
| `plugins/planner/skills/linear-project-create/SKILL.md` | Skill | Create projects with specs |
| `plugins/planner/skills/linear-milestone-create/SKILL.md` | Skill | Create milestones in projects |
| `plugins/planner/commands/linear-issue-create.md` | Command | Trigger linear-issue-create skill |
| `plugins/planner/commands/linear-project-create.md` | Command | Trigger linear-project-create skill |
| `plugins/planner/commands/linear-milestone-create.md` | Command | Trigger linear-milestone-create skill |

---

## 9. Files to Modify

| File | Change |
|------|--------|
| `plugins/planner/.claude-plugin/plugin.json` | Add new commands to the commands array |

---

## 10. Testing

### Test linear-issue-create
1. Run `/planner:linear-issue-create`
2. Verify it lists plans from PROGRESS.md
3. Select a plan
4. Verify issue created in Linear
5. Verify plan file updated with `linear_issue` field

### Test linear-project-create
1. Run `/planner:linear-project-create appt`
2. Verify it finds all appt-* plans
3. Verify project spec is comprehensive
4. Select team when prompted
5. Choose to create issues
6. Verify project and issues created
7. Verify all plan files updated with `linear_project` and `linear_issue`

### Test linear-milestone-create
1. Run `/planner:linear-milestone-create`
2. Verify it lists user's projects
3. Select a project
4. Verify milestone name suggestion
5. Choose to create issues from plans
6. Verify milestone and issues created
7. Verify plan files updated

### Test MCP Check
1. Temporarily disable Linear MCP
2. Run any `/planner:linear-*` command
3. Verify helpful error message displayed

---

## 11. AskUserQuestion Patterns

### Pattern 1: Plan Selection (multi-select)
```
Question: "Which plans would you like to create issues for?"
Header: "Plans"
Options: [list of plan filenames from PROGRESS.md]
multiSelect: true
```

### Pattern 2: Team Selection
```
Question: "Which team should this project be created in?"
Header: "Team"
Options: [list of teams from Linear]
multiSelect: false
```

### Pattern 3: Project Selection
```
Question: "Which project would you like to add a milestone to?"
Header: "Project"
Options: [list of user's projects from Linear]
multiSelect: false
```

### Pattern 4: Confirmation
```
Question: "Would you like to create issues for each plan in this project?"
Header: "Issues"
Options: ["Yes - Create issues", "No - Project only"]
multiSelect: false
```

---

## 12. Error Handling

1. **No Linear MCP**: Clear error message with installation instructions
2. **No plans found**: Inform user, suggest running planner-create first
3. **No projects found**: Inform user, suggest creating a project first
4. **Linear API errors**: Display error message, suggest checking credentials
5. **Plan file write errors**: Log error, continue with other plans, report at end
