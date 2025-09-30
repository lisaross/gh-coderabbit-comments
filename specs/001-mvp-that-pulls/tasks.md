# Tasks: CodeRabbit Comment Fetcher MVP

**Input**: Design documents from `/Users/focus/Developer/Projects/gh-coderabbit-comments/specs/001-mvp-that-pulls/`
**Prerequisites**: plan.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → ✅ Extracted: Bash 5.x, gh CLI, jq, single script structure
2. Load optional design documents:
   → ✅ data-model.md: 4 entities (Repository Context, PR, Thread, Comment)
   → ✅ contracts/: GitHub GraphQL API contract
   → ✅ research.md: Pagination patterns, bash practices, gh integration
   → ✅ quickstart.md: 11 test scenarios
3. Generate tasks by category:
   → Setup: directories, dependencies, gitignore
   → Tests: 11 integration scenarios (from quickstart)
   → Core: script skeleton, repo detection, PR detection, GraphQL, filtering, output
   → Integration: error handling, file saving, cleanup
   → Polish: unit tests, README, performance validation
4. Apply task rules:
   → Tests before implementation (TDD)
   → Setup tasks marked [P] (different files)
   → Test tasks marked [P] (independent scenarios)
   → Core tasks sequential (same script file)
5. Number tasks sequentially (T001-T032)
6. Generate dependency graph ✅
7. Create parallel execution examples ✅
8. Validate task completeness:
   → ✅ Contract has test (T004)
   → ✅ All 11 quickstart scenarios covered (T005-T015)
   → ✅ All entities validated (T016-T019)
