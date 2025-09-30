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

# Copy to your PATH (required - so you can run from any repo)
mkdir -p ~/.local/bin
cp bin/gh-crab-comments ~/.local/bin/
chmod +x ~/.local/bin/gh-crab-comments

# Verify ~/.local/bin is in PATH
echo $PATH | grep -q ".local/bin" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# Verify installation
which gh-crab-comments
```

## Usage

### For Users: Interactive Command Line

From any git repository with an open PR:

```bash
# Navigate to your project repo (NOT the gh-coderabbit-comments repo)
cd /path/to/your/project-with-pr

# Run the command
gh-crab-comments
```

The script will:
1. Detect the current repository (owner/name)
2. Find the PR associated with your current branch
3. Fetch all unresolved CodeRabbit comments
4. Display them grouped by file path
5. Save the output to `.coderabbit/pr-{number}-comments.txt`

### For AI Agents: Automated Integration

AI coding assistants (like Claude Code, Cursor, Aider, etc.) can use this tool to fetch CodeRabbit feedback:

```bash
# Agent workflow: Fetch and process CodeRabbit comments
cd /path/to/project
gh-crab-comments

# Read the saved output file
cat .coderabbit/pr-$(gh pr view --json number -q .number)-comments.txt

# Parse and implement fixes
# (Agent processes comments and makes code changes)
```

**Benefits for AI Agents:**
- 🤖 **Clean, parseable output** - No HTML/UI markup, just pure comment content
- 📁 **Persistent file storage** - Comments saved for token-efficient re-reading
- 🎯 **Grouped by file** - Easy to batch-process fixes by file
- ⚡ **Fast retrieval** - No need to scrape GitHub UI or parse complex API responses
- 🔄 **Works in CI/CD** - Can be automated in GitHub Actions or other pipelines

**Example Agent Integration:**

```python
# Python example for AI agent
import subprocess
import os

def get_coderabbit_comments(repo_path):
    """Fetch CodeRabbit comments for current PR."""
    os.chdir(repo_path)

    # Run gh-crab-comments
    result = subprocess.run(['gh-crab-comments'],
                          capture_output=True,
                          text=True)

    if result.returncode == 0:
        # Get PR number and read file
        pr_num = subprocess.check_output(
            ['gh', 'pr', 'view', '--json', 'number', '-q', '.number'],
            text=True
        ).strip()

        with open(f'.coderabbit/pr-{pr_num}-comments.txt', 'r') as f:
            return f.read()

    return None

# Agent can now process comments and make fixes
comments = get_coderabbit_comments('/path/to/repo')
# ... implement fixes based on comments ...
```

### Example Output

```
🔍 Fetching unresolved CodeRabbit comments from PR #123...

Found 6 unresolved CodeRabbit comments:

📝 .gitignore
   ⚠️ Potential issue | 🟠 Major
   Don't ignore the entire .claude/ directory
   Blanket-ignoring .claude/ will prevent committing required Claude Code configs...
   Apply this diff to keep project configs tracked while excluding local files:
   -# Claude Code hooks and settings (local only)
   -.claude/
   +# Claude Code (commit project configs; ignore only local/secrets)
   +.claude/settings.local.json
   +.claude/**/secrets/**

📝 src/utils/parser.js
   ⚠️ Potential issue | 🔴 Critical
   Add error handling for null input cases.
   The function will crash if input is null or undefined...

💾 Saved to: .coderabbit/pr-123-comments.txt
```

**Output Format:**
- Comments are grouped by file path (📝 emoji prefix)
- Severity indicators included (⚠️ with 🔴 Critical / 🟠 Major / 🟡 Minor)
- Code suggestions formatted with proper indentation
- Clean, readable text without HTML markup

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
