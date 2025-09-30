<!--
Sync Impact Report
==================
Version: NONE → 1.0.0 (Initial constitution creation)
Rationale: MINOR bump - establishing foundational governance for new CLI tool project

Principles Added:
- I. Shell-First Development (bash script foundation)
- II. Claude Code Integration (token-efficient MCP usage)
- III. macOS Native Conventions (platform-specific UX)
- IV. GitHub CLI Extension Pattern (gh integration)
- V. User-Friendly Output (formatted, readable results)

Templates Status:
✅ plan-template.md - Constitution Check section ready for shell/CLI principles
✅ spec-template.md - No changes needed (generic feature spec)
✅ tasks-template.md - No changes needed (generic task structure)

Deferred Items:
- RATIFICATION_DATE marked as TODO (awaiting user confirmation of project start date)

Last Updated: 2025-09-30
-->

# gh-coderabbit-comments Constitution

## Core Principles

### I. Shell-First Development

Every feature MUST be implementable as a standalone bash script using standard UNIX tools.
Scripts MUST follow these requirements:

- Use `#!/usr/bin/env bash` shebang
- Include `set -e` for error propagation
- Exit codes: 0 = success, 1 = user error, 2 = system error
- No external dependencies beyond: `gh`, `jq`, standard UNIX utils
- Self-contained: one script file per feature when possible

**Rationale**: Shell scripts are transparent, debuggable, and composable. They integrate
seamlessly with macOS terminal workflows and can be inspected/modified without compilation.

### II. Claude Code Integration

All tooling MUST minimize token usage when consumed by Claude Code or other AI assistants:

- Output format: structured, parseable, no verbose decoration
- Help text: concise summaries with examples, not exhaustive manuals
- Error messages: actionable, include fix suggestions
- MCP responses: return only requested data, no metadata bloat
- Loaders/progress: suppress unless explicitly requested via flag

**Rationale**: AI coding assistants pay per-token. Verbose output inflates context windows
and increases latency. Token-efficient tools enable more work per session.

### III. macOS Native Conventions

User experience MUST follow macOS terminal best practices:

- Installation: `~/bin` or `/usr/local/bin` with PATH instructions
- Config files: `~/.config/[tool-name]/` or `~/.zshrc` integration
- Permissions: warn if `chmod +x` needed, never auto-modify
- Colors: use ANSI codes for success (green), errors (red), info (cyan)
- Emojis: ✅ ❌ 🔍 for visual scanning (fallback to text on non-UTF8)

**Rationale**: macOS users expect zsh-friendly commands, color-coded output, and
non-intrusive installations. Following platform conventions reduces friction.

### IV. GitHub CLI Extension Pattern

Tool MUST integrate as a `gh` CLI extension or standalone command:

- Authenticate via `gh auth` (no custom token management)
- Auto-detect repo context from current directory
- Support standard `gh` flags where applicable (`--json`, `--jq`)
- Respect `.github/` config conventions
- Error messages reference `gh` documentation

**Rationale**: Users already trust `gh` for authentication. Reusing its context detection
and config patterns reduces setup complexity and security surface area.

### V. User-Friendly Output

Output MUST prioritize human readability while supporting machine parsing:

- Default: formatted text with spacing, headers, visual hierarchy
- Flag `--json`: machine-readable JSON output (no decoration)
- Pagination: auto-detect terminal height, offer `--no-pager` override
- Summary stats: show counts before details (e.g., "Found 3 comments")
- Empty state: friendly message (e.g., "✅ No unresolved comments"), not silence

**Rationale**: CLI tools are primarily for humans. Good UX means users can skim results
quickly. Machine formats available via flags keep automation paths clean.

## Development Workflow

### Testing Requirements

- Manual testing: include `manual-testing.md` checklist per feature
- Shell unit tests: use `bats-core` for critical functions
- Integration tests: test against actual `gh api` in dev environment
- Error scenarios: verify all exit codes and error message formatting

### Documentation Standards

- README: installation, usage, examples, troubleshooting
- Inline comments: explain non-obvious bash patterns (e.g., GraphQL pagination)
- Help text: accessible via `--help`, shows common use cases
- Changelog: track breaking changes, new flags, deprecations

### Commit Discipline

- Format: `type(scope): description` (e.g., `feat(comments): add --json flag`)
- Scope: feature name or affected file
- Body: include before/after examples for UX changes
- Breaking changes: prefix with `BREAKING:` in commit body

## Security & Reliability

### Authentication

- NEVER store credentials in code or config
- ALWAYS use `gh auth token` for GitHub API access
- WARN users if token lacks required scopes
- FAIL safely: invalid auth → clear error, not silent failure

### Input Validation

- Sanitize all user inputs before shell interpolation
- Validate repo owner/name format before API calls
- Escape special characters in GraphQL queries
- Limit pagination to prevent infinite loops (max 100 pages)

### Error Handling

- Trap signals: `trap cleanup EXIT INT TERM`
- Cleanup temp files: use `mktemp`, remove on exit
- Network failures: retry once with backoff, then fail with message
- API errors: parse and display GitHub error details, not raw JSON

## Governance

### Amendment Process

1. Propose change via GitHub issue with rationale
2. Discuss impact on existing features
3. Update constitution and affected templates
4. Increment version per semantic versioning rules
5. Document in Sync Impact Report

### Version Policy

- **MAJOR**: Remove/redefine core principles, change shell dialect (bash → zsh)
- **MINOR**: Add new principle, expand scope (e.g., support Linux)
- **PATCH**: Clarify wording, fix examples, update dates

### Compliance Review

All PRs MUST verify:

- [ ] No external dependencies added beyond approved list
- [ ] Output format changes include `--json` flag preservation
- [ ] Help text updated if CLI flags changed
- [ ] macOS-specific paths/commands not hardcoded (use `$HOME`, `command -v`)
- [ ] Token efficiency maintained (no verbose logging by default)

**Version**: 1.0.0 | **Ratified**: TODO(RATIFICATION_DATE: awaiting user confirmation) | **Last Amended**: 2025-09-30
