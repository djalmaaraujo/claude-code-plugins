---
name: planner-commit
description: Handle git commits for plan execution with support for Conventional Commits or simple format. Called by plan-executor when auto_commit is enabled.
allowed-tools: Bash
user-invocable: false
---

# Planner Commit Skill

This skill handles git commits after successful plan execution, respecting the configured commit message standard.

## Context You Receive

When called, you receive:

- `plan_name`: The name of the executed plan (e.g., "auth-01-setup.md")
- `summary`: Brief description of what was accomplished
- `files_modified`: List of files that were changed
- `auto_commit_standard`: Either `"conventional_commits"` or `"no_standard"`

---

## Commit Logic

### If `auto_commit_standard` is `"conventional_commits"`

Follow the Conventional Commits specification (v1.0.0):

**Format**: `<type>(<scope>): <description>`

**Determine the commit type** by analyzing the changes:

| Type       | When to Use                                                  |
| ---------- | ------------------------------------------------------------ |
| `feat`     | New feature or functionality                                 |
| `fix`      | Bug fix                                                      |
| `refactor` | Code restructuring without behavior change                   |
| `docs`     | Documentation only changes                                   |
| `test`     | Adding or updating tests                                     |
| `chore`    | Maintenance, dependencies, tooling, config                   |
| `style`    | Formatting, whitespace, missing semicolons (no logic change) |
| `perf`     | Performance improvements                                     |

**Determine the scope** from the plan name:

- Extract a meaningful scope from the plan filename
- Example: `auth-01-setup.md` → scope is `auth`
- Example: `user-profile-03-api.md` → scope is `user-profile`
- If unclear, use `planner` as the default scope

**Write the description**:

- Use imperative mood ("add feature" not "added feature")
- Keep it under 72 characters
- Be concise but descriptive

**Include a body** if more than 3 files were modified:

- Add a blank line after the subject
- List key changes or provide context
- Wrap at 72 characters

**Example commits**:

```
feat(auth): add user authentication endpoints

- Implement login and logout routes
- Add JWT token generation
- Create auth middleware
```

```
fix(user-profile): correct avatar upload validation
```

```
refactor(planner): reorganize plan execution flow
```

---

### If `auto_commit_standard` is `"no_standard"` (or missing)

Use the simple format:

```
feat(planner): Complete [plan_name] - [summary]
```

**Examples**:

```
feat(planner): Complete auth-01-setup.md - Set up authentication module
```

```
feat(planner): Complete user-profile-02-api.md - Add profile API endpoints
```

---

## Git Commands

1. **Stage all modified files**:

   ```bash
   git add .
   ```

2. **Create the commit** with the appropriate message format:

   ```bash
   git commit -m "<message>"
   ```

   For multi-line messages (Conventional Commits with body):

   ```bash
   git commit -m "<subject>" -m "<body>"
   ```

3. **Do NOT push** - leave that to the user

---

## Rules

1. **Never push to remote** - only commit locally
2. **Always stage with `git add .`** before committing
3. **Analyze the actual changes** to determine the correct commit type
4. **Use the plan name** to derive a meaningful scope
5. **Keep commits atomic** - one commit per plan execution
6. **Handle errors gracefully** - if commit fails, report the error
