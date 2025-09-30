#!/usr/bin/env bats

# T005: Integration test - Happy path with comments found
# Scenario 1 from quickstart.md

setup() {
  # This test requires a test repository with unresolved CodeRabbit comments
  export TEST_REPO_DIR="${BATS_TEST_TMPDIR}/test-repo"
}

@test "happy path: script finds and displays unresolved CodeRabbit comments" {
  skip "Requires implementation of bin/gh-crab-comments"

  # Run the script (will fail until implemented)
  run bin/gh-crab-comments

  # Should succeed
  [ "$status" -eq 0 ]

  # Should show search message
  [[ "$output" =~ "🔍 Fetching unresolved CodeRabbit comments" ]]

  # Should show file paths with emoji
  [[ "$output" =~ "📝" ]]

  # Should show comment text
  [[ "$output" =~ "Found" ]]
}

@test "happy path: script creates output file" {
  skip "Requires implementation of bin/gh-crab-comments"

  # Run the script
  run bin/gh-crab-comments
  [ "$status" -eq 0 ]

  # Output file should exist (PR number will vary)
  [ -d ".coderabbit" ]

  # At least one output file should exist
  output_files=(.coderabbit/pr-*-comments.txt)
  [ -f "${output_files[0]}" ]
}

@test "happy path: output file contains formatted content" {
  skip "Requires implementation of bin/gh-crab-comments"

  run bin/gh-crab-comments
  [ "$status" -eq 0 ]

  # Find the output file
  output_file=$(ls .coderabbit/pr-*-comments.txt 2>/dev/null | head -1)
  [ -n "$output_file" ]

  # File should contain formatted output
  grep -q "📝" "$output_file"
  grep -q "Found" "$output_file"
}
