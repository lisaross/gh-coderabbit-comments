#!/usr/bin/env bats

# T006: Integration test - No unresolved comments
# Scenario 2 from quickstart.md

@test "no comments: displays friendly empty state message" {
  skip "Requires implementation of bin/gh-crab-comments and test setup"

  # This test needs a PR with all comments resolved
  run bin/gh-crab-comments

  # Should succeed (exit 0)
  [ "$status" -eq 0 ]

  # Should show friendly message
  [[ "$output" =~ "✅ No unresolved CodeRabbit comments found" ]]
}

@test "no comments: exits with code 0" {
  skip "Requires implementation of bin/gh-crab-comments and test setup"

  run bin/gh-crab-comments
  [ "$status" -eq 0 ]
}
