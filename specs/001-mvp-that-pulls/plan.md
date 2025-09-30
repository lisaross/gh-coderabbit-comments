# Implementation Plan: CodeRabbit Comment Fetcher MVP

**Branch**: `001-mvp-that-pulls` | **Date**: 2025-09-30 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/Users/focus/Developer/Projects/gh-coderabbit-comments/specs/001-mvp-that-pulls/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → ✅ Spec loaded successfully
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → ✅ No NEEDS CLARIFICATION in spec (all resolved via /clarify)
   → Project Type: single (CLI tool)
   → Structure Decision: Single project with bash script
3. Fill the Constitution Check section based on the constitution document
   → ✅ Constitution analyzed
4. Evaluate Constitution Check section below
   → In progress
5. Execute Phase 0 → research.md
   → Pending
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent file
   → Pending
7. Re-evaluate Constitution Check section
   → Pending
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
   → Pending
9. STOP - Ready for /tasks command
   → Pending
```

**IMPORTANT**: The /plan command STOPS at step 8. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary

This MVP delivers a bash-based CLI command that fetches all unresolved CodeRabbit review comments from a GitHub PR. The tool auto-detects the repository context from the current working directory, uses `gh` CLI for authentication, and displays comments grouped by file path with visual formatting. All results are saved to a file for later review by Claude Code or manual inspection.

Key capabilities:
- Auto-detection of repo owner, name, and PR number from current branch
- GraphQL pagination to handle PRs with >100 review threads
- Filtering for unresolved threads with CodeRabbit-authored comments
- Chronological ordering of comments within threads
- Graceful error handling for auth failures, rate limiting, and missing PRs
- Token-efficient output suitable for AI assistant consumption

## Technical Context

**Language/Version**: Bash 5.x (macOS zsh default)
**Primary Dependencies**: `gh` CLI (GitHub official), `jq` (JSON parsing), standard UNIX tools (`grep`, `sed`, `cat`)
**Storage**: Filesystem (output file in `.coderabbit/` directory)
**Testing**: `bats-core` (Bash Automated Testing System), manual testing checklist
**Target Platform**: macOS 12+ (primary), Linux compatible (bash 4.4+)
**Project Type**: single (standalone CLI tool)
**Performance Goals**: <5 seconds for PRs with <50 comments, <30 seconds for PRs with 500+ comments
**Constraints**: GraphQL API pagination limit (100 items per page), rate limit handling required
**Scale/Scope**: Single bash script (~300-500 lines), support for PRs with 1000+ comments via pagination

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Shell-First Development ✅
- [x] Implementable as standalone bash script
- [x] Uses `#!/usr/bin/env bash` shebang
- [x] Includes `set -e` for error propagation
- [x] Exit codes: 0 (success), 1 (user error), 2 (system error) per FR-014
- [x] Dependencies limited to: `gh`, `jq`, standard UNIX tools
- [x] Self-contained: single script file

**Status**: PASS - All requirements met by design

### II. Claude Code Integration ✅
- [x] Output format: structured (grouped by file), parseable
- [x] Saves to file for token-efficient AI consumption (FR-013)
- [x] Error messages: actionable (prompts for `gh auth login`, shows rate limit reset time)
- [x] No verbose decoration by default (emojis only for visual scanning)
- [x] Progress suppressed (no loaders for MVP)

**Status**: PASS - Token efficiency built into requirements

### III. macOS Native Conventions ✅
- [x] Installation: `~/bin` or `/usr/local/bin` (documented in README)
- [x] Config: Output to `.coderabbit/` directory in repo root
- [x] Permissions: Script must be `chmod +x` (installation docs will warn)
- [x] Colors: ANSI codes for success (green ✅), errors (red ❌), info (cyan 🔍) per FR-012
- [x] Emojis: Used for visual scanning per FR-012

**Status**: PASS - macOS conventions followed

### IV. GitHub CLI Extension Pattern ✅
- [x] Authenticates via `gh auth` (FR-011)
- [x] Auto-detects repo context from current directory (FR-001, FR-002)
- [x] Future: Can support `--json` flag (deferred to post-MVP)
- [x] Respects `.github/` conventions (no custom config for MVP)
- [x] Error messages reference `gh auth login` (FR-010a)

**Status**: PASS - Leverages gh CLI as required

### V. User-Friendly Output ✅
- [x] Default: formatted text with file path grouping, visual hierarchy (FR-006, FR-007, FR-012)
- [x] Future `--json` flag: deferred to post-MVP (constitution allows this)
- [x] No pagination needed (displays all, saves to file per clarification)
- [x] Summary stats: "Found N unresolved comments" before details
- [x] Empty state: "✅ No unresolved comments" per FR-009

**Status**: PASS - Human-first output with file backup

### Testing Requirements ✅
- [x] Manual testing: Will create `manual-testing.md` checklist in Phase 1
- [x] Shell unit tests: Use `bats-core` for pagination logic, error handling
- [x] Integration tests: Test against real `gh api` in dev environment
- [x] Error scenarios: Verify exit codes 0/1/2 per FR-014

**Status**: PASS - Testing strategy aligns with constitution

