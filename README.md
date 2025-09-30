# gh-crab-comments

Fetch unresolved CodeRabbit comments from GitHub pull requests directly from the command line.

## Features

- 🔍 Auto-detects repository and PR from your current git branch
- 📝 Filters for unresolved CodeRabbit comments only
- 💾 Saves output to `.coderabbit/pr-{number}-comments.txt` for easy reference
- ⚡ Fast pagination for large PRs (handles 1000+ comments)
- 🎯 Groups comments by file path for better readability

## Prerequisites

- **macOS** 12+ or **Linux** with Bash 4.4+
- **gh CLI** (GitHub CLI) - [Install](https://cli.github.com)
- **jq** - JSON processor
- **git** - Version control (pre-installed on macOS)

### Installation

#### Install Dependencies

```bash
# Install gh CLI
brew install gh

# Install jq
brew install jq

# Authenticate with GitHub
gh auth login
```

#### Install gh-crab-comments

```bash
# Clone the repository
git clone https://github.com/focus/gh-coderabbit-comments.git
cd gh-coderabbit-comments

# Make the script executable
chmod +x bin/gh-crab-comments

# Copy to your PATH (optional)
mkdir -p ~/bin
cp bin/gh-crab-comments ~/bin/
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Usage

### Basic Usage

Navigate to any git repository with an open PR and run:

```bash
gh-crab-comments
```

The script will:
1. Detect the current repository (owner/name)
2. Find the PR associated with your current branch
3. Fetch all unresolved CodeRabbit comments
4. Display them grouped by file path
5. Save the output to `.coderabbit/pr-{number}-comments.txt`

### Example Output

```
🔍 Fetching unresolved CodeRabbit comments from PR #123...

Found 3 unresolved CodeRabbit comments:

📝 src/utils/parser.js
   Consider using early return to reduce nesting depth.
   This will improve readability and maintainability.

📝 src/utils/parser.js
   Add error handling for null input cases.

📝 tests/parser.test.js
   Add test case for edge condition when input is empty array.

💾 Saved to: .coderabbit/pr-123-comments.txt
```

### No Comments Found

```
🔍 Fetching unresolved CodeRabbit comments from PR #124...

✅ No unresolved CodeRabbit comments found
```

## Exit Codes

- **0** - Success (comments found or no comments)
- **1** - User error (no PR found, not in git repo, authentication required)
- **2** - System error (rate limit, network failure, missing dependencies)

## Troubleshooting

### "gh: command not found"

Install GitHub CLI:
```bash
brew install gh
```

### "jq: command not found"

Install jq:
```bash
brew install jq
```

### "GitHub authentication required"

Authenticate with GitHub:
```bash
gh auth login
```

### "No PR found for current branch"

Ensure your branch has an associated PR:
```bash
# Check if PR exists
gh pr view

# If no PR, create one
gh pr create
```

### "Must be run inside a git repository"

Navigate to a git repository:
```bash
cd /path/to/your/repo
```

### Empty output but comments exist

- Verify comments are **unresolved** (not marked as resolved in GitHub UI)
- Verify comments are authored by **coderabbitai** user
- Check if your branch is up to date with the remote

### Script hangs indefinitely

- Check network connectivity
- Verify GitHub API status: https://www.githubstatus.com
- Press `Ctrl+C` to cancel

## Testing

### Run Unit Tests

```bash
# Install bats-core for testing
brew install bats-core

# Run all tests
bats tests/unit/*.bats
bats tests/integration/*.bats
```

### Manual Testing

See `specs/001-mvp-that-pulls/quickstart.md` for detailed manual testing scenarios.

## Performance

Expected performance benchmarks:

| PR Size | Comments | Expected Time |
|---------|----------|---------------|
| Small   | <50      | <5 seconds    |
| Medium  | 50-200   | <15 seconds   |
| Large   | 200-500  | <30 seconds   |

## Contributing

This is an MVP implementation. Contributions are welcome!

### Development Setup

```bash
# Clone repository
git clone https://github.com/focus/gh-coderabbit-comments.git
cd gh-coderabbit-comments

# Run tests
bats tests/

# Test script locally
./bin/gh-crab-comments
```

## License

MIT License - See LICENSE file for details

## Credits

- Built with [gh CLI](https://cli.github.com) by GitHub
- Integrates with [CodeRabbit](https://coderabbit.ai) PR reviews
- Inspired by the need for faster PR review workflows

## Roadmap

Potential future enhancements:
- [ ] Cache results with timestamp
- [ ] Incremental fetch (only new comments)
- [ ] Support for multiple PRs
- [ ] JSON output format
- [ ] Resolved comments history
- [ ] Comment threading visualization

---

**Made with ❤️ for faster PR reviews**
