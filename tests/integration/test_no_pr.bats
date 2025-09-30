#!/usr/bin/env bats

# T007: Integration test - No PR found for branch
# Scenario 3 from quickstart.md

@test "no PR: displays error message when branch has no PR" {
  skip "Requires implementation of bin/gh-crab-comments and test branch"

  # This test needs to run on a branch without a PR
  run bin/gh-crab-comments

  # Should fail with exit code 1 (user error)
  [ "$status" -eq 1 ]

  # Should show clear error message
  [[ "$output" =~ "❌ No PR found for current branch" ]]
}

@test "no PR: exits with code 1" {
  skip "Requires implementation of bin/gh-crab-comments and test branch"

  run bin/gh-crab-comments
  [ "$status" -eq 1 ]
}
