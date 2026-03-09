#!/bin/bash
# Resolves a PR review thread by its node ID.
#
# Usage: resolve-thread.sh THREAD_ID
#
# THREAD_ID: The thread node ID (PRRT_kwDO...) from get-unresolved-comments.sh output.
# Output:    JSON with the resolved thread's id and isResolved status.

set -euo pipefail

THREAD_ID="${1:?Usage: resolve-thread.sh THREAD_ID}"

gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread {
        id
        isResolved
      }
    }
  }
' -f threadId="$THREAD_ID"
