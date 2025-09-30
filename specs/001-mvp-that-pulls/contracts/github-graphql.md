# GitHub GraphQL API Contract

**Feature**: CodeRabbit Comment Fetcher MVP
**API**: GitHub GraphQL API v4
**Endpoint**: `https://api.github.com/graphql`
**Authentication**: Bearer token via `gh auth token`

---

## Query: FetchReviewThreads

### Purpose
Fetch all review threads and their comments for a specific pull request, with pagination support.

### GraphQL Schema

```graphql
query FetchReviewThreads(
  $owner: String!
  $repo: String!
  $number: Int!
  $cursor: String
) {
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

### Input Parameters

| Parameter | Type | Required | Description | Validation |
|-----------|------|----------|-------------|------------|
| `owner` | String | Yes | Repository owner (user/org login) | Match `^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$` |
| `repo` | String | Yes | Repository name | Match `^[a-zA-Z0-9._-]+$` |
| `number` | Int | Yes | Pull request number | Positive integer > 0 |
| `cursor` | String | No | Pagination cursor from previous response | Base64-encoded string or null |

**First Request**: Omit `$cursor` or pass `null`
**Subsequent Requests**: Pass `endCursor` from previous response

### Response Schema

#### Success Response (200 OK)

```json
{
  "data": {
    "repository": {
      "pullRequest": {
        "reviewThreads": {
          "pageInfo": {
            "hasNextPage": true,
            "endCursor": "Y3Vyc29yOnYyOpHOABCD1234=="
          },
          "nodes": [
            {
              "isResolved": false,
              "comments": {
                "nodes": [
                  {
                    "id": "PRRC_kwDOABC123",
                    "author": {
                      "login": "coderabbitai"
                    },
                    "bodyText": "Consider using early return to reduce nesting depth.",
                    "createdAt": "2025-09-30T14:23:45Z",
                    "path": "src/utils/parser.js"
                  },
                  {
                    "id": "PRRC_kwDOABC124",
                    "author": {
                      "login": "human-developer"
                    },
                    "bodyText": "Thanks, will fix!",
                    "createdAt": "2025-09-30T15:10:22Z",
                    "path": "src/utils/parser.js"
                  }
                ]
              }
            },
            {
              "isResolved": true,
              "comments": {
                "nodes": [
                  {
                    "id": "PRRC_kwDOABC125",
                    "author": {
                      "login": "coderabbitai"
                    },
                    "bodyText": "Add null check here.",
                    "createdAt": "2025-09-29T10:15:30Z",
                    "path": "src/main.js"
                  }
                ]
              }
            }
          ]
        }
      }
    }
  }
}
```

#### Error Responses

**Authentication Error** (401 Unauthorized):
```json
{
  "message": "Bad credentials",
  "documentation_url": "https://docs.github.com/graphql"
}
```
→ **Handling**: Exit 1, prompt user to run `gh auth login` (FR-010a)

**Rate Limiting Error** (200 OK with errors):
```json
{
  "errors": [
    {
      "type": "RATE_LIMITED",
      "message": "API rate limit exceeded",
      "extensions": {
        "resetAt": "2025-09-30T16:00:00Z"
      }
    }
  ]
}
```
→ **Handling**: Exit 2, display reset time (FR-010b)

**Resource Not Found** (200 OK with null data):
```json
{
  "data": {
    "repository": null
  },
  "errors": [
    {
      "type": "NOT_FOUND",
      "path": ["repository"],
      "message": "Could not resolve to a Repository with the name 'invalid-repo'."
    }
  ]
}
```
→ **Handling**: Exit 1, display "Repository or PR not found"

**Invalid Query** (200 OK with errors):
```json
{
  "errors": [
    {
      "message": "Field 'invalidField' doesn't exist on type 'PullRequest'",
      "locations": [{ "line": 5, "column": 7 }]
    }
  ]
}
```
→ **Handling**: Exit 2, display "GraphQL query error" (implementation bug)

### Field Descriptions

#### `reviewThreads.pageInfo`
- `hasNextPage` (Boolean): `true` if more pages exist, `false` if this is the last page
- `endCursor` (String): Opaque cursor for next page request, `null` on last page

#### `reviewThreads.nodes[]` (Review Thread)
- `isResolved` (Boolean): `true` if thread marked as resolved, `false` if still open
  - **MVP Filtering**: Only process threads where `isResolved == false` (FR-004)

#### `comments.nodes[]` (Comment)
- `id` (String): Unique comment identifier (e.g., "PRRC_kwDOABC123")
- `author.login` (String): GitHub username of comment author
  - **MVP Filtering**: Only process where `login == "coderabbitai"` (FR-005)
- `bodyText` (String): Plain text content of comment (no markdown formatting)
- `createdAt` (ISO 8601 String): UTC timestamp of comment creation
  - **MVP Sorting**: Sort comments chronologically within each thread (FR-005a)
- `path` (String): File path relative to repository root
  - **MVP Grouping**: Group comments by path in output (FR-006)

### Pagination Algorithm

```bash
# Initialize
cursor="null"
page_count=0
MAX_PAGES=100  # Constitution limit

