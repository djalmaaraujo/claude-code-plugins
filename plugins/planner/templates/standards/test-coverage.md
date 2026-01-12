# Test Coverage Best Practices

These conventions ensure effective testing without over-engineering.

## Write Minimal Tests During Development

- Do NOT write tests for every change or intermediate step
- Focus on completing the feature implementation first
- Add strategic tests only at logical completion points
- Avoid test-driven development for exploratory work

## Test Only Core User Flows

- Write tests exclusively for critical paths and primary user workflows
- Skip writing tests for non-critical utilities and secondary workflows
- These can be addressed in dedicated testing phases
- Prioritize tests that catch real bugs

## Defer Edge Case Testing

- Do NOT test edge cases, error states, or validation logic unless business-critical
- Edge case testing can be addressed in dedicated testing phases
- Focus on the happy path first
- Add edge case tests when bugs are found

## Test Behavior, Not Implementation

- Focus tests on what the code does, not how it does it
- Testing implementation details creates brittle tests
- Tests should survive refactoring
- Test public interfaces, not private methods

## Clear Test Names

- Use descriptive names that explain what's being tested
- Include the expected outcome in the name
- Follow patterns like "should_return_error_when_input_is_invalid"
- Test names serve as documentation

## Mock External Dependencies

- Isolate units by mocking databases, APIs, file systems
- Tests should not depend on external services
- Use dependency injection to enable mocking
- Keep mocks simple and focused

## Fast Execution

- Keep unit tests fast (milliseconds each)
- Developers should run them frequently during development
- Slow tests get skipped and lose value
- Move slow tests to integration test suites
