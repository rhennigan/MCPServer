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

RESPONSE=$(gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          pageInfo { hasNextPage }
          nodes {
            id
            isResolved
            path
            line
            comments(first: 50) {
              pageInfo { hasNextPage }
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
' -F owner="$OWNER" -F repo="$REPO" -F pr="$PR_NUMBER")

# Check for GraphQL errors
if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
  echo "Error: GraphQL query failed:" >&2
  echo "$RESPONSE" | jq -r '.errors[].message' >&2
  exit 1
fi

# Check that the pull request was found
if echo "$RESPONSE" | jq -e '.data.repository.pullRequest == null' > /dev/null 2>&1; then
  echo "Error: Pull request #${PR_NUMBER} not found in ${OWNER}/${REPO}" >&2
  exit 1
fi

# Warn if review threads were truncated
if echo "$RESPONSE" | jq -e '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage' > /dev/null 2>&1; then
  echo "Warning: More than 100 review threads exist; results are truncated." >&2
fi

# Warn if any thread has truncated comments
TRUNCATED_THREADS=$(echo "$RESPONSE" | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.comments.pageInfo.hasNextPage)] | length')
if [ "$TRUNCATED_THREADS" -gt 0 ]; then
  echo "Warning: ${TRUNCATED_THREADS} thread(s) have more than 50 comments; some comments are truncated." >&2
fi

# Output unresolved threads
echo "$RESPONSE" | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)]'
