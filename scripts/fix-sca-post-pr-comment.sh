#!/bin/bash

# Get absolute path to fix PR response file
RESULTS_FILE_PATH="$GITHUB_WORKSPACE/github_fix_pr_post_response.json"

if [ ! -f "$RESULTS_FILE_PATH" ]; then
    echo "ERROR: Fix PR response file not found at $RESULTS_FILE_PATH"
    exit 1
fi

cat $RESULTS_FILE_PATH

# Generate the complete MR comment with absolute path
COMMENT_BODY=$($GITHUB_WORKSPACE/veracode-helper/helper/scripts/post-fix-mr-comment.sh "$RESULTS_FILE_PATH" 2>&1) || { echo "ERROR: post-fix-mr-comment.sh failed"; COMMENT_BODY=""; }

COMMENT_RESPONSE=$(curl --request POST \
    --header "Authorization: Bearer $SECRETS_PAT" \
    --header "Accept: application/vnd.github+json" \
    --header "X-GitHub-Api-Version: 2022-11-28" \
    --data "{\"body\": $(echo "$COMMENT_BODY" | jq -Rs .)}" \
    "$GITHUB_API_URL/repos/$REPOSITORY_FULL_NAME/issues/$PR_NUMBER/comments")

echo "Comment response:"
echo $COMMENT_RESPONSE