9. Return: SUCCESS (tasks ready for execution)
```

---

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Exact file paths included in descriptions

## Path Conventions
- **Project type**: Single bash CLI tool
- **Main script**: `bin/gh-crab-comments`
- **Tests**: `tests/integration/` and `tests/unit/`
- **Output**: `.coderabbit/pr-{number}-comments.txt`

---

## Phase 3.1: Setup

- [ ] **T001** [P] Create project directory structure
  - Create `bin/` directory for main script
  - Create `tests/integration/` for integration tests
  - Create `tests/unit/` for unit tests
  - Create `.coderabbit/` directory (gitignored for output files)
  - Verify all directories created successfully

- [ ] **T002** [P] Verify dependencies and versions
  - Check `gh` CLI installed: `command -v gh`
  - Verify gh version ≥2.0.0: `gh version | grep -E 'version [2-9]'`
  - Check `jq` installed: `command -v jq`
  - Verify jq version ≥1.6: `jq --version`
  - Check `git` installed: `command -v git`
  - Check `bats-core` installed for testing: `command -v bats`
  - If any missing, output installation instructions and exit 1

- [ ] **T003** [P] Configure .gitignore
  - Add `.coderabbit/` directory to `.gitignore` (output files)
  - Add any temporary files (e.g., `*.tmp`, `.DS_Store`)
  - Commit .gitignore updates

---

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3

**CRITICAL**: These tests MUST be written and MUST FAIL before ANY implementation in Phase 3.3

### Contract Test

- [x] **T004** [P] Contract test: Verify GraphQL query structure in `tests/integration/test_graphql_contract.bats`
  - Write bats test that calls `gh api graphql` with FetchReviewThreads query
  - Use test repository (anthropics/test-repo or similar)
  - Assert response contains `.data.repository.pullRequest.reviewThreads`
  - Assert `pageInfo` contains `hasNextPage` and `endCursor`
  - Assert thread has `isResolved` field
  - Assert comments have required fields: `id`, `author.login`, `bodyText`, `createdAt`, `path`
  - Test MUST FAIL initially (no implementation yet)

### Integration Tests (from quickstart.md scenarios)

- [x] **T005** [P] Integration test: Happy path with comments found in `tests/integration/test_happy_path.bats`
  - Scenario 1 from quickstart.md
  - Setup: Mock or use test repo with PR containing unresolved CodeRabbit comments
  - Run `bin/gh-crab-comments` (will fail initially)
  - Assert output contains "🔍 Fetching unresolved CodeRabbit comments"
  - Assert output shows file paths with 📝 emoji
  - Assert output shows comment text
  - Assert file created in `.coderabbit/pr-{number}-comments.txt`
  - Assert exit code 0

- [x] **T006** [P] Integration test: No unresolved comments in `tests/integration/test_no_comments.bats`
  - Scenario 2 from quickstart.md
  - Setup: Use PR with all comments resolved
  - Run `bin/gh-crab-comments`
  - Assert output contains "✅ No unresolved CodeRabbit comments found"
  - Assert exit code 0

- [x] **T007** [P] Integration test: No PR found for branch in `tests/integration/test_no_pr.bats`
  - Scenario 3 from quickstart.md
  - Setup: Checkout branch without associated PR
  - Run `bin/gh-crab-comments`
  - Assert output contains "❌ No PR found for current branch"
  - Assert exit code 1

- [x] **T008** [P] Integration test: Not in git repository in `tests/integration/test_not_in_repo.bats`
  - Scenario 4 from quickstart.md
  - Setup: Run from non-git directory (e.g., /tmp)
  - Run `bin/gh-crab-comments`
  - Assert output contains "❌ Must be run inside a git repository"
  - Assert exit code 1

- [x] **T009** [P] Integration test: Authentication failure in `tests/integration/test_auth_failure.bats`
  - Scenario 5 from quickstart.md
  - Setup: Mock `gh auth status` to fail
  - Run `bin/gh-crab-comments`
  - Assert output contains "❌ GitHub authentication required"
  - Assert output contains "Run: gh auth login"
  - Assert exit code 1

- [x] **T010** [P] Integration test: Large PR with pagination in `tests/integration/test_pagination.bats`
  - Scenario 6 from quickstart.md
  - Setup: Use PR with >100 review threads (or mock response)
  - Run `bin/gh-crab-comments`
  - Assert pagination happens (check for multiple API calls in debug mode)
  - Assert all comments fetched
  - Assert exit code 0
  - Assert performance: completes in <30 seconds

- [x] **T011** [P] Integration test: Mixed authors in threads in `tests/integration/test_mixed_authors.bats`
  - Scenario 7 from quickstart.md
  - Setup: PR with threads containing both CodeRabbit and human comments
  - Run `bin/gh-crab-comments`
  - Assert only CodeRabbit comments shown (filter by `author.login=="coderabbitai"`)
  - Assert human replies excluded
  - Assert chronological order within threads (oldest first)
  - Assert exit code 0

- [x] **T012** [P] Integration test: Closed/merged PR in `tests/integration/test_closed_pr.bats`
  - Scenario 8 from quickstart.md
  - Setup: Use closed or merged PR with unresolved comments
  - Run `bin/gh-crab-comments`
  - Assert comments fetched (works regardless of PR state)
  - Assert no state-related errors
  - Assert exit code 0

- [x] **T013** [P] Integration test: Output file validation in `tests/integration/test_output_file.bats`
  - Scenario 9 from quickstart.md
  - Run `bin/gh-crab-comments`
  - Assert file created: `.coderabbit/pr-{number}-comments.txt`
  - Assert file contains terminal output (formatted text)
  - Assert file readable (plain text, UTF-8)
  - Assert file persists after script exits

- [x] **T014** [P] Integration test: Signal interruption (Ctrl+C) in `tests/integration/test_signal_handling.bats`
  - Scenario 10 from quickstart.md
  - Run `bin/gh-crab-comments` in background
  - Send SIGINT (Ctrl+C simulation)
  - Assert script stops cleanly
  - Assert no temp files left in `/tmp` (check for `tmp.*` pattern)
  - Assert no partial output files
  - Assert cleanup function executed

- [x] **T015** [P] Integration test: Rate limiting in `tests/integration/test_rate_limit.bats`
  - Scenario 11 from quickstart.md
  - Setup: Mock rate limit response from GraphQL API
  - Run `bin/gh-crab-comments`
  - Assert output contains "❌ GitHub API rate limit exceeded"
  - Assert output shows reset time: "Rate limit resets at: {timestamp}"
  - Assert exit code 2

---

## Phase 3.3: Core Implementation (ONLY after tests are failing)

**Prerequisites**: All Phase 3.2 tests written and failing ✅

### Script Skeleton

- [x] **T016** Create main script skeleton in `bin/gh-crab-comments`
  - Add shebang: `#!/usr/bin/env bash`
  - Add error handling: `set -e`, `set -u`, `set -o pipefail`
  - Add cleanup trap: `trap cleanup EXIT INT TERM`
  - Define `cleanup()` function (remove temp files)
  - Add dependency checks: `gh`, `jq`, `git`
  - Exit with code 2 if dependencies missing
  - Make executable: `chmod +x bin/gh-crab-comments`
  - Run tests: T002, T004 should start passing

