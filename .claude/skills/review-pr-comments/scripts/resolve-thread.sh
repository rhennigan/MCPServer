#!/bin/bash
# Resolves a PR review thread by its node ID.
#
# Usage: resolve-thread.sh THREAD_ID
#
# THREAD_ID: The thread node ID (PRRT_kwDO...) from get-unresolved-comments.sh output.
# Output:    JSON with the resolved thread's id and isResolved status.

set -euo pipefail

THREAD_ID="${1:?Usage: resolve-thread.sh THREAD_ID}"

RESPONSE=$(gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread {
        id
        isResolved
      }
    }
  }
' -f threadId="$THREAD_ID")

# Check for GraphQL errors (GitHub can return HTTP 200 with an errors array)
if echo "$RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
  echo "Error: resolveReviewThread mutation failed:" >&2
  echo "$RESPONSE" | jq -r '.errors[].message' >&2
  exit 1
fi

# Verify the thread was actually resolved
if ! echo "$RESPONSE" | jq -e '.data.resolveReviewThread.thread.isResolved == true' > /dev/null 2>&1; then
  echo "Error: Thread was not resolved (isResolved is not true):" >&2
  echo "$RESPONSE" | jq . >&2
  exit 1
fi

echo "$RESPONSE"
