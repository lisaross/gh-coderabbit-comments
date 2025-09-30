#!/usr/bin/env bats

# T010: Integration test - Large PR with pagination
# Scenario 6 from quickstart.md

@test "pagination: handles PR with >100 review threads" {
  skip "Requires implementation and test PR with >100 threads"

  # This test needs a PR with >100 threads (or mocked responses)
  run bin/gh-crab-comments

  # Should succeed
  [ "$status" -eq 0 ]

  # Should complete in reasonable time (<30 seconds)
  # Note: bats doesn't have built-in timeout, manual testing needed
}

@test "pagination: fetches all comments across multiple pages" {
  skip "Requires implementation and test PR with >100 threads"

  run bin/gh-crab-comments

  [ "$status" -eq 0 ]

  # Should show all comments (verify count)
  # This requires knowing expected count in test PR
}
