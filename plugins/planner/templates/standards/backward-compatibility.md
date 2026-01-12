# Backward Compatibility Conventions

These conventions clarify when backward compatibility is and isn't needed.

## Only When Required

- Unless specifically instructed otherwise, assume backward compatibility is not needed
- Clean implementations are preferable to compatibility shims
- Ask explicitly if backward compatibility is a requirement
- Don't add complexity "just in case"

## Clean Deletion of Unused Code

- If something is unused, delete it completely
- Do not rename unused variables with underscore prefix (`_var`)
- Do not re-export types "for backward compatibility"
- Do not add `// removed` comments for removed code

## Avoid Compatibility Hacks

Things to avoid:

- Renaming unused `_vars` to satisfy linters
- Re-exporting moved types from old locations
- Adding deprecation comments without removal dates
- Maintaining two code paths indefinitely

## When Backward Compatibility IS Required

If explicitly required:

- Document the compatibility requirement clearly
- Set a sunset date for the compatibility layer
- Add deprecation warnings that guide users to the new approach
- Plan for eventual removal

## Breaking Changes

When making breaking changes:

- Document them clearly in changelogs
- Provide migration guides when helpful
- Consider semantic versioning implications
- Communicate changes to affected users

## Version Control is Your Safety Net

- Git preserves all history - deleted code isn't lost
- If you need old code back, retrieve it from history
- Don't keep dead code around "just in case"
- Trust the version control system
