#!/usr/bin/env bats

# T012: Integration test - Closed/merged PR
# Scenario 8 from quickstart.md

@test "closed PR: fetches comments from closed PR" {
  skip "Requires implementation and closed test PR"

  # Run on branch of a closed PR
  run bin/gh-crab-comments

  # Should succeed regardless of PR state
  [ "$status" -eq 0 ]

  # Should fetch comments normally
  [[ "$output" =~ "🔍 Fetching" ]]
}

@test "merged PR: fetches comments from merged PR" {
  skip "Requires implementation and merged test PR"

  # Run on branch of a merged PR
  run bin/gh-crab-comments

  # Should succeed
  [ "$status" -eq 0 ]

  # No state-related errors
  ! [[ "$output" =~ "closed" ]]
  ! [[ "$output" =~ "merged" ]]
}
