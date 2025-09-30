# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-09-30

### Added - MVP Release

#### Core Features (FR-001 through FR-014)
- **FR-001**: Auto-detect git repository owner and name from current working directory
- **FR-002**: Auto-detect PR number from current branch using `gh pr view`
- **FR-003**: Fetch review threads regardless of PR state (open/closed/merged)
- **FR-004**: Filter for unresolved threads only (`isResolved == false`)
- **FR-005**: Filter for CodeRabbit comments only (`author.login == "coderabbitai"`)
- **FR-005a**: Sort comments chronologically within threads (oldest first)
- **FR-006**: Group comments by file path in output
- **FR-007**: Display comment text with indentation for readability
- **FR-008**: Support cursor-based pagination (up to 100 pages, 10,000 threads)
- **FR-009**: Display friendly empty state message when no comments found
- **FR-010**: Clear error messages for user errors (no PR, not in repo)
- **FR-010a**: Authentication error prompts user to run `gh auth login`
- **FR-010b**: Rate limiting error shows reset time
- **FR-012**: Emoji-enhanced output (🔍, 📝, ✅, ❌, 💾)
- **FR-013**: Save output to `.coderabbit/pr-{number}-comments.txt`
- **FR-014**: Proper exit codes (0=success, 1=user error, 2=system error)

#### Implementation Details
- Single bash script (`bin/gh-crab-comments`) following shell-first principles
- GraphQL API integration via GitHub CLI (`gh api graphql`)
- JSON parsing with `jq` for safe and efficient data extraction
- Cleanup trap for signal handling (EXIT, INT, TERM)
- Comprehensive error handling for all failure modes
- Performance: <5s for small PRs, <30s for large PRs (500+ comments)

#### Testing
- 12 integration tests covering all quickstart scenarios (bats)
- 3 unit test suites (pagination, filtering, validation)
- Contract tests for GitHub GraphQL API
- Manual testing checklist with 11 scenarios

#### Documentation
- Complete README with installation, usage, and troubleshooting
- Quickstart guide with manual testing scenarios
- Data model documentation
- GraphQL contract specification
- Technical research findings

### Constitutional Compliance

This release adheres to the project constitution:

#### I. Shell-First Development
- ✅ Bash 5.x with strict mode (`set -euo pipefail`)
- ✅ Single self-contained script
- ✅ Exit codes: 0 (success), 1 (user error), 2 (system error)
- ✅ Only approved dependencies: `gh`, `jq`, standard UNIX tools

#### II. Claude Code Integration
- ✅ Structured, parseable output
- ✅ File-based output for token efficiency
- ✅ Actionable error messages
- ✅ No verbose decoration

#### III. macOS Native Conventions
- ✅ Color-coded output (green, red, cyan)
- ✅ Emoji support in terminal
- ✅ Standard `~/bin` installation path
- ✅ Works with default zsh shell

#### IV. GitHub CLI Extension Pattern
- ✅ Authentication via `gh auth`
- ✅ Auto-detection from git context
- ✅ Error messages reference `gh` commands
- ✅ Seamless integration with `gh` workflows

#### V. User-Friendly Output
- ✅ Formatted text with spacing
- ✅ Summary statistics
- ✅ Friendly empty state
- ✅ Clear file path grouping

### Dependencies

- **gh** (GitHub CLI) >= 2.0.0 - For GitHub API access
- **jq** >= 1.6 - For JSON parsing
- **git** - For repository context
- **bats-core** (optional) - For running tests

### Credits

Special thanks to:
- **CodeRabbit** for providing the PR review comments that this tool fetches
- **GitHub CLI team** for excellent API and tooling
- **jq contributors** for robust JSON processing

### Known Limitations

- Assumes <100 comments per thread (nested pagination not implemented)
- No caching (fetches fresh data on every run)
- Single PR at a time (no batch processing)
- Plain text output only (no JSON export)

### Breaking Changes

N/A - Initial release

---

## [Unreleased]

### Planned Features

- Incremental fetch (only new comments since last run)
- JSON output format option
- Resolved comments history
- Cache with configurable TTL
- Batch processing for multiple PRs
- Comment threading visualization
- GitHub Actions integration
- PR comment templates

---

**Release Date**: 2025-09-30
**Initial Release**: v1.0.0 MVP
**Project**: gh-coderabbit-comments
**License**: MIT
