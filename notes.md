## Create a global script

### 1. Create the script

```bash
# Create a bin directory if you don't have one
mkdir -p ~/bin

# Create the script
nano ~/bin/gh-crab-comments
```

### 2. Paste this content

```bash
#!/usr/bin/env bash
set -e

# Get current repo info
owner=$(gh repo view --json owner -q .owner.login)
repo=$(gh repo view --json name -q .name)

# Get PR number for current branch
number=$(gh pr view --json number -q .number 2>/dev/null)

if [ -z "$number" ]; then
    echo "❌ No PR found for current branch"
    exit 1
fi

echo "🔍 Fetching unresolved CodeRabbitAI comments from PR #$number..."
echo ""

# Paginated fetch
cursor=null
found=0
while :; do
    if [ "$cursor" = "null" ]; then
        resp=$(gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!) { repository(owner:$owner, name:$repo) { pullRequest(number:$number) { reviewThreads(first:100) { pageInfo { hasNextPage endCursor } nodes { isResolved comments(first:100) { nodes { id author { login } bodyText createdAt path } } } } } } }' -f owner="$owner" -f repo="$repo" -f number="$number")
    else
        resp=$(gh api graphql -f query='query($owner:String!, $repo:String!, $number:Int!, $cursor:String) { repository(owner:$owner, name:$repo) { pullRequest(number:$number) { reviewThreads(first:100, after:$cursor) { pageInfo { hasNextPage endCursor } nodes { isResolved comments(first:100) { nodes { id author { login } bodyText createdAt path } } } } } } }' -f owner="$owner" -f repo="$repo" -f number="$number" -f cursor="$cursor")
    fi
    
    result=$(echo "$resp" | jq -r '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved==false) | .comments.nodes[] | select(.author.login=="coderabbitai") | "📝 \(.path)\n   \(.bodyText)\n"')
    
    if [ -n "$result" ]; then
        echo "$result"
        found=1
    fi
    
    hasNext=$(echo "$resp" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage')
    cursor=$(echo "$resp" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor')
    
    if [ "$hasNext" != "true" ]; then break; fi
done

if [ "$found" = "0" ]; then
    echo "✅ No unresolved CodeRabbitAI comments found"
fi
```

### 3. Make it executable

```bash
chmod +x ~/bin/gh-crab-comments
```

### 4. Add to PATH (if not already)

```bash
# Add to your ~/.zshrc (or ~/.bash_profile if using bash)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

### 5. Use it

Just `cd` into any repo with a PR and run:

```bash
gh-crab-comments
```

It will:
- ✅ Auto-detect the repo and current branch
- ✅ Find the associated PR
- ✅ Fetch all unresolved CodeRabbitAI comments
- ✅ Display them nicely formatted