### Repository Context Detection

- [x] **T017** Implement repository context detection in `bin/gh-crab-comments`
  - **Validates**: Repository Context entity (spec.md:L102, data-model.md)
  - Check if in git repo: `git rev-parse --is-inside-work-tree`
  - Exit code 1 with error message if not in repo (FR-010)
  - Extract owner: `gh repo view --json owner -q .owner.login`
  - Extract repo name: `gh repo view --json name -q .name`
  - Extract current branch: `git branch --show-current`
  - Validate owner/repo against regex from data-model.md (owner: `^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$`, repo: `^[a-zA-Z0-9._-]+$`)
  - Exit code 1 if validation fails
  - Run tests: T008 should pass (not in repo error)
  - **Covers**: FR-001 (auto-detect owner/name) + Repository Context entity

### PR Number Detection

- [x] **T018** Implement PR number detection in `bin/gh-crab-comments`
  - Check auth status: `gh auth status` (exit 1 if fails, prompt for `gh auth login`)
  - Get PR number: `gh pr view --json number -q .number`
  - Exit code 1 with "❌ No PR found for current branch" if empty (FR-010)
  - Validate PR number is positive integer
  - Store PR number in variable
  - Run tests: T007 (no PR), T009 (auth failure) should pass

### GraphQL Query Implementation

- [x] **T019** Implement GraphQL pagination loop in `bin/gh-crab-comments`
  - Define FetchReviewThreads query from contracts/github-graphql.md
  - Initialize: `cursor="null"`, `page_count=0`, `MAX_PAGES=100`
  - Implement pagination loop:
    - First request without cursor
    - Subsequent requests with cursor
    - Extract `hasNextPage` and `endCursor` from response
    - Break when `hasNextPage==false`
    - Safety check: break if `page_count>=MAX_PAGES`
  - Handle errors:
    - Auth error: exit 1 with prompt
    - Rate limit error: exit 2 with reset time (FR-010b)
    - Not found error: exit 1
  - Store responses in temp file (cleaned up by trap)
  - Run tests: T004 (contract), T010 (pagination), T015 (rate limit) should pass

### Filtering Logic

- [x] **T020** Implement comment filtering in `bin/gh-crab-comments`
  - Filter threads: `select(.isResolved==false)` with jq (FR-004)
  - Filter comments: `select(.author.login=="coderabbitai")` with jq (FR-005)
  - Sort comments by `createdAt` ascending within each thread (FR-005a)
  - Implement jq pipeline for filtering and sorting
  - Store filtered comments in variable or temp file
  - Run tests: T011 (mixed authors) should pass

### Output Formatting

- [x] **T021** Implement output formatting in `bin/gh-crab-comments`
  - Group comments by `path` field (FR-006)
  - Format output with emojis: 🔍, 📝, ✅, ❌ (FR-012)
  - Display file path with 📝 emoji
  - Display comment text indented (FR-007)
  - Show summary: "Found N unresolved CodeRabbit comments" before details
  - Show empty state: "✅ No unresolved CodeRabbit comments found" (FR-009)
  - Use ANSI color codes: green for success, red for errors, cyan for info
  - Run tests: T005 (happy path), T006 (no comments) should pass

### File Saving

- [x] **T022** Implement file saving in `bin/gh-crab-comments`
  - Create `.coderabbit/` directory if not exists: `mkdir -p .coderabbit`
  - Save output to `.coderabbit/pr-{number}-comments.txt` (FR-013)
  - File format: plain text with same formatting as terminal output
  - Display message: "💾 Saved to: .coderabbit/pr-{number}-comments.txt"
  - Ensure file persists after script exits
  - Run tests: T013 (output file validation) should pass