### Security & Reliability ✅
- [x] No credential storage (uses `gh auth token` dynamically)
- [x] Input validation: Sanitize repo owner/name before API calls
- [x] GraphQL escaping: Use `jq` for safe JSON construction
- [x] Pagination limit: Max 100 pages to prevent infinite loops per constitution
- [x] Trap signals: `trap cleanup EXIT INT TERM` for temp file cleanup
- [x] Network failures: GraphQL errors handled, rate limit detected (FR-010b)

**Status**: PASS - Security principles followed

## Project Structure

### Documentation (this feature)
```
specs/001-mvp-that-pulls/
├── plan.md              # This file
├── research.md          # Phase 0 output (GraphQL patterns, bash best practices)
├── data-model.md        # Phase 1 output (Comment, Thread, PR entities)
├── quickstart.md        # Phase 1 output (manual test scenarios)
├── contracts/           # Phase 1 output (GraphQL query schemas)
│   └── github-graphql.md
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
gh-coderabbit-comments/
├── bin/
│   └── gh-crab-comments          # Main executable script
├── tests/
│   ├── integration/
│   │   └── test_gh_api.bats      # Integration tests with real gh api
│   └── unit/
│       ├── test_pagination.bats  # Pagination logic unit tests
│       └── test_filtering.bats   # Comment filtering unit tests
├── .coderabbit/                  # Output directory (gitignored)
│   └── pr-<number>-comments.txt  # Saved comments per PR
├── README.md                     # Installation & usage docs
└── manual-testing.md             # Manual test checklist
```

**Structure Decision**: Single project structure selected. This is a standalone bash CLI tool with no frontend/backend split. The main script lives in `bin/` for easy PATH installation. Tests use `bats-core` framework with integration/unit separation. Output files saved to `.coderabbit/` directory (gitignored) for Claude Code consumption.

## Phase 0: Outline & Research

No NEEDS CLARIFICATION markers remain in Technical Context (all resolved via /clarify). Research focus areas:

1. **GraphQL Pagination Patterns**:
   - Research: Best practices for GitHub GraphQL API pagination with cursor-based navigation
   - Research: Error handling for rate limiting and API failures
   - Research: Efficient query structure to minimize API calls

2. **Bash Best Practices**:
   - Research: Signal trapping and cleanup patterns
   - Research: `jq` usage for safe JSON parsing and construction
   - Research: Exit code conventions and error message formatting

3. **GitHub CLI Integration**:
   - Research: `gh auth token` usage and scope verification
   - Research: `gh repo view` for auto-detecting repo context
   - Research: `gh pr view` for PR number detection from branch

**Output**: ✅ research.md created with GraphQL patterns, bash best practices, and gh CLI integration research

## Phase 1: Design & Contracts
*Prerequisites: research.md complete ✅*

### Artifacts Created

1. **data-model.md** ✅
   - Entities: Repository Context, Pull Request, Review Thread, Comment
   - Validation rules for owner/repo names, PR numbers
   - Filtering pipeline: `isResolved==false` → `author.login=="coderabbitai"` → sort by `createdAt`
   - Storage format: in-memory (bash variables) + persistent (`.coderabbit/pr-{number}-comments.txt`)
   - Error states and exit codes mapped to FR requirements
   - Pagination model: 100 threads/page, max 100 pages

2. **contracts/github-graphql.md** ✅
   - Query: `FetchReviewThreads` with cursor-based pagination
   - Input parameters: `owner`, `repo`, `number`, `cursor` (optional)
   - Response schema with success and error cases
   - Error handling: Auth (exit 1), Rate limit (exit 2), Not found (exit 1)
   - Field descriptions for all returned data
   - Pagination algorithm with bash implementation
   - Security: input validation, no GraphQL injection, token via `gh auth`

3. **quickstart.md** ✅
   - 11 manual test scenarios covering all functional requirements
   - Happy path, error cases, edge cases (large PRs, mixed authors, closed PRs)
   - Performance benchmarks (<5s small, <30s large)
   - Constitution compliance checklist
   - Troubleshooting guide for common issues
   - Acceptance criteria and sign-off section

4. **CLAUDE.md** ✅ (agent context file)
   - Updated via `.specify/scripts/bash/update-agent-context.sh claude`
   - Added technologies: Bash 5.x, gh CLI, jq, filesystem storage
   - Project structure documented (single CLI tool)
   - Ready for implementation guidance

### Contract Tests

**Note**: Contract tests will be generated in Phase 3 (task execution) following TDD approach. Quickstart.md serves as the manual test specification for now.

### Integration Test Scenarios (from quickstart.md)

1. **Scenario 1**: Happy path with comments found → verify FR-001 through FR-014
2. **Scenario 2**: No unresolved comments → verify FR-009
3. **Scenario 3**: No PR found → verify FR-010, exit code 1
4. **Scenario 4**: Not in git repo → verify FR-010, exit code 1
5. **Scenario 5**: Auth failure → verify FR-010a, FR-011, exit code 1
6. **Scenario 6**: Large PR pagination → verify FR-008
7. **Scenario 7**: Mixed authors → verify FR-005, FR-005a
8. **Scenario 8**: Closed/merged PR → verify clarification (works with any state)
9. **Scenario 9**: Output file validation → verify FR-013
10. **Scenario 10**: Signal interruption → verify cleanup
11. **Scenario 11**: Rate limiting → verify FR-010b, exit code 2

