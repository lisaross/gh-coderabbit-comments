#!/usr/bin/env bats

# T011: Integration test - Mixed authors in threads
# Scenario 7 from quickstart.md

@test "mixed authors: only displays CodeRabbit comments" {
  skip "Requires implementation and test PR with mixed authors"

  run bin/gh-crab-comments

  [ "$status" -eq 0 ]

  # Output should only contain CodeRabbit comments
  # Should NOT contain human replies

  # Verify filtering by checking output doesn't contain human usernames
  # This requires knowing test PR structure
}

@test "mixed authors: comments shown in chronological order within threads" {
  skip "Requires implementation and test PR with mixed authors"

  run bin/gh-crab-comments

  [ "$status" -eq 0 ]

  # Verify timestamps are in ascending order
  # Extract timestamps and verify they're sorted
}
