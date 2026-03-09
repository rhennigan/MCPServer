---
name: review-pr-comments
description: >-
  Address review comments on a GitHub pull request — fetch unresolved comments,
  investigate each issue, fix valid ones, reply, and resolve threads. Use this
  skill when the user asks to review PR comments, address PR feedback, handle PR
  review, respond to reviewer comments, or fix issues raised in a pull request.
disable-model-invocation: true
argument-hint: "PR number (default: current branch's PR)"
---

# Address Pull Request Review Comments

Fetch unresolved review comments on a GitHub PR, investigate each one, fix valid issues, reply, and resolve the threads.

## Bundled Scripts

This skill includes two helper scripts in `scripts/`:

| Script | Purpose |
|--------|---------|
| `get-unresolved-comments.sh` | Fetches only unresolved review threads via GraphQL — returns thread IDs, file paths, line numbers, and comment bodies |
| `resolve-thread.sh` | Resolves a single review thread by its node ID (`PRRT_...`) via the `resolveReviewThread` GraphQL mutation |

GitHub's REST API does not expose thread resolution at all — these scripts use `gh api graphql` because it's the only programmatic path.

## Determine the PR and Repository

Use `$ARGUMENTS` as the PR number if provided. Otherwise, detect it from the current branch:

```bash
gh pr view --json number,title,url,state --jq '{number, title, url, state}'
```

If no PR is found, ask the user for the PR number.

Get the owner and repo name if unknown (the scripts need them as separate arguments):

```bash
gh repo view --json owner,name --jq '[.owner.login, .name]'
```

## Fetch Unresolved Comments

Use the bundled script to get only unresolved review threads:

```bash
bash <skill-path>/scripts/get-unresolved-comments.sh OWNER REPO PR_NUMBER
```

This returns a JSON array of unresolved threads. Each thread contains:
- `id` — the thread node ID (`PRRT_...`), needed to resolve the thread later
- `path` — file path the comment is on
- `line` — line number
- `comments` — array of `{ body, author.login, createdAt, databaseId }`

Also check for top-level issue-style comments (these live in a separate API and aren't part of review threads):

```bash
gh pr view {number} --comments --json comments
```

Skip bot-generated overview comments that list changed files without raising specific issues. Focus on comments that raise an actionable concern.

If there are no unresolved threads and no new issue-style comments, report that to the user and stop.

## Triage Each Comment

For each comment that raises a specific issue or suggests a change:

### 1. Understand the comment

Read the comment body, the file path, and the line number. Identify what the reviewer is asking for — a code fix, a docs correction, a design concern, etc.

### 2. Investigate validity

Read the relevant source files to determine whether the issue is accurate:

- **Valid issue**: The reviewer identified a real problem (bug, inconsistency, missing case, stale docs, etc.)
- **Not valid**: The reviewer misread the code, or the concern doesn't apply given context they may not have seen

### 3. Act on it

**If valid and fixable:**
- Make the fix in the source code
- Run any relevant tests or inspections to verify the fix
- Stage and commit the change with a clear commit message
- Each fix gets its own commit so the reply can reference a specific SHA

**If not valid or already addressed:**
- Prepare a reply explaining why (with specifics — point to code, cite behavior, etc.)

**If it requires a design decision or the user's judgment:**
- Flag it for the user in the summary (don't fix or reply yet)

### 4. Reply and resolve

Reply to every actionable comment, whether you fixed it or not. Use the REST API to reply on the same review thread (use the `databaseId` of the root comment in the thread):

```bash
gh api -X POST repos/{owner}/{repo}/pulls/{number}/comments/{comment_database_id}/replies \
  -f body="<your reply>"
```

Every reply must end with an attribution line:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Keep replies concise: state what you did (or why you disagree), reference the commit SHA if you made a fix, and include the attribution.

After replying to a thread where the issue has been addressed (either fixed or explained), resolve it:

```bash
bash <skill-path>/scripts/resolve-thread.sh THREAD_ID
```

where `THREAD_ID` is the `id` field from `get-unresolved-comments.sh` output (e.g. `PRRT_kwDO...`).

Do **not** resolve threads flagged for the user's judgment — leave those open.

## Push Changes

After committing all fixes, push to the PR branch. Since pushing is visible to others, confirm with the user before pushing if there's any doubt about the changes.

## Summary

After processing all comments, provide a summary listing:
- How many unresolved threads were found
- Which ones were fixed and resolved (with commit SHAs)
- Which ones were replied to and resolved without code changes (and why)
- Any threads left open for the user's judgment (design decisions, ambiguous feedback, etc.)
