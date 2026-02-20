#!/bin/bash

export PATH=$PATH:~/veracode-cli-2/

PROJECT_ROOT_DIR=''
PROJECT_PATH="$GITHUB_WORKSPACE/source-code/$PROJECT_ROOT_DIR"

cd $PROJECT_PATH

PARAMS=""
if [ -n "${FIX_SCA_PARAMS}" ]; then
    echo "FIX_SCA_PARAM: $FIX_SCA_PARAMS"
    PARAMS="-i $FIX_SCA_PARAMS"
fi

echo "PARAMS: $PARAMS"

veracode fix sca "$PROJECT_PATH" \
    --results $GITHUB_WORKSPACE/$SCA_RESULTS_FILE_NAME \
    --transitive \
    --decouple true \
    $PARAMS

# Check if there are any changes to existing files (excluding new files)
if [ -z "$(git diff --name-only HEAD)" ]; then
    echo "No changes to existing files detected. Skipping branch creation and PR."
    exit 0
fi

echo "run-next-step=true" >> $GITHUB_OUTPUT

echo "----- Git diff -----"
git --no-pager diff