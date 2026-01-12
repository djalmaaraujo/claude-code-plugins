# Configuration

<!--
IMPORTANT: This section controls spec behavior and relationships.
All {{PLACEHOLDER}} values will be replaced by the spec-creator agent.
-->

prefix: {{PREFIX}}
<!--
  The prefix used for this spec and related plans.
  Format: Short identifier (e.g., "auth", "checkout", "user-mgmt")
  Related plans will be named: prefix-001-taskname.md, prefix-002-taskname.md
-->

status: {{STATUS}}
<!--
  Spec status values:
  - DRAFT: Initial creation, still being refined
  - ACTIVE: Approved and ready for plan generation
  - DEPRECATED: Superseded by a newer spec
-->

created_at: {{CREATED_AT}}
last_updated: {{LAST_UPDATED}}
author: {{AUTHOR}}
<!--
  Author obtained from: git config user.name
-->

---

# Spec: {{SPEC_TITLE}}

## 1. Front Matter

### Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| {{VERSION}} | {{DATE}} | {{AUTHOR}} | {{CHANGE_DESCRIPTION}} |

### Table of Contents

1. [Front Matter](#1-front-matter)
2. [Introduction & Overview](#2-introduction--overview)
3. [Functional Requirements](#3-functional-requirements)
4. [Non-Functional Requirements](#4-non-functional-requirements)
5. [Design & Technical Details](#5-design--technical-details)
6. [Implementation & Logistics](#6-implementation--logistics)
7. [Appendix](#7-appendix)

---

## 2. Introduction & Overview

### 2.1 Purpose

{{PURPOSE_DESCRIPTION}}

<!--
Why build this? What problem does it solve?
If spec_verbose is ON, the agent will ask the user for clarification.
Otherwise, infer from codebase context, README, and request.
-->

### 2.2 Goals & Objectives

{{GOALS_AND_OBJECTIVES}}

<!--
Measurable outcomes expected from this feature.
Format as bullet points with clear success criteria.
If spec_verbose is ON, the agent will ask the user for input.
-->

### 2.3 Scope

#### In Scope

{{IN_SCOPE_ITEMS}}

#### Out of Scope

{{OUT_OF_SCOPE_ITEMS}}

<!--
Clear boundaries of what this spec covers and what it does NOT cover.
Helps prevent scope creep and sets expectations.
-->

### 2.4 Target Audience

{{TARGET_AUDIENCE}}

<!--
Who will use this feature? Stakeholders, end users, developers?
If spec_verbose is ON, the agent will ask the user.
-->

### 2.5 Definitions & Glossary

| Term | Definition |
|------|------------|
| {{TERM}} | {{DEFINITION}} |

<!--
Define key terms, acronyms, and domain-specific language.
Essential for clarity across team members.
-->

---

## 3. Functional Requirements

### 3.1 User Stories

{{USER_STORIES}}

<!--
Format:
- As a [user type], I want [goal] so that [benefit]

Example:
- As a customer, I want to save my payment method so that I can checkout faster
- As an admin, I want to view all transactions so that I can monitor activity
-->

### 3.2 Feature Descriptions

{{FEATURE_DESCRIPTIONS}}

<!--
Detailed descriptions of what the system does.
Each feature should be:
- Clear and unambiguous
- Testable (can verify if implemented)
- Traceable (can link to plans)
-->

### 3.3 Use Cases

#### Use Case 1: {{USE_CASE_TITLE}}

**Actor**: {{ACTOR}}
**Preconditions**: {{PRECONDITIONS}}
**Main Flow**:
1. {{STEP_1}}
2. {{STEP_2}}
3. {{STEP_3}}

**Postconditions**: {{POSTCONDITIONS}}
**Alternative Flows**: {{ALTERNATIVE_FLOWS}}
**Exception Flows**: {{EXCEPTION_FLOWS}}

<!--
Step-by-step user interactions.
Document happy path and edge cases.
-->

### 3.4 Data Requirements

#### Input Data

{{INPUT_DATA_REQUIREMENTS}}

#### Output Data

{{OUTPUT_DATA_REQUIREMENTS}}

#### Data Storage

{{DATA_STORAGE_REQUIREMENTS}}

<!--
What data flows in, out, and needs to be stored.
Consider validation, transformation, and persistence.
-->

---

## 4. Non-Functional Requirements

### 4.1 Performance

{{PERFORMANCE_REQUIREMENTS}}

<!--
Speed, load capacity, response times.
Examples:
- API response time < 200ms for 95th percentile
- Support 1000 concurrent users
- Page load < 3 seconds
-->

### 4.2 Security

{{SECURITY_REQUIREMENTS}}

<!--
Access controls, data encryption, compliance.
Examples:
- All API endpoints require authentication
- Sensitive data encrypted at rest
- GDPR compliance for user data
-->

### 4.3 Reliability & Availability

{{RELIABILITY_REQUIREMENTS}}

<!--
Uptime goals, disaster recovery.
Examples:
- 99.9% uptime SLA
- Recovery time objective (RTO) < 1 hour
- Daily backups retained for 30 days
-->

### 4.4 Scalability

{{SCALABILITY_REQUIREMENTS}}

<!--
Ability to grow with demand.
Examples:
- Horizontal scaling for API servers
- Database sharding strategy
- CDN for static assets
-->

### 4.5 Usability

{{USABILITY_REQUIREMENTS}}

<!--
Ease of use considerations.
Examples:
- Mobile-responsive design
- Accessibility (WCAG 2.1 AA)
- Maximum 3 clicks to complete core action
-->

---

## 5. Design & Technical Details

### 5.1 System Architecture

{{SYSTEM_ARCHITECTURE}}

<!--
High-level diagrams, components, and their interactions.
Can use ASCII diagrams or describe component relationships.
-->

### 5.2 Interface Specifications

#### API Endpoints

{{API_SPECIFICATIONS}}

<!--
Format:
- METHOD /path - Description
  Request: { field: type }
  Response: { field: type }
-->

#### UI/UX Considerations

{{UI_UX_CONSIDERATIONS}}

<!--
User interface design notes, mockup references.
-->

#### Data Formats

{{DATA_FORMATS}}

<!--
JSON schemas, data structures, message formats.
-->

### 5.3 Technical Standards & Constraints

#### Technologies to Use

{{TECHNOLOGIES_TO_USE}}

#### Technologies to Avoid

{{TECHNOLOGIES_TO_AVOID}}

#### Platform Constraints

{{PLATFORM_CONSTRAINTS}}

<!--
Technical decisions and limitations.
Align with existing codebase patterns.
-->

### 5.4 Data Models

{{DATA_MODELS}}

<!--
Database schemas, entity relationships.
Can use ASCII diagrams or describe in table format:

| Table | Field | Type | Constraints |
|-------|-------|------|-------------|
| users | id | UUID | PRIMARY KEY |
| users | email | VARCHAR(255) | UNIQUE, NOT NULL |
-->

---

## 6. Implementation & Logistics

### 6.1 Assumptions & Dependencies

#### Assumptions

{{ASSUMPTIONS}}

<!--
What must be true for this to work.
Examples:
- Users have modern browsers (Chrome 90+, Firefox 88+)
- Database supports JSON columns
- Third-party API is available and stable
-->

#### Dependencies

{{DEPENDENCIES}}

<!--
External systems, libraries, or features required.
Examples:
- Stripe API for payments
- Redis for caching
- auth-feature spec must be implemented first
-->

### 6.2 Milestones (Plans)

{{MILESTONES_PLANS_LIST}}

<!--
This section is automatically updated after plans are generated.
Format:

| Plan | Description | Status |
|------|-------------|--------|
| prefix-001-setup.md | Initial setup and scaffolding | NOT STARTED |
| prefix-002-models.md | Database models and migrations | NOT STARTED |

The spec-plans-sync skill will update this section.
-->

### 6.3 Success Metrics

{{SUCCESS_METRICS}}

<!--
How success will be measured.
If spec_verbose is ON, the agent will ask the user.
Examples:
- 50% reduction in checkout abandonment
- User satisfaction score > 4.5/5
- 100% test coverage for critical paths
-->

### 6.4 Deployment Plan

{{DEPLOYMENT_PLAN}}

<!--
How this goes live.
If spec_verbose is ON, the agent will ask the user.
Examples:
- Feature flag rollout (10% → 50% → 100%)
- Blue-green deployment
- Database migration strategy
-->

---

## 7. Appendix

### 7.1 Supporting Documents

{{SUPPORTING_DOCUMENTS}}

<!--
Links to:
- Design mockups
- API documentation
- Related specs
- External resources
-->

### 7.2 Research & Background

{{RESEARCH_BACKGROUND}}

<!--
Any research, analysis, or background information
that informed this spec.
-->

### 7.3 Open Questions

{{OPEN_QUESTIONS}}

<!--
Unresolved questions that need answers.
Track these for follow-up.
-->

---

## Spec Conventions

@templates/standards/spec-writing.md
@templates/standards/requirement-format.md

<!--
Reference spec-specific conventions when available.
These guide how requirements should be written.
-->

---

## Template Usage Notes

<!--
This section is for template customization guidance.
Remove this entire section when creating actual specs.
-->

This template provides a structure for creating comprehensive specifications.

### How Placeholders Work

All `{{PLACEHOLDER}}` values in this template will be **automatically replaced** by the `spec-creator` agent when generating specs. The agent:

1. Analyzes your request and codebase context deeply
2. Infers as much as possible from existing code, README, and patterns
3. Fills in all placeholders with appropriate content
4. Only asks questions if `spec_verbose` is ON or truly necessary
5. Removes unused optional sections

### Placeholder Reference

| Placeholder | Description |
|-------------|-------------|
| `{{PREFIX}}` | Short identifier for this spec (e.g., "auth", "checkout") |
| `{{STATUS}}` | Spec status: DRAFT, ACTIVE, or DEPRECATED |
| `{{SPEC_TITLE}}` | Descriptive title for the spec |
| `{{PURPOSE_DESCRIPTION}}` | Why this feature is being built |
| `{{GOALS_AND_OBJECTIVES}}` | Measurable outcomes |
| `{{IN_SCOPE_ITEMS}}` | What's included |
| `{{OUT_OF_SCOPE_ITEMS}}` | What's excluded |
| `{{USER_STORIES}}` | User stories in standard format |
| `{{FEATURE_DESCRIPTIONS}}` | Detailed feature descriptions |
| `{{API_SPECIFICATIONS}}` | API endpoint definitions |
| `{{DATA_MODELS}}` | Database schemas |
| `{{MILESTONES_PLANS_LIST}}` | Related plans (auto-updated by sync) |

### spec_verbose Behavior

When `spec_verbose` is **OFF** (default):
- Agent infers everything possible from codebase
- Only asks when truly ambiguous
- Maximum automation

When `spec_verbose` is **ON**:
- Agent asks more clarifying questions
- Seeks user input for key decisions
- More interactive experience

### Customizing This Template

When you eject this template to your project's `plans/` folder, you can:

1. **Modify sections** - Change headings, add fields, restructure as needed
2. **Add new placeholders** - Use `{{YOUR_PLACEHOLDER}}` syntax
3. **Remove sections** - Delete sections not relevant to your project
4. **Add project-specific guidance** - Include your team's conventions

The spec-creator agent will use your customized template when generating new specs.
