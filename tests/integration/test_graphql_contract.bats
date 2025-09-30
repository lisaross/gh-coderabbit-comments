#!/usr/bin/env bats

# T004: Contract test - Verify GraphQL query structure
# This test validates the GitHub GraphQL API contract

setup() {
  # Load the query from the main script once it exists
  QUERY='query FetchReviewThreads($owner: String!, $repo: String!, $number: Int!, $cursor: String) {
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
}'
}

@test "GraphQL query returns valid structure with pageInfo" {
  # Use a known public repository for testing
  # Replace with actual test repository that has PRs
  skip "Requires test repository setup"

  response=$(gh api graphql -f query="$QUERY" \
    -f owner="anthropics" \
    -f repo="anthropic-sdk-typescript" \
    -f number=1)

  # Verify response contains expected structure
  echo "$response" | jq -e '.data.repository.pullRequest.reviewThreads'
  echo "$response" | jq -e '.data.repository.pullRequest.reviewThreads.pageInfo'
  echo "$response" | jq -e '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage'
  echo "$response" | jq -e '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor'
}

@test "GraphQL query includes required thread fields" {
  skip "Requires test repository setup"

  response=$(gh api graphql -f query="$QUERY" \
    -f owner="anthropics" \
    -f repo="anthropic-sdk-typescript" \
    -f number=1)

  # Verify thread has isResolved field
  echo "$response" | jq -e '.data.repository.pullRequest.reviewThreads.nodes[0].isResolved'
}

@test "GraphQL query includes required comment fields" {
  skip "Requires test repository setup"

  response=$(gh api graphql -f query="$QUERY" \
    -f owner="anthropics" \
    -f repo="anthropic-sdk-typescript" \
    -f number=1)

  # Verify comments have all required fields
  echo "$response" | jq -e '.data.repository.pullRequest.reviewThreads.nodes[0].comments.nodes[0].id'
  echo "$response" | jq -e '.data.repository.pullRequest.reviewThreads.nodes[0].comments.nodes[0].author.login'
  echo "$response" | jq -e '.data.repository.pullRequest.reviewThreads.nodes[0].comments.nodes[0].bodyText'
  echo "$response" | jq -e '.data.repository.pullRequest.reviewThreads.nodes[0].comments.nodes[0].createdAt'
  echo "$response" | jq -e '.data.repository.pullRequest.reviewThreads.nodes[0].comments.nodes[0].path'
}
