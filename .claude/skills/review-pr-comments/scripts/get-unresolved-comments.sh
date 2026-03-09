#!/bin/bash
# Fetches unresolved review thread comments for a GitHub PR.
#
# Usage: get-unresolved-comments.sh OWNER REPO PR_NUMBER
#
# Output: JSON array of unresolved threads with their comments, paths, and IDs.
# Each thread includes:
#   - id:         Thread node ID (PRRT_...) used to resolve the thread
#   - path:       File path the comment is on
#   - line:       Line number in the diff
#   - comments:   Array of comments in the thread (body, author, createdAt, databaseId)

set -euo pipefail

OWNER="${1:?Usage: get-unresolved-comments.sh OWNER REPO PR_NUMBER}"
REPO="${2:?Usage: get-unresolved-comments.sh OWNER REPO PR_NUMBER}"
PR_NUMBER="${3:?Usage: get-unresolved-comments.sh OWNER REPO PR_NUMBER}"

gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            path
            line
            comments(first: 50) {
              nodes {
                body
                databaseId
                createdAt
                author { login }
              }
            }
          }
        }
      }
    }
  }
' -F owner="$OWNER" -F repo="$REPO" -F pr="$PR_NUMBER" \
  --jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)]'
