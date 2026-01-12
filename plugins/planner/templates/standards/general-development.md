# General Development Conventions

These conventions ensure consistent, maintainable, and collaborative development practices.

## Consistent Project Structure

- Organize files and directories in a predictable, logical structure
- Team members should be able to navigate the codebase easily
- Follow existing patterns when adding new files

## Clear Documentation

- Maintain up-to-date README files with setup instructions
- Include architecture overview for complex systems
- Document contribution guidelines for team projects

## Version Control Best Practices

When `auto_commit` is enabled in planner configuration:

- Use clear, descriptive commit messages
- Create feature branches for new work
- Write meaningful pull/merge request descriptions
- Keep commits focused and atomic

## Environment Configuration

- Use environment variables for configuration
- Never commit secrets or API keys to version control
- Provide `.env.example` files as templates
- Document required environment variables

## Dependency Management

- Keep dependencies up-to-date and minimal
- Document why major dependencies are used
- Pin versions for reproducible builds
- Review dependencies for security vulnerabilities

## Code Review Process

- Establish consistent code review expectations
- Review for correctness, readability, and maintainability
- Provide constructive feedback with specific suggestions
- Authors should respond to all feedback before merging

## Testing Requirements

- Define what level of testing is required before merging
- Unit tests for core business logic
- Integration tests for critical paths
- Run tests before committing changes
