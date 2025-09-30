#!/usr/bin/env bats

# T008: Integration test - Not in git repository
# Scenario 4 from quickstart.md

@test "not in repo: displays error when run outside git repository" {
  skip "Requires implementation of bin/gh-crab-comments"

  # Change to non-git directory
  cd /tmp

  # Store original directory to reference bin/gh-crab-comments
  SCRIPT_DIR="$BATS_TEST_DIRNAME/../.."
  run "$SCRIPT_DIR/bin/gh-crab-comments"

  # Should fail with exit code 1 (user error)
  [ "$status" -eq 1 ]

  # Should show clear error message
  [[ "$output" =~ "❌ Must be run inside a git repository" ]]
}

@test "not in repo: exits with code 1" {
  skip "Requires implementation of bin/gh-crab-comments"

  cd /tmp
  SCRIPT_DIR="$BATS_TEST_DIRNAME/../.."
  run "$SCRIPT_DIR/bin/gh-crab-comments"
  [ "$status" -eq 1 ]
}
