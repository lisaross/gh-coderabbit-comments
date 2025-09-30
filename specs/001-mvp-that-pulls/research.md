# Research: CodeRabbit Comment Fetcher MVP

**Date**: 2025-09-30
**Feature**: 001-mvp-that-pulls

## Research Areas

### 1. GraphQL Pagination Patterns

**Decision**: Use cursor-based pagination with `pageInfo.hasNextPage` and `pageInfo.endCursor`

**Rationale**:
- GitHub GraphQL API returns `pageInfo` object with:
  - `hasNextPage` (boolean): Indicates if more pages exist
  - `endCursor` (string): Cursor for next page request
- Pattern: Loop while `hasNextPage==true`, passing `endCursor` as `after` parameter
- Efficient: Only fetches needed pages, stops when complete
- Standard: GitHub's recommended pagination approach

**Implementation Pattern**:
```bash
cursor="null"
while true; do
  if [ "$cursor" = "null" ]; then
    # First request without cursor
    response=$(gh api graphql -f query='...' -f owner="$owner" -f repo="$repo" -f number="$pr")
  else
    # Subsequent requests with cursor
    response=$(gh api graphql -f query='...' -f owner="$owner" -f repo="$repo" -f number="$pr" -f cursor="$cursor")
  fi

  # Process response
  # ...

  hasNext=$(echo "$response" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage')
  cursor=$(echo "$response" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor')

  [ "$hasNext" != "true" ] && break
done
```

**Alternatives Considered**:
- Offset-based pagination: Not supported by GitHub GraphQL
- Fetch all at once: Would hit rate limits on large PRs

**Error Handling**:
- Rate limiting: Check for `X-RateLimit-Remaining: 0` header, extract reset time from `X-RateLimit-Reset`
- Network failures: `gh api` returns non-zero exit code, capture with `$?`
- Malformed JSON: `jq` returns null, check before using cursor
- Infinite loop protection: Max 100 pages per constitution (100 pages × 100 threads = 10,000 threads max)

---

### 2. Bash Best Practices

#### Signal Trapping and Cleanup

**Decision**: Use `trap` to clean up temp files on EXIT, INT, TERM signals

**Implementation Pattern**:
```bash
#!/usr/bin/env bash
set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# Temp file for intermediate data
TEMP_FILE=$(mktemp)

# Cleanup function
cleanup() {
  rm -f "$TEMP_FILE"
}

# Register cleanup on exit
trap cleanup EXIT INT TERM

# Script logic...
```

**Rationale**:
- `trap cleanup EXIT` runs on normal exit or error (due to `set -e`)
- `INT` (Ctrl+C) and `TERM` (kill signal) also trigger cleanup
- `mktemp` creates unique temp file in `/tmp`, avoids collisions
- Constitution requires: "Cleanup temp files: use `mktemp`, remove on exit"

#### `jq` Usage for Safe JSON Parsing

**Decision**: Use `jq` with `-r` (raw output) and explicit field paths

**Patterns**:
```bash
# Extract single field
owner=$(gh repo view --json owner -q .owner.login)

# Extract nested field with null handling
cursor=$(echo "$response" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor // "null"')

# Filter and map array
comments=$(echo "$response" | jq -r '
  .data.repository.pullRequest.reviewThreads.nodes[]
  | select(.isResolved==false)
  | .comments.nodes[]
  | select(.author.login=="coderabbitai")
  | "📝 \(.path)\n   \(.bodyText)\n"
')
```

**Rationale**:
- `-r` flag outputs raw strings (no JSON quotes)
- `// "null"` provides default for null values
- `select()` filters arrays inline
- String interpolation `\(field)` builds formatted output
- Safe: No shell variable interpolation in jq expressions

#### Exit Code Conventions

**Decision**: Follow constitution exit codes

**Mapping**:
- `exit 0`: Success (comments found or no comments)
- `exit 1`: User error (no PR found, not in repo, auth failure)
- `exit 2`: System error (rate limiting, network failure, jq/gh not installed)

**Implementation**:
```bash
# Check prerequisites
command -v gh >/dev/null 2>&1 || { echo "❌ gh CLI not installed"; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "❌ jq not installed"; exit 2; }

# User errors
if ! gh pr view --json number -q .number 2>/dev/null; then
  echo "❌ No PR found for current branch"
  exit 1
fi

# System errors (rate limiting)
if echo "$response" | jq -e '.errors[]? | select(.type=="RATE_LIMITED")' >/dev/null; then
  reset_time=$(echo "$response" | jq -r '.errors[0].extensions.resetAt')
  echo "❌ Rate limited. Resets at: $reset_time"
  exit 2
fi
```

---

### 3. GitHub CLI Integration

