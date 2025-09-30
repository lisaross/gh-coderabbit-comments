#!/usr/bin/env bats

# T009: Integration test - Authentication failure
# Scenario 5 from quickstart.md

@test "auth failure: detects when gh auth is not configured" {
  skip "Requires implementation of bin/gh-crab-comments"

  # Mock gh auth status to fail
  # This would require mocking gh command or testing with logged out state
  # For real testing, user should manually test by running: gh auth logout

  run bin/gh-crab-comments

  # Should fail with exit code 1 (user error)
  [ "$status" -eq 1 ]

  # Should show auth error
  [[ "$output" =~ "❌ GitHub authentication required" ]]

  # Should prompt for login
  [[ "$output" =~ "Run: gh auth login" ]]
}

@test "auth failure: exits with code 1" {
  skip "Requires implementation and manual testing with gh auth logout"

  run bin/gh-crab-comments
  [ "$status" -eq 1 ]
}
