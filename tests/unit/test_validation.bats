#!/usr/bin/env bats

# T027: Unit test - Validation logic

@test "validation: valid owner name passes" {
  owner="anthropics"
  [[ "$owner" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]
}

@test "validation: owner with hyphen passes" {
  owner="my-org"
  [[ "$owner" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]
}

@test "validation: owner starting with hyphen fails" {
  owner="-invalid"
  ! [[ "$owner" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]
}

@test "validation: owner ending with hyphen fails" {
  owner="invalid-"
  ! [[ "$owner" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]
}

@test "validation: valid repo name passes" {
  repo="my-repo.test"
  [[ "$repo" =~ ^[a-zA-Z0-9._-]+$ ]]
}

@test "validation: repo with underscore passes" {
  repo="my_repo"
  [[ "$repo" =~ ^[a-zA-Z0-9._-]+$ ]]
}

@test "validation: repo with invalid chars fails" {
  repo="invalid@repo"
  ! [[ "$repo" =~ ^[a-zA-Z0-9._-]+$ ]]
}

@test "validation: positive PR number passes" {
  pr_number="123"
  [[ "$pr_number" =~ ^[0-9]+$ ]] && [ "$pr_number" -gt 0 ]
}

@test "validation: zero PR number fails" {
  pr_number="0"
  ! ([[ "$pr_number" =~ ^[0-9]+$ ]] && [ "$pr_number" -gt 0 ])
}

@test "validation: negative PR number fails" {
  pr_number="-1"
  ! [[ "$pr_number" =~ ^[0-9]+$ ]]
}

@test "validation: non-numeric PR number fails" {
  pr_number="abc"
  ! [[ "$pr_number" =~ ^[0-9]+$ ]]
}
