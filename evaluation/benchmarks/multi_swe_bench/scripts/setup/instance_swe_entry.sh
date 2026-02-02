#!/bin/bash

source ~/.bashrc
SWEUTIL_DIR=/swe_util

# FIXME: Cannot read SWE_INSTANCE_ID from the environment variable
# SWE_INSTANCE_ID=django__django-11099
if [ -z "$SWE_INSTANCE_ID" ]; then
    echo "Error: SWE_INSTANCE_ID is not set." >&2
    exit 1
fi

if [ -z "$REPO_NAME" ]; then
    echo "Error: REPO_NAME is not set." >&2
    exit 1
fi

# Read the swe-bench-test-lite.json file and extract the required item based on instance_id
item=$(jq --arg INSTANCE_ID "$SWE_INSTANCE_ID" '.[] | select(.instance_id == $INSTANCE_ID)' $SWEUTIL_DIR/eval_data/instances/swe-bench-instance.json)

if [[ -z "$item" ]]; then
  echo "No item found for the provided instance ID."
  exit 1
fi

WORKSPACE_NAME=$(echo "$item" | jq -r '(.repo | tostring) + "__" + (.version | tostring) | gsub("/"; "__")')

echo "WORKSPACE_NAME: $WORKSPACE_NAME"

# Clear the workspace if it exists
if [ -d /workspace/$WORKSPACE_NAME ]; then
    rm -rf /workspace/$WORKSPACE_NAME
fi
mkdir -p /workspace

# Handle three possible repo locations:
# 1. /testbed - for SWE-bench Multilingual and most SWE-bench-style datasets.
# 2. /home/$REPO_NAME - for Multi-SWE-bench.
# 3. /workspace/repo (in this case don't copy it, work directly inside of it instead)
if [ -d /testbed ]; then
    cp -r /testbed /workspace/$WORKSPACE_NAME
elif [ -d /home/$REPO_NAME ]; then
    cp -r /home/$REPO_NAME /workspace/$WORKSPACE_NAME
fi

# Activate instance-specific environment
# . /opt/miniconda3/etc/profile.d/conda.sh
# conda activate testbed