### Exit Codes

- [x] **T023** Implement exit code handling in `bin/gh-crab-comments`
  - Success (comments found or no comments): exit 0 (FR-014)
  - User error (no PR, not in repo, auth failure): exit 1 (FR-014)
  - System error (rate limit, network failure, missing deps): exit 2 (FR-014)
  - Verify all error paths use correct exit codes
  - Run tests: All integration tests should verify correct exit codes

---

## Phase 3.4: Integration

- [x] **T024** Implement signal handling and cleanup in `bin/gh-crab-comments`
  - Ensure `trap cleanup EXIT INT TERM` catches all signals
  - Cleanup function removes temp files: `rm -f "$TEMP_FILE"`
  - Test Ctrl+C during execution (no orphaned files)
  - Run tests: T014 (signal interruption) should pass

---

## Phase 3.5: Polish

### Unit Tests

- [ ] **T025** [P] Unit test: Pagination logic in `tests/unit/test_pagination_logic.bats`
  - Extract pagination loop into testable function (optional refactor)
  - Test cursor initialization: `cursor="null"`
  - Test cursor update from response
  - Test `hasNextPage==false` stops loop
  - Test max pages limit (100 pages) stops loop
  - Mock GraphQL responses for testing

- [ ] **T026** [P] Unit test: Filtering logic in `tests/unit/test_filtering_logic.bats`
  - Test `isResolved==false` filter with jq
  - Test `author.login=="coderabbitai"` filter with jq
  - Test chronological sorting by `createdAt`
  - Mock comment data for testing

- [ ] **T027** [P] Unit test: Validation logic in `tests/unit/test_validation.bats`
  - Test owner name validation regex
  - Test repo name validation regex
  - Test PR number validation (positive integer)
  - Test invalid inputs return proper errors

### Documentation

- [ ] **T028** [P] Write README.md
  - Installation instructions (copy to `~/bin`, add to PATH)
  - Usage examples: `gh-crab-comments`
  - Prerequisites: `gh`, `jq`, `git`, GitHub authentication
  - Troubleshooting section (from quickstart.md)
  - Exit codes documentation
  - Example output screenshots (text format)
  - Link to quickstart.md for detailed testing

- [ ] **T029** [P] Update CHANGELOG.md
  - Add entry for MVP release (v0.1.0 or v1.0.0)
  - List all functional requirements implemented (FR-001 through FR-014)
  - Note constitutional compliance
  - Credit CodeRabbit for review comments feature

### Manual Testing & Performance

- [ ] **T030** Run manual testing checklist from `specs/001-mvp-that-pulls/quickstart.md`
  - Execute all 11 test scenarios manually
  - Check off validation checklists in quickstart.md
  - Verify constitution compliance checklist
  - Test on real PRs with varying sizes
  - Document any issues found

- [ ] **T031** Performance validation
  - Test small PR (<50 comments): measure time with `time gh-crab-comments`
  - Assert: <5 seconds (per Technical Context)
  - Test medium PR (50-200 comments): measure time
  - Assert: <15 seconds
  - Test large PR (200-500 comments): measure time
  - Assert: <30 seconds (per Technical Context)
  - Record results in quickstart.md performance table

- [ ] **T032** Final integration check
  - Run all bats tests: `bats tests/integration/*.bats`
  - Run all bats tests: `bats tests/unit/*.bats`
  - Verify all tests pass
  - Fix any failing tests
  - Commit final working version

---

## Dependencies

```
Setup (T001-T003) → All subsequent tasks

Tests (T004-T015) → Implementation (T016-T023)
  ↓
T016 (skeleton) → T017, T018
  ↓
T017 (repo detection) + T018 (PR detection) → T019 (GraphQL)
  ↓
T019 (GraphQL) → T020 (filtering)
  ↓
T020 (filtering) → T021 (output formatting)
  ↓
T021 (output) → T022 (file saving)
  ↓
T016-T022 → T023 (exit codes)
  ↓
T023 → T024 (signal handling)
  ↓
T024 → Polish (T025-T032)

Polish tasks (T025-T029) can run in parallel [P]
T030 (manual testing) must run after T032 (all tests pass)
T031 (performance) can run in parallel with T030
```

