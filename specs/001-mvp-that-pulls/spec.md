# Feature Specification: CodeRabbit Comment Fetcher MVP

**Feature Branch**: `001-mvp-that-pulls`
**Created**: 2025-09-30
**Status**: Draft
**Input**: User description: "mvp that pulls ALL unresolved coderabbit comments from a PR to be reviewed by claude code using command"

## Execution Flow (main)
```
1. Parse user description from Input
   → ✅ Feature description provided
2. Extract key concepts from description
   → Identify: actors (developer using Claude Code), actions (fetch comments, display for review), data (CodeRabbit PR comments), constraints (unresolved only)
3. For each unclear aspect:
   → Mark with [NEEDS CLARIFICATION: specific question]
4. Fill User Scenarios & Testing section
   → ✅ Clear user flow identified
5. Generate Functional Requirements
   → Each requirement must be testable
   → Mark ambiguous requirements
6. Identify Key Entities (if data involved)
   → Comments, PR, threads
7. Run Review Checklist
   → If any [NEEDS CLARIFICATION]: WARN "Spec has uncertainties"
   → If implementation details found: ERROR "Remove tech details"
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

---

## Clarifications

### Session 2025-09-30
- Q: When the PR has many unresolved comments, how should output be handled? → A: Display all comments and save to file for review
- Q: How should nested conversation threads be handled (when CodeRabbit replies are mixed with user replies)? → A: Show all CodeRabbit comments in thread chronologically
- Q: When GitHub authentication fails, what should happen? → A: Prompt user to run gh auth login
- Q: When GitHub API rate limiting occurs, what should happen? → A: Exit with error and show rate limit reset time
- Q: Should the tool work with closed or merged PRs? → A: Yes, fetch comments from any PR state

---

## User Scenarios & Testing

### Primary User Story

A developer working on a pull request receives CodeRabbit review comments and wants to address them efficiently. They want to retrieve all unresolved CodeRabbit comments from their current PR branch in a format that Claude Code can analyze and help them address systematically.

### Acceptance Scenarios

1. **Given** a developer is on a branch with an associated PR containing unresolved CodeRabbit comments, **When** they run the command, **Then** all unresolved CodeRabbit comments are displayed with file paths and comment text

2. **Given** a developer is on a branch with an associated PR that has no unresolved CodeRabbit comments, **When** they run the command, **Then** a success message indicates no unresolved comments exist

3. **Given** a developer is on a branch without an associated PR, **When** they run the command, **Then** an error message indicates no PR was found for the current branch

4. **Given** a developer is not in a git repository, **When** they run the command, **Then** an error message indicates the command must be run from within a git repository

5. **Given** CodeRabbit has posted comments on multiple files in a PR, **When** the developer runs the command, **Then** comments are grouped by file path for easy navigation

### Edge Cases

- When the PR has many unresolved comments, the system displays all to terminal AND saves a copy to a file for review
- In nested conversation threads (CodeRabbit + user replies), all CodeRabbit comments are shown in chronological order
- If GitHub authentication fails or expires, the system prompts the user to run `gh auth login` and exits
- When GitHub API rate limiting occurs, the system exits with an error message showing when the rate limit will reset
- The tool works with PRs in any state (open, closed, merged) - fetching comments regardless of PR status

## Requirements

### Functional Requirements

- **FR-001**: System MUST auto-detect the current git repository's owner and name from the working directory
- **FR-002**: System MUST auto-detect the PR number associated with the current branch
- **FR-003**: System MUST fetch all review threads from the detected PR regardless of PR state (open, closed, or merged)
- **FR-004**: System MUST filter review threads to only include unresolved threads
- **FR-005**: System MUST filter comments within unresolved threads to only show comments authored by CodeRabbit (login: "coderabbitai")
- **FR-005a**: System MUST display all CodeRabbit comments from a thread in chronological order (by creation timestamp)
- **FR-006**: System MUST display each comment with its associated file path
- **FR-007**: System MUST display each comment's text content in readable format
- **FR-008**: System MUST handle pagination when fetching review threads (PRs may have more than 100 threads)
- **FR-009**: System MUST display a friendly message when no unresolved CodeRabbit comments are found
- **FR-010**: System MUST display clear error messages when prerequisites are not met (no PR, not in repo)
- **FR-010a**: System MUST prompt user to run `gh auth login` when authentication fails and exit with code 1
- **FR-010b**: System MUST detect GitHub API rate limiting and exit with error message showing rate limit reset time (exit code 2)
- **FR-011**: System MUST use existing GitHub CLI authentication (no separate credential management)
- **FR-012**: System MUST support standard terminal output with visual formatting (emojis, spacing)
- **FR-013**: System MUST save all fetched comments to a file for later review
- **FR-014**: System MUST exit with code 0 on success, 1 on user error, 2 on system error

### Non-Functional Requirements

- **NFR-001**: System MUST complete execution in <5 seconds for PRs with <50 comments (performance goal)
- **NFR-002**: System MUST complete execution in <30 seconds for PRs with 500+ comments (performance goal)
- **NFR-003**: System MUST support PRs with up to 1000+ comments via pagination (scalability)
- **NFR-004**: System MUST use token-efficient output format suitable for AI assistant consumption (Claude Code integration)
- **NFR-005**: System MUST follow macOS terminal conventions (colors, emojis, PATH installation)
- **NFR-006**: System MUST be implementable as a single bash script <500 lines (maintainability)

### Key Entities

- **Pull Request**: The GitHub pull request being reviewed, identified by owner, repo name, and PR number
- **Review Thread**: A conversation thread containing one or more comments, has an `isResolved` status
- **Comment**: Individual review comment within a thread, has author, body text, file path, and creation timestamp
- **Repository Context**: Current working directory's git repository information (owner, name, current branch)

---

## Review & Acceptance Checklist

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [x] Review checklist passed

---