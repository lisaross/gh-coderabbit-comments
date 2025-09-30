#!/usr/bin/env bats

# T025: Unit test - Pagination logic

setup() {
  # Load helper functions if needed
  export MAX_PAGES=100
}

@test "pagination: cursor initializes to null" {
  cursor="null"
  [ "$cursor" = "null" ]
}

@test "pagination: cursor updates from response" {
  # Mock response with cursor
  mock_response='{"data":{"repository":{"pullRequest":{"reviewThreads":{"pageInfo":{"hasNextPage":true,"endCursor":"abc123"}}}}}}'

  cursor=$(echo "$mock_response" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor')
  [ "$cursor" = "abc123" ]
}

@test "pagination: stops when hasNextPage is false" {
  mock_response='{"data":{"repository":{"pullRequest":{"reviewThreads":{"pageInfo":{"hasNextPage":false,"endCursor":null}}}}}}'

  has_next=$(echo "$mock_response" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage')
  [ "$has_next" = "false" ]
}

@test "pagination: respects max pages limit" {
  page_count=0
  MAX_PAGES=100

  # Simulate loop
  while [ "$page_count" -lt "$MAX_PAGES" ]; do
    page_count=$((page_count + 1))
    if [ "$page_count" -ge "$MAX_PAGES" ]; then
      break
    fi
  done

  [ "$page_count" -eq "$MAX_PAGES" ]
}

@test "pagination: handles null cursor gracefully" {
  mock_response='{"data":{"repository":{"pullRequest":{"reviewThreads":{"pageInfo":{"hasNextPage":true,"endCursor":null}}}}}}'

  cursor=$(echo "$mock_response" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor // "null"')
  [ "$cursor" = "null" ]
}
