#!/usr/bin/env bats

# T013: Integration test - Output file validation
# Scenario 9 from quickstart.md

@test "output file: creates file in .coderabbit directory" {
  skip "Requires implementation of bin/gh-crab-comments"

  run bin/gh-crab-comments

  [ "$status" -eq 0 ]

  # .coderabbit directory should exist
  [ -d ".coderabbit" ]

  # Output file should exist with pattern pr-{number}-comments.txt
  output_files=(.coderabbit/pr-*-comments.txt)
  [ -f "${output_files[0]}" ]
}

@test "output file: contains terminal output content" {
  skip "Requires implementation of bin/gh-crab-comments"

  run bin/gh-crab-comments
  [ "$status" -eq 0 ]

  # Find output file
  output_file=$(ls .coderabbit/pr-*-comments.txt 2>/dev/null | head -1)
  [ -n "$output_file" ]

  # Should contain same formatted content as terminal
  file_content=$(cat "$output_file")
  [[ "$file_content" =~ "📝" ]]
}

@test "output file: is readable plain text UTF-8" {
  skip "Requires implementation of bin/gh-crab-comments"

  run bin/gh-crab-comments
  [ "$status" -eq 0 ]

  output_file=$(ls .coderabbit/pr-*-comments.txt 2>/dev/null | head -1)
  [ -n "$output_file" ]

  # Should be readable
  [ -r "$output_file" ]

  # Should be plain text (check with file command)
  file_type=$(file -b --mime-type "$output_file")
  [[ "$file_type" =~ "text/plain" ]]
}

@test "output file: persists after script exits" {
  skip "Requires implementation of bin/gh-crab-comments"

  run bin/gh-crab-comments
  [ "$status" -eq 0 ]

  output_file=$(ls .coderabbit/pr-*-comments.txt 2>/dev/null | head -1)
  [ -n "$output_file" ]

  # File should still exist
  [ -f "$output_file" ]

  # Can be read again
  cat "$output_file" > /dev/null
}