# Pagination loop
while [ "$page_count" -lt "$MAX_PAGES" ]; do
  # Build query with or without cursor
  if [ "$cursor" = "null" ]; then
    response=$(gh api graphql \
      -f query="$GRAPHQL_QUERY" \
      -f owner="$owner" \
      -f repo="$repo" \
      -f number="$pr_number")
  else
    response=$(gh api graphql \
      -f query="$GRAPHQL_QUERY_WITH_CURSOR" \
      -f owner="$owner" \
      -f repo="$repo" \
      -f number="$pr_number" \
      -f cursor="$cursor")
  fi

  # Check for errors
  if echo "$response" | jq -e '.errors' >/dev/null; then
    # Handle error (see error handling section)
    exit 1 or exit 2
  fi

  # Process page results
  # ... (filtering, formatting)

  # Check if more pages exist
  hasNext=$(echo "$response" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage')
  [ "$hasNext" != "true" ] && break

  # Get next cursor
  cursor=$(echo "$response" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor')

  page_count=$((page_count + 1))
done

# Safety check
if [ "$page_count" -ge "$MAX_PAGES" ]; then
  echo "⚠️  Warning: Reached maximum page limit ($MAX_PAGES pages)"
fi
```

### Rate Limits

**GitHub GraphQL API**:
- **Primary rate limit**: 5,000 points per hour
- **Query cost**: ~1 point per request (this query is simple)
- **MVP usage**: ~1-10 requests per PR (typical case)

**Cost Calculation**:
- Small PR (<100 threads): 1 request = 1 point
- Large PR (1000 threads): 10 requests = 10 points
- Very large PR (10,000 threads): 100 requests = 100 points

**Rate Limit Headers** (not available in GraphQL response, use REST endpoint or handle errors):
- Detect via error response (see Error Responses section)

### Testing Strategy

#### Manual Testing
1. **Small PR** (5 comments):
   - Verify single-page fetch
   - Verify correct filtering (unresolved only, CodeRabbit only)

2. **Large PR** (200+ comments):
   - Verify pagination works
   - Verify all pages fetched

3. **Mixed authors**:
   - Verify only CodeRabbit comments included
   - Verify human replies excluded

4. **Resolved threads**:
   - Verify resolved threads excluded
   - Verify only unresolved threads processed

5. **Error cases**:
   - No PR found → Exit 1
   - Auth failure → Exit 1 with prompt
   - Rate limit → Exit 2 with reset time

#### Integration Test (bats)
```bash
# tests/integration/test_gh_api.bats

@test "Fetch PR review threads returns valid JSON" {
  run gh api graphql -f query="$QUERY" -f owner="anthropics" -f repo="test-repo" -f number=1
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.data.repository.pullRequest.reviewThreads'
}

@test "Pagination cursor works" {
  # First page
  first=$(gh api graphql -f query="$QUERY" -f owner="test" -f repo="repo" -f number=1)
  cursor=$(echo "$first" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor')

  # Second page with cursor
  second=$(gh api graphql -f query="$QUERY" -f owner="test" -f repo="repo" -f number=1 -f cursor="$cursor")
  [ $? -eq 0 ]
}
```

### Security Considerations

**Input Sanitization**:
- Owner/repo names: Validated against regex before use
- PR number: Validated as positive integer
- Cursor: Opaque string from GitHub, no validation needed (trusted source)

**Token Security**:
- Token obtained via `gh auth token` (never hardcoded)
- Token not logged or displayed
- Uses HTTPS for all API calls

**GraphQL Injection**:
- All variables passed via `-f` flag (jq handles escaping)
- No string concatenation of variables into query

### Dependencies

**Required**:
- `gh` CLI v2.0.0+ (GraphQL support)
- `jq` v1.6+ (JSON parsing)

**Verification**:
```bash
# Check gh version
gh version | grep -E 'version [2-9]'

# Check jq installed
command -v jq >/dev/null 2>&1
```

### Contract Validation

**Pre-execution checks**:
- [x] `gh` CLI installed and version ≥2.0.0
- [x] `gh auth status` succeeds (user logged in)
- [x] Repository exists and user has read access
- [x] PR number is valid positive integer

**Post-execution checks**:
- [x] Response contains `.data.repository.pullRequest`
- [x] `pageInfo` contains `hasNextPage` and `endCursor`
- [x] All threads have `isResolved` field
- [x] All comments have required fields: `id`, `author.login`, `bodyText`, `createdAt`, `path`

**Contract adherence**: This query follows GitHub GraphQL v4 schema exactly as documented at https://docs.github.com/en/graphql

---

## Summary

**Contract Type**: GitHub GraphQL API v4
**Query**: FetchReviewThreads (paginated)
**Inputs**: owner, repo, number, cursor (optional)
**Outputs**: reviewThreads with pagination info
**Error Handling**: Auth (exit 1), Rate limit (exit 2), Not found (exit 1)
**Pagination**: Cursor-based, max 100 pages
**Security**: Token via gh auth, input validation, no injection risk

**Next**: Create quickstart.md with manual test scenarios