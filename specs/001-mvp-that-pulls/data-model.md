# Data Model: CodeRabbit Comment Fetcher MVP

**Date**: 2025-09-30
**Feature**: 001-mvp-that-pulls

## Entity Definitions

### 1. Repository Context

**Purpose**: Represents the current working directory's git repository information

**Fields**:
- `owner` (string, required): GitHub organization or user login
- `name` (string, required): Repository name
- `currentBranch` (string, required): Name of current git branch

**Validation Rules**:
- `owner`: Must match pattern `^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$`
- `name`: Must match pattern `^[a-zA-Z0-9._-]+$`
- `currentBranch`: Non-empty string

**Source**: Extracted via `gh repo view --json` and `git branch --show-current`

**Relationships**:
- Has one Pull Request (via currentBranch)

---

### 2. Pull Request

**Purpose**: GitHub pull request being reviewed

**Fields**:
- `number` (integer, required): PR number
- `owner` (string, required): Repository owner (from Repository Context)
- `repo` (string, required): Repository name (from Repository Context)
- `state` (string, optional): "OPEN", "CLOSED", or "MERGED" (fetched but not used for filtering per FR-003)

**Validation Rules**:
- `number`: Positive integer > 0
- `owner`, `repo`: Inherited from Repository Context validation

**Source**: Extracted via `gh pr view --json number`

**Relationships**:
- Belongs to Repository Context
- Has many Review Threads

**Notes**:
- Per FR-003: Fetch threads regardless of PR state (open/closed/merged)
- PR state informational only, not used for filtering

---

### 3. Review Thread

**Purpose**: Conversation thread containing one or more review comments

**Fields**:
- `id` (string, implicit): Thread identifier (not explicitly stored)
- `isResolved` (boolean, required): Whether thread is marked as resolved
- `comments` (array, required): Collection of Comment entities

**Validation Rules**:
- `isResolved`: Boolean (true/false)
- `comments`: Non-empty array (threads always have ≥1 comment)

**Filtering**:
- Per FR-004: Only include threads where `isResolved == false`

**Source**: GitHub GraphQL `pullRequest.reviewThreads` query

**Relationships**:
- Belongs to Pull Request
- Has many Comments (minimum 1)

**State Transitions**:
- Unresolved → Resolved (handled externally, not by this tool)
- Tool only reads current state, doesn't modify

---

### 4. Comment

**Purpose**: Individual review comment within a thread

**Fields**:
- `id` (string, required): Unique comment identifier
- `author.login` (string, required): GitHub username of comment author
- `bodyText` (string, required): Plain text content of comment
- `createdAt` (ISO 8601 datetime, required): Timestamp when comment was created
- `path` (string, required): File path being commented on (e.g., "src/main.js")

**Validation Rules**:
- `author.login`: Non-empty string
- `bodyText`: Non-empty string (GitHub enforces this)
- `createdAt`: Valid ISO 8601 format (e.g., "2025-09-30T14:23:45Z")
- `path`: Non-empty string, typically relative file path

**Filtering**:
- Per FR-005: Only include comments where `author.login == "coderabbitai"`
- Per FR-005a: Sort by `createdAt` ascending (chronological order)

**Source**: GitHub GraphQL `reviewThread.comments` query

**Relationships**:
- Belongs to Review Thread
- Many comments can reference same `path` (grouped in output)

**Display Format** (per FR-006, FR-007, FR-012):
```
📝 {path}
   {bodyText}
   (Created: {createdAt formatted})
```

---

## Data Flow

```
1. Repository Context Detection
   ↓
   [Git working directory] → {owner, name, currentBranch}

2. Pull Request Lookup
   ↓
   [currentBranch] → gh pr view → {pr_number}

3. Review Threads Fetch (with pagination)
   ↓
   [GraphQL query] → repository.pullRequest.reviewThreads
   ↓
   Filter: isResolved == false

4. Comments Extraction
   ↓
   [For each thread] → comments array
   ↓
   Filter: author.login == "coderabbitai"
   ↓
   Sort: by createdAt ascending

5. Output Grouping
   ↓
   [Group by path] → Display + Save to file
```

---

## Storage Format

### In-Memory (during execution)

**Bash variables**:
```bash
owner="anthropics"
repo="claude-code"
pr_number=123

# Temp JSON responses (deleted on cleanup)
response=$(mktemp)  # GraphQL response JSON

# Processed output
comments_output=""  # Accumulated formatted strings
```

### Persistent (output file)

**File**: `.coderabbit/pr-{number}-comments.txt`

**Format** (per FR-006, FR-007, FR-012):
```
🔍 Found 3 unresolved CodeRabbit comments in PR #123

📝 src/utils/parser.js
   Consider using early return to reduce nesting depth.
   This will improve readability and maintainability.
   (Created: 2025-09-30 14:23:45 UTC)

📝 src/utils/parser.js
   Add error handling for null input cases.
   (Created: 2025-09-30 14:25:12 UTC)

📝 tests/parser.test.js
   Add test case for edge condition when input is empty array.
   (Created: 2025-09-30 14:26:03 UTC)

---
Saved to: .coderabbit/pr-123-comments.txt
```

**Grouping**: Comments with same `path` appear consecutively

**Ordering**: Within each file group, sorted by `createdAt` (oldest first per FR-005a)

---

## Error States

### Repository Context Errors
- **Not in git repo**: `git rev-parse` fails → Exit 1
- **No remote configured**: `gh repo view` fails → Exit 1
- **Invalid owner/name**: Validation fails → Exit 1

### Pull Request Errors
- **No PR for branch**: `gh pr view` returns empty → Exit 1 per FR-010
- **PR not found**: Invalid PR number → Exit 1

### Review Thread Errors
- **Authentication failure**: `gh auth status` fails → Exit 1 per FR-010a
- **Rate limiting**: `X-RateLimit-Remaining: 0` → Exit 2 per FR-010b
- **Network failure**: `gh api` returns non-zero → Exit 2
- **Malformed JSON**: `jq` parse error → Exit 2

### Empty States
- **No unresolved threads**: Display "✅ No unresolved comments" → Exit 0 per FR-009
- **No CodeRabbit comments**: Display "✅ No unresolved CodeRabbit comments" → Exit 0

---

## Pagination Model

**Thread Pagination**:
- Fetch 100 threads per page (GitHub max)
- Use `pageInfo.endCursor` for next page
- Stop when `pageInfo.hasNextPage == false`
- Constitution limit: Max 100 pages (10,000 threads)

**Comment Pagination**:
- Fetch 100 comments per thread (GitHub max)
- Assumption: Most threads <100 comments (MVP constraint)
- Future enhancement: Nested comment pagination if needed

**Pagination State**:
```bash
cursor="null"  # Initial state
page_count=0   # Safety counter

while [ "$page_count" -lt 100 ]; do
  # Fetch page
  # Process results
  # Update cursor
  page_count=$((page_count + 1))
done
```

---

## Summary

**Core Entities**: Repository Context, Pull Request, Review Thread, Comment

**Key Relationships**:
- Repository Context → Pull Request (1:1 via branch)
- Pull Request → Review Threads (1:many)
- Review Thread → Comments (1:many)

**Filtering Pipeline**:
1. Threads: `isResolved == false`
2. Comments: `author.login == "coderabbitai"`
3. Ordering: `createdAt` ascending
4. Grouping: By `path`

**Storage**: Ephemeral (in-memory during execution) + Persistent (output file)

**Validation**: String patterns, boolean checks, positive integers

**Error Handling**: Exit codes 0/1/2 per constitution and FR-014

**Next**: Create GraphQL contract in `contracts/github-graphql.md`