#### `gh auth token` Usage

**Decision**: Use `gh auth token` to obtain token, check `gh auth status` for validity

**Pattern**:
```bash
# Check auth status first
if ! gh auth status >/dev/null 2>&1; then
  echo "❌ GitHub authentication required"
  echo "Run: gh auth login"
  exit 1
fi

# Token is automatically used by gh api
# No need to manually extract or pass token
```

**Rationale**:
- `gh auth status` checks if user is logged in
- `gh api` automatically uses cached token
- Constitution requires: "ALWAYS use `gh auth token` for GitHub API access"
- No manual token management needed

#### Auto-detecting Repo Context

**Decision**: Use `gh repo view --json` to extract owner and repo name

**Pattern**:
```bash
# Must be run inside a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Must be run inside a git repository"
  exit 1
fi

# Extract repo context
owner=$(gh repo view --json owner -q .owner.login 2>/dev/null) || {
  echo "❌ Failed to detect repository context"
  exit 1
}

repo=$(gh repo view --json name -q .name 2>/dev/null) || {
  echo "❌ Failed to detect repository name"
  exit 1
}
```

**Rationale**:
- `gh repo view` auto-detects repo from git remote
- `--json` flag + `-q` (jq query) extracts specific fields
- Error handling: `|| { ... }` catches failures
- FR-001 requirement: "System MUST auto-detect current git repository's owner and name"

#### PR Number Detection from Branch

**Decision**: Use `gh pr view --json number` to get PR for current branch

**Pattern**:
```bash
# Get PR number for current branch
pr_number=$(gh pr view --json number -q .number 2>/dev/null)

if [ -z "$pr_number" ]; then
  echo "❌ No PR found for current branch"
  exit 1
fi

echo "🔍 Fetching comments from PR #$pr_number..."
```

**Rationale**:
- `gh pr view` without args uses current branch
- Returns PR associated with branch (if exists)
- FR-002 requirement: "System MUST auto-detect the PR number associated with the current branch"
- Clean error message if no PR exists

---

## GraphQL Query Design

**Decision**: Use nested `reviewThreads` → `comments` query with pagination

**Query Structure**:
```graphql
query($owner: String!, $repo: String!, $number: Int!, $cursor: String) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100, after: $cursor) {
        pageInfo {
          hasNextPage
          endCursor
        }
        nodes {
          isResolved
          comments(first: 100) {
            nodes {
              id
              author {
                login
              }
              bodyText
              createdAt
              path
            }
          }
        }
      }
    }
  }
}
```

**Rationale**:
- `first: 100` fetches maximum allowed per page
- `after: $cursor` enables pagination
- `isResolved` filters in bash (simpler than GraphQL `where`)
- `comments(first: 100)` handles nested comments (usually <100 per thread)
- Fields match FR-005a, FR-006, FR-007 requirements

**Filtering Strategy**:
- Filter `isResolved==false` in bash with `jq`
- Filter `author.login=="coderabbitai"` in bash with `jq`
- Rationale: Easier to debug, more flexible for MVP

---

## Performance Considerations

**Estimated API Calls**:
- Small PR (<50 threads): 1 API call
- Medium PR (50-300 threads): 1-3 API calls
- Large PR (300-1000 threads): 3-10 API calls
- Constitution limit: Max 100 API calls (10,000 threads)

**Rate Limiting**:
- GitHub GraphQL: 5,000 points per hour
- This query: ~1 point per call
- MVP: Well within limits for normal usage

**Optimization Opportunities** (post-MVP):
- Cache results with timestamp
- Incremental fetch (only new comments since last run)
- Parallel pagination (not needed for MVP)

---

## Dependencies Verification

**Required Tools**:
1. `gh` CLI ✅
   - Check: `command -v gh`
   - Install: https://cli.github.com/
   - Version: 2.0.0+ (GraphQL support)

2. `jq` ✅
   - Check: `command -v jq`
   - Install: `brew install jq` (macOS)
   - Version: 1.6+ (stable)

3. Standard UNIX tools ✅
   - `mktemp`, `rm`, `cat`, `echo` (always available)
   - `git` (required for repo detection)

**Constitution Compliance**: All dependencies approved (gh, jq, standard UNIX utils)

---

## Summary

All research complete. No remaining unknowns. Ready for Phase 1 (Design & Contracts).

**Key Decisions**:
- Cursor-based pagination with 100-page limit
- `trap` for cleanup, `jq` for safe JSON parsing
- Exit codes: 0 (success), 1 (user error), 2 (system error)
- `gh` CLI for auth and repo detection
- GraphQL query with nested `reviewThreads` → `comments`

**Next Steps**: Create data-model.md, contracts/, quickstart.md