### Post-Design Constitution Re-check

Re-evaluating all constitutional principles against Phase 1 design:

#### I. Shell-First Development ✅
- Design confirms: Single bash script, no compilation needed
- Dependencies: Only `gh`, `jq`, standard tools (approved list)
- Exit codes: Clearly mapped in data-model.md
- **Status**: PASS - Design fully compliant

#### II. Claude Code Integration ✅
- Output file design: Plain text, token-efficient, parseable
- File location: `.coderabbit/` directory (gitignored, specific)
- Error messages: Actionable (documented in contracts)
- **Status**: PASS - Token efficiency maintained

#### III. macOS Native Conventions ✅
- Output directory: `.coderabbit/` in repo root (respects project structure)
- Installation: `~/bin` documented in quickstart
- Emojis: Specified in data-model output format
- **Status**: PASS - Platform conventions followed

#### IV. GitHub CLI Extension Pattern ✅
- Contract confirms: `gh api graphql` for all GitHub calls
- Auth: `gh auth status` check before execution
- Context detection: `gh repo view` and `gh pr view`
- **Status**: PASS - Full gh CLI integration

#### V. User-Friendly Output ✅
- Output format: File path grouping, visual hierarchy, summary stats
- Empty state: "✅ No unresolved comments" per FR-009
- File backup: All output saved for later review
- **Status**: PASS - UX design complete

**Conclusion**: No constitutional violations introduced by Phase 1 design. All principles maintained.

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

### Task Generation Strategy

The `/tasks` command will:

1. **Load design artifacts**:
   - data-model.md → Entity creation tasks
   - contracts/github-graphql.md → API integration tasks
   - quickstart.md → Test scenario tasks

2. **Generate task structure**:
   - **Setup tasks**: Project init, dependency checks, directory structure
   - **Test tasks** (TDD - written FIRST):
     - Contract test: Verify GraphQL query returns expected structure
     - Integration tests: 11 scenarios from quickstart.md
     - Unit tests: Pagination logic, filtering logic, error handling
   - **Implementation tasks**:
     - Core script: Main execution flow
     - Repo detection: `gh repo view` integration
     - PR detection: `gh pr view` integration
     - GraphQL pagination: Cursor-based loop
     - Filtering: `jq` pipelines for unresolved + CodeRabbit
     - Output formatting: File grouping, emoji, colors
     - File saving: Write to `.coderabbit/pr-{number}-comments.txt`
     - Error handling: Auth, rate limit, not found
   - **Polish tasks**:
     - README.md: Installation, usage examples
     - Manual testing: Run all quickstart scenarios
     - Performance validation: Test with large PRs

3. **Task ordering**:
   - **TDD order**: Tests before implementation (critical!)
   - **Dependency order**:
     - Setup → Tests → Core → Integration → Polish
     - Repo/PR detection before GraphQL queries
     - Pagination before filtering
     - Filtering before output formatting
   - **Parallel opportunities** [P]:
     - Multiple test files (different scenarios)
     - Documentation tasks (README, CHANGELOG)

4. **Estimated output**: 20-25 numbered tasks in tasks.md

**Task Examples**:
```
T001 [P] Create project directories (bin/, tests/, .coderabbit/)
T002 [P] Verify dependencies (gh, jq, git)
T003 [P] Contract test: GraphQL query structure
T004 [P] Integration test: Happy path scenario
T005 [P] Integration test: No PR found scenario
T006     Create main script skeleton (bin/gh-crab-comments)
T007     Implement repo context detection
T008     Implement PR number detection
T009     Implement GraphQL pagination loop
T010     Implement filtering (unresolved + CodeRabbit)
T011     Implement output formatting
T012     Implement file saving
T013     Implement error handling (auth)
T014     Implement error handling (rate limit)
T015 [P] Run manual tests from quickstart.md
T016 [P] Write README.md
T017     Performance test with large PR
```

**IMPORTANT**: This phase is executed by the `/tasks` command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)
**Phase 4**: Implementation (execute tasks.md following constitutional principles)
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking

**No constitutional violations identified.**

All design decisions align with:
- Shell-First Development (bash script)
- Claude Code Integration (file output)
- macOS Native Conventions (standard paths, emojis)
- GitHub CLI Extension Pattern (full gh CLI usage)
- User-Friendly Output (formatted, grouped, saved)

No complexity justification needed.

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved (via /clarify)
- [x] Complexity deviations documented (none)

**Artifacts Generated**:
- [x] plan.md (this file)
- [x] research.md (GraphQL, bash, gh CLI research)
- [x] data-model.md (entities, validation, filtering)
- [x] contracts/github-graphql.md (API contract with schemas)
- [x] quickstart.md (11 manual test scenarios)
- [x] CLAUDE.md (agent context file)
- [ ] tasks.md (awaiting /tasks command)

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
*Ready for /tasks command*