---

## Parallel Execution Examples

### Setup Phase (all parallel)
```bash
# T001, T002, T003 can run together (different operations)
# Run in separate terminal windows or sequentially
mkdir -p bin tests/integration tests/unit .coderabbit
command -v gh && command -v jq && command -v git && command -v bats
echo ".coderabbit/" >> .gitignore
```

### Test Writing Phase (all parallel)
```bash
# T004-T015 can run together (different test files)
# Launch multiple agents in parallel:
```
Launch 12 test tasks together (T004-T015):
- Task: "Write contract test for GraphQL query structure in tests/integration/test_graphql_contract.bats per T004"
- Task: "Write integration test for happy path in tests/integration/test_happy_path.bats per T005"
- Task: "Write integration test for no comments in tests/integration/test_no_comments.bats per T006"
- Task: "Write integration test for no PR found in tests/integration/test_no_pr.bats per T007"
- Task: "Write integration test for not in repo in tests/integration/test_not_in_repo.bats per T008"
- Task: "Write integration test for auth failure in tests/integration/test_auth_failure.bats per T009"
- Task: "Write integration test for pagination in tests/integration/test_pagination.bats per T010"
- Task: "Write integration test for mixed authors in tests/integration/test_mixed_authors.bats per T011"
- Task: "Write integration test for closed PR in tests/integration/test_closed_pr.bats per T012"
- Task: "Write integration test for output file validation in tests/integration/test_output_file.bats per T013"
- Task: "Write integration test for signal handling in tests/integration/test_signal_handling.bats per T014"
- Task: "Write integration test for rate limiting in tests/integration/test_rate_limit.bats per T015"

### Polish Phase (some parallel)
```bash
# T025, T026, T027 can run together (different test files)
# T028, T029 can run together (different doc files)
```
Launch 5 polish tasks together (T025-T029):
- Task: "Write unit test for pagination logic in tests/unit/test_pagination_logic.bats per T025"
- Task: "Write unit test for filtering logic in tests/unit/test_filtering_logic.bats per T026"
- Task: "Write unit test for validation logic in tests/unit/test_validation.bats per T027"
- Task: "Write README.md with installation and usage instructions per T028"
- Task: "Update CHANGELOG.md with MVP release notes per T029"

---

## Notes

- **[P] tasks**: Different files, no dependencies, can run in parallel
- **TDD approach**: Write failing tests (T004-T015) before implementing (T016-T023)
- **Commit frequency**: Commit after completing each task or logical group
- **Test verification**: Run `bats tests/` after each implementation task to verify tests passing
- **Performance**: Monitor script execution time during development, optimize if needed
- **Avoid**:
  - Vague tasks (each task specifies exact file and action)
  - Same file conflicts (core tasks T016-T023 modify same file sequentially)
  - Premature optimization (get tests passing first, optimize later)

---

## Validation Checklist

*GATE: Verify before marking tasks complete*

- [x] All contracts have corresponding tests (T004)
- [x] All entities validated (implicit in T017-T020, validated in T027)
- [x] All tests come before implementation (T004-T015 before T016-T023)
- [x] Parallel tasks truly independent (verified: different files)
- [x] Each task specifies exact file path (✅ all tasks include paths)
- [x] No task modifies same file as another [P] task (✅ verified)
- [x] All 11 quickstart scenarios covered (T005-T015)
- [x] Exit codes mapped correctly (T023)
- [x] Performance benchmarks defined (T031)
- [x] Documentation tasks included (T028-T029)

---

## Estimated Effort

**Total tasks**: 32
**Setup**: 3 tasks (~30 min)
**Tests (TDD)**: 12 tasks (~3-4 hours to write failing tests)
**Implementation**: 8 tasks (~4-6 hours to make tests pass)
**Integration**: 1 task (~30 min)
**Polish**: 8 tasks (~2-3 hours)

**Total estimated time**: 10-14 hours for MVP completion

---

**Ready for execution**: Begin with T001 (setup) and proceed sequentially through dependencies