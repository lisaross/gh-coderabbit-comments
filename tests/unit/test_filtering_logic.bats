#!/usr/bin/env bats

# T026: Unit test - Filtering logic

@test "filtering: isResolved false filter works" {
  mock_data='{"nodes":[{"isResolved":false,"comments":{"nodes":[{"author":{"login":"coderabbitai"},"bodyText":"test"}]}},{"isResolved":true,"comments":{"nodes":[{"author":{"login":"coderabbitai"},"bodyText":"resolved"}]}}]}'

  result=$(echo "$mock_data" | jq -r '.nodes[] | select(.isResolved == false) | .comments.nodes[0].bodyText')
  [ "$result" = "test" ]
}

@test "filtering: author.login coderabbitai filter works" {
  mock_data='{"nodes":[{"author":{"login":"coderabbitai"},"bodyText":"from bot"},{"author":{"login":"human"},"bodyText":"from human"}]}'

  result=$(echo "$mock_data" | jq -r '.nodes[] | select(.author.login == "coderabbitai") | .bodyText')
  [ "$result" = "from bot" ]
}

@test "filtering: excludes non-coderabbit comments" {
  mock_data='{"nodes":[{"author":{"login":"human"},"bodyText":"human comment"}]}'

  result=$(echo "$mock_data" | jq -r '.nodes[] | select(.author.login == "coderabbitai") | .bodyText' || echo "")
  [ -z "$result" ]
}

@test "filtering: chronological sorting by createdAt" {
  mock_data='{"nodes":[{"createdAt":"2025-09-30T15:00:00Z","bodyText":"second"},{"createdAt":"2025-09-30T14:00:00Z","bodyText":"first"}]}'

  result=$(echo "$mock_data" | jq -r '.nodes | sort_by(.createdAt) | .[0].bodyText')
  [ "$result" = "first" ]
}

@test "filtering: handles empty nodes array" {
  mock_data='{"nodes":[]}'

  result=$(echo "$mock_data" | jq -r '.nodes[] | select(.author.login == "coderabbitai") | .bodyText' || echo "empty")
  [ "$result" = "empty" ]
}
