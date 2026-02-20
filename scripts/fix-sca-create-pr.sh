#!/bin/bash

cd $GITHUB_WORKSPACE/source-code

echo "Generating current changes diff..."
CURRENT_DIFF=$(git --no-pager diff --no-color HEAD)
CURRENT_DIFF_HASH=$(echo "$CURRENT_DIFF" | sha256sum | awk '{print $1}')
CURRENT_DIFF_SHORT_HASH=$(echo $CURRENT_DIFF_HASH | cut -c1-8)
echo "Current diff short hash: $CURRENT_DIFF_SHORT_HASH"

# Create new branch for Fix Pull Request
BRANCH_NAME="$FIX_PR_BRANCH_PREFIX-$CURRENT_DIFF_SHORT_HASH-$SOURCE_BRANCH" # Use diff short hash for unique PR branch name
git checkout -b ${BRANCH_NAME}

# Open Pull Request with SCA fix results
git config user.name "Veracode SCA Fix Bot"
git config user.email "sca-fix@veracode.com" # Not a real email, change this when one exists

# Create Pull Request
git status
git add -u # Add all changes to tracked files
git commit -m "${FIX_PR_COMMIT_MESSAGE}"
git push origin $BRANCH_NAME

PR_DESCRIPTION=""

GITHUB_PR_POST_RESPONSE=$(curl -X POST \
    -H "Authorization: Bearer $SECRETS_PAT" \
    -H "Content-Type: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -d "$(jq -n \
    --arg title "[Veracode Fix for SCA] $BRANCH_NAME" \
    --arg body "$PR_DESCRIPTION" \
    --arg head "$BRANCH_NAME" \
    --arg base "$SOURCE_BRANCH" \
    '{title: $title, body: $body, head: $head, base: $base}')" \
    "$GITHUB_API_URL/repos/$REPOSITORY_FULL_NAME/pulls")

echo "Github PR Post Response"
echo $GITHUB_PR_POST_RESPONSE | tee $GITHUB_WORKSPACE/github_fix_pr_post_response.json

echo "run-next-step=true" >> $GITHUB_OUTPUT