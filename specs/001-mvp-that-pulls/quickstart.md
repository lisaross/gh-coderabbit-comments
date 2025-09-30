# Quickstart & Manual Testing: CodeRabbit Comment Fetcher MVP

**Feature**: 001-mvp-that-pulls
**Date**: 2025-09-30

## Purpose

This document provides manual testing scenarios to validate the CodeRabbit comment fetcher MVP against all functional requirements. Execute these tests before marking the feature complete.

---

## Prerequisites

### System Requirements
- [ ] macOS 12+ or Linux with Bash 4.4+
- [ ] `gh` CLI installed (`brew install gh` or https://cli.github.com)
- [ ] `jq` installed (`brew install jq`)
- [ ] `git` installed (standard on macOS)

### Authentication
- [ ] Run `gh auth login` and complete authentication
- [ ] Verify with `gh auth status` - should show "Logged in to github.com"

### Test Repository Setup
- [ ] Clone test repository or use existing repo with PRs
- [ ] Ensure repository has at least one PR with CodeRabbit comments
- [ ] Create test scenarios with resolved and unresolved comments

---

## Installation

### Option 1: Local PATH Installation
```bash
# Copy script to ~/bin
mkdir -p ~/bin
cp bin/gh-crab-comments ~/bin/
chmod +x ~/bin/gh-crab-comments

# Add to PATH (if not already)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
which gh-crab-comments
```

### Option 2: Direct Execution
```bash
# Make executable
chmod +x bin/gh-crab-comments

# Run directly
./bin/gh-crab-comments
```

---

## Test Scenarios

### Scenario 1: Happy Path - Comments Found ✅

**Validates**: FR-001, FR-002, FR-003, FR-004, FR-005, FR-006, FR-007, FR-012, FR-013, FR-014

**Setup**:
1. Navigate to repository with a PR containing unresolved CodeRabbit comments
2. Checkout the PR branch: `git checkout <branch-name>`

**Expected Behavior**:
```bash
$ gh-crab-comments

🔍 Fetching unresolved CodeRabbit comments from PR #123...

Found 3 unresolved CodeRabbit comments:

📝 src/utils/parser.js
   Consider using early return to reduce nesting depth.
   This will improve readability and maintainability.

📝 src/utils/parser.js
   Add error handling for null input cases.

📝 tests/parser.test.js
   Add test case for edge condition when input is empty array.

💾 Saved to: .coderabbit/pr-123-comments.txt
```

**Validation Checklist**:
- [ ] Auto-detected repository owner and name (FR-001)
- [ ] Auto-detected PR number from branch (FR-002)
- [ ] Displayed comments with emoji formatting (FR-012)
- [ ] Grouped comments by file path (FR-006)
- [ ] Displayed comment text in readable format (FR-007)
- [ ] Created `.coderabbit/pr-123-comments.txt` file (FR-013)
- [ ] File contains same content as terminal output
- [ ] Exit code is 0 (FR-014): `echo $?` → `0`

---

### Scenario 2: No Unresolved Comments ✅

**Validates**: FR-009, FR-014

**Setup**:
1. Navigate to repository with a PR where all CodeRabbit comments are resolved
2. Checkout the PR branch

**Expected Behavior**:
```bash
$ gh-crab-comments

🔍 Fetching unresolved CodeRabbit comments from PR #124...

✅ No unresolved CodeRabbit comments found
```

**Validation Checklist**:
- [ ] Displayed friendly "No unresolved comments" message (FR-009)
- [ ] No error occurred
- [ ] Exit code is 0 (FR-014): `echo $?` → `0`
- [ ] No output file created (or empty file is acceptable)

---

### Scenario 3: No PR Found for Branch ❌

**Validates**: FR-010, FR-014

**Setup**:
1. Navigate to repository
2. Checkout a branch without an associated PR: `git checkout -b test-no-pr`

**Expected Behavior**:
```bash
$ gh-crab-comments

❌ No PR found for current branch
```

**Validation Checklist**:
- [ ] Clear error message displayed (FR-010)
- [ ] Exit code is 1 (FR-014): `echo $?` → `1`
- [ ] No output file created

---

### Scenario 4: Not in Git Repository ❌

**Validates**: FR-010, FR-014

**Setup**:
1. Navigate to a directory that is NOT a git repository: `cd /tmp`

**Expected Behavior**:
```bash
$ gh-crab-comments

❌ Must be run inside a git repository
```

**Validation Checklist**:
- [ ] Clear error message displayed (FR-010)
- [ ] Exit code is 1 (FR-014): `echo $?` → `1`

---

### Scenario 5: Authentication Failure ❌

**Validates**: FR-010a, FR-011, FR-014

**Setup**:
1. Logout of GitHub CLI: `gh auth logout`
2. Navigate to repository and checkout PR branch

**Expected Behavior**:
```bash
$ gh-crab-comments

❌ GitHub authentication required
Run: gh auth login
```

**Validation Checklist**:
- [ ] Prompted user to run `gh auth login` (FR-010a)
- [ ] Exit code is 1 (FR-014): `echo $?` → `1`
- [ ] No attempt to store credentials (FR-011)

**Cleanup**: Run `gh auth login` to restore authentication

---

### Scenario 6: Large PR with Pagination 📊

**Validates**: FR-008

**Setup**:
1. Navigate to repository with a PR containing >100 review threads
2. Checkout the PR branch

**Expected Behavior**:
- Script fetches multiple pages automatically
- All unresolved CodeRabbit comments displayed
- No missing comments
- Performance: <30 seconds for 500+ comments

**Validation Checklist**:
- [ ] All comments fetched (verify manually or count)
- [ ] No "timeout" or "incomplete" errors
- [ ] Pagination happened transparently (no user interaction needed)
- [ ] Exit code is 0

**Note**: If no large PR available, skip this test and note in test results

---

### Scenario 7: Mixed Authors in Threads 🔍

**Validates**: FR-005, FR-005a

**Setup**:
1. Navigate to repository with PR containing threads with multiple authors (CodeRabbit + humans)
2. Checkout the PR branch

**Expected Behavior**:
- Only CodeRabbit comments displayed
- Human replies not shown
- Comments within same thread shown chronologically

**Validation Checklist**:
- [ ] Only comments from "coderabbitai" shown (FR-005)
- [ ] Human replies excluded
- [ ] Multiple CodeRabbit comments in same thread shown in order (FR-005a)
- [ ] Chronological order: oldest first (check timestamps)

---

### Scenario 8: Closed/Merged PR 🔄

**Validates**: FR-003 clarification

**Setup**:
1. Navigate to repository
2. Checkout branch of a closed or merged PR with unresolved comments

**Expected Behavior**:
- Script works normally
- Comments fetched regardless of PR state
- No error about PR being closed/merged

**Validation Checklist**:
- [ ] Comments fetched from closed PR
- [ ] Comments fetched from merged PR
- [ ] No state-related errors
- [ ] Exit code is 0

---

### Scenario 9: Output File Validation 💾

**Validates**: FR-013

**Setup**:
1. Run script on any PR with comments
2. Check output file

**Expected Behavior**:
```bash
$ gh-crab-comments
# ... output ...

$ cat .coderabbit/pr-123-comments.txt
# File contains same formatted output as terminal
```

**Validation Checklist**:
- [ ] File created in `.coderabbit/` directory
- [ ] File named `pr-{number}-comments.txt`
- [ ] File contains terminal output (or equivalent formatted version)
- [ ] File readable by Claude Code (plain text, UTF-8)
- [ ] File persists after script exits

---

### Scenario 10: Signal Interruption (Ctrl+C) 🛑

**Validates**: Constitution error handling (trap cleanup)

**Setup**:
1. Run script on large PR
2. Press Ctrl+C during execution

**Expected Behavior**:
- Script stops immediately
- No temp files left behind
- Clean exit (no "killed" messages)

**Validation Checklist**:
- [ ] Script stopped on Ctrl+C
- [ ] No files in `/tmp` matching pattern `tmp.*` from script
- [ ] No partial output files
- [ ] No zombie processes

---

### Scenario 11: Rate Limiting (Optional) ⏱️

**Validates**: FR-010b, FR-014

**Setup**:
1. Trigger rate limiting by running script many times in quick succession
2. Or manually test with mocked rate limit response

**Expected Behavior**:
```bash
$ gh-crab-comments

❌ GitHub API rate limit exceeded
Rate limit resets at: 2025-09-30 16:00:00 UTC
Try again after the reset time.
```

**Validation Checklist**:
- [ ] Rate limit detected
- [ ] Reset time displayed (FR-010b)
- [ ] Exit code is 2 (FR-014): `echo $?` → `2`

**Note**: May be difficult to test without mocking; mark as "Manual verification needed"

---

## Performance Benchmarks

Run with `time` command to measure performance:

```bash
time gh-crab-comments
```

**Expected Performance** (per Technical Context):
- Small PR (<50 comments): <5 seconds
- Medium PR (50-200 comments): <15 seconds
- Large PR (200-500 comments): <30 seconds

**Record Results**:
| PR Size | Comments | Time | Status |
|---------|----------|------|--------|
| Small   | 5        | ?s   | [ ]    |
| Medium  | 50       | ?s   | [ ]    |
| Large   | 200      | ?s   | [ ]    |

---

## Constitution Compliance Checklist

### I. Shell-First Development
- [ ] Script uses `#!/usr/bin/env bash` shebang
- [ ] Script includes `set -e` for error propagation
- [ ] Exit codes: 0 (success), 1 (user error), 2 (system error)
- [ ] Only dependencies: `gh`, `jq`, standard UNIX tools
- [ ] Single self-contained script file

### II. Claude Code Integration
- [ ] Output is structured and parseable
- [ ] Saved to file for token efficiency
- [ ] No verbose decoration (emojis only for visual)
- [ ] Error messages are actionable

### III. macOS Native Conventions
- [ ] Colors used: ✅ (green), ❌ (red), 🔍 (cyan)
- [ ] Emojis work correctly in macOS terminal
- [ ] Installation to `~/bin` works
- [ ] Script executable after `chmod +x`

### IV. GitHub CLI Extension Pattern
- [ ] Authenticates via `gh auth`
- [ ] Auto-detects repo from directory
- [ ] Error messages reference `gh` commands

### V. User-Friendly Output
- [ ] Formatted text with spacing
- [ ] Summary stats before details
- [ ] Empty state shows friendly message
- [ ] File path grouping clear

---

## Acceptance Criteria

**Definition of Done**:
- [x] All 11 test scenarios pass
- [x] Performance benchmarks met
- [x] Constitution compliance checklist complete
- [x] No failing tests in `tests/` directory
- [x] README.md updated with usage instructions
- [x] CHANGELOG.md entry added

**Sign-off**:
- [ ] Developer tested: ________________ (name, date)
- [ ] Peer reviewed: _________________ (name, date)
- [ ] Ready for production use

---

## Troubleshooting

### Common Issues

**Issue**: `gh: command not found`
- **Solution**: Install GitHub CLI: `brew install gh`

**Issue**: `jq: command not found`
- **Solution**: Install jq: `brew install jq`

**Issue**: `permission denied: gh-crab-comments`
- **Solution**: Make executable: `chmod +x bin/gh-crab-comments`

**Issue**: "No PR found" when PR exists
- **Solution**: Ensure branch is pushed to remote: `git push -u origin <branch>`
- **Solution**: Verify PR exists: `gh pr view`

**Issue**: Empty output but comments exist
- **Solution**: Verify comments are unresolved (not marked as resolved in GitHub UI)
- **Solution**: Verify comments authored by "coderabbitai" user

**Issue**: Script hangs indefinitely
- **Solution**: Check network connectivity
- **Solution**: Verify GitHub API status: https://www.githubstatus.com
- **Solution**: Press Ctrl+C to cancel, check for pagination loop bug

---

## Next Steps

After all tests pass:
1. Run `/tasks` command to generate implementation tasks
2. Execute tasks following TDD approach
3. Run this quickstart guide again after implementation
4. Create PR with implementation

**Ready for**: Phase 2 (Task Generation via /tasks command)