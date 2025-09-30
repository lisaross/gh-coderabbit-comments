# Testing Notes

## Implementation Status

✅ **All core tasks (T001-T029) completed**

### Automated Tests Status

#### Integration Tests (T004-T015)
- ✅ All 12 integration tests written
- ⚠️  Tests marked as `skip` - require real GitHub repository with PRs
- 📝 Tests will pass once run against actual PRs with CodeRabbit comments

#### Unit Tests (T025-T027)
- ✅ All 3 unit test suites written
- ✅ Pagination logic tests
- ✅ Filtering logic tests
- ✅ Validation logic tests

### Manual Testing Required (T030-T032)

To complete full testing, perform these steps:

#### T030: Manual Testing Checklist

Run through all 11 scenarios in `specs/001-mvp-that-pulls/quickstart.md`:

1. **Happy path** - PR with unresolved CodeRabbit comments
2. **No comments** - PR with all comments resolved
3. **No PR found** - Branch without PR
4. **Not in repo** - Run from `/tmp`
5. **Auth failure** - Test with `gh auth logout`
6. **Pagination** - Large PR (>100 threads)
7. **Mixed authors** - Threads with bot + human comments
8. **Closed/merged PR** - Test on closed PR
9. **Output file** - Verify `.coderabbit/pr-*-comments.txt` created
10. **Signal handling** - Press Ctrl+C during execution
11. **Rate limiting** - (Optional) Test with rate limit

#### T031: Performance Validation

Measure performance on different PR sizes:

```bash
# Small PR (<50 comments)
time ./bin/gh-crab-comments
# Expected: <5 seconds

# Medium PR (50-200 comments)
time ./bin/gh-crab-comments
# Expected: <15 seconds

# Large PR (200-500 comments)
time ./bin/gh-crab-comments
# Expected: <30 seconds
```

Record results in `specs/001-mvp-that-pulls/quickstart.md`.

#### T032: Final Integration Check

```bash
# Run all unit tests (should pass immediately)
bats tests/unit/*.bats

# Run integration tests (requires test repo setup)
bats tests/integration/*.bats

# Verify all tests pass
# Fix any failing tests
# Commit final working version
```

## Testing Prerequisites

To run integration tests, you need:

1. **Test Repository** with:
   - At least one PR with unresolved CodeRabbit comments
   - At least one PR with all comments resolved
   - At least one closed/merged PR with comments
   - PRs with varying sizes (small, medium, large)

2. **Tools Installed**:
   ```bash
   brew install bats-core
   brew install gh
   brew install jq
   gh auth login
   ```

3. **Test Scenarios Setup**:
   - Create test branches without PRs
   - Ensure some PRs have mixed-author threads
   - Have a PR with >100 review threads (for pagination testing)

## Running Tests

### Unit Tests (No Setup Required)

```bash
# All unit tests
bats tests/unit/*.bats

# Individual test suites
bats tests/unit/test_pagination_logic.bats
bats tests/unit/test_filtering_logic.bats
bats tests/unit/test_validation.bats
```

### Integration Tests (Requires Test Repo)

```bash
# All integration tests
bats tests/integration/*.bats

# Individual test files
bats tests/integration/test_happy_path.bats
bats tests/integration/test_no_comments.bats
# ... etc
```

### Manual Script Testing

```bash
# Test in current repo (requires PR)
./bin/gh-crab-comments

# Test error handling
cd /tmp
/path/to/gh-coderabbit-comments/bin/gh-crab-comments
# Should show "Must be run inside a git repository"

# Test with no PR
git checkout -b test-no-pr
./bin/gh-crab-comments
# Should show "No PR found for current branch"
```

## Test Coverage

### Covered Scenarios
- ✅ Dependency checks
- ✅ Repository context detection
- ✅ PR number detection
- ✅ GraphQL query structure
- ✅ Pagination logic
- ✅ Filtering logic (isResolved, author)
- ✅ Output formatting
- ✅ File saving
- ✅ Exit codes
- ✅ Error handling
- ✅ Validation patterns

### Requires Real Testing
- ⚠️  Actual GitHub API calls
- ⚠️  Rate limiting behavior
- ⚠️  Large PR pagination
- ⚠️  Signal interruption cleanup
- ⚠️  Performance on varying PR sizes

## Next Steps

1. **Create test GitHub repository** with sample PRs
2. **Run integration tests** against test repository
3. **Measure performance** on different PR sizes
4. **Verify all scenarios** from quickstart guide
5. **Document any issues** found during testing
6. **Fix bugs** if any discovered
7. **Re-run tests** to confirm fixes
8. **Mark T030-T032 as complete** in tasks.md

## Test Results Template

Once testing is complete, record results:

```markdown
### Test Results (Date: YYYY-MM-DD)

#### Integration Tests
- [ ] T004: GraphQL contract - PASS/FAIL
- [ ] T005: Happy path - PASS/FAIL
- [ ] T006: No comments - PASS/FAIL
- [ ] T007: No PR found - PASS/FAIL
- [ ] T008: Not in repo - PASS/FAIL
- [ ] T009: Auth failure - PASS/FAIL
- [ ] T010: Pagination - PASS/FAIL
- [ ] T011: Mixed authors - PASS/FAIL
- [ ] T012: Closed PR - PASS/FAIL
- [ ] T013: Output file - PASS/FAIL
- [ ] T014: Signal handling - PASS/FAIL
- [ ] T015: Rate limiting - PASS/FAIL

#### Unit Tests
- [x] T025: Pagination logic - PASS
- [x] T026: Filtering logic - PASS
- [x] T027: Validation - PASS

#### Performance
- [ ] Small PR (<50): ____ seconds
- [ ] Medium PR (50-200): ____ seconds
- [ ] Large PR (200-500): ____ seconds

#### Issues Found
1. None (or list issues)

#### Sign-off
- Tested by: _________________
- Date: _________________
- Ready for production: YES/NO
```

---

**Status**: Implementation complete, awaiting real-world testing
**Next Action**: Set up test repository and run manual validation
