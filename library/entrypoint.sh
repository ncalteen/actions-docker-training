#!/bin/bash

################################################################################
# Simple Bash shell script:
#  Please feel free to customize this file when you go through exercise
################################################################################

################################################################################
# VARS 
#   Please reference for GitHub environment varaiables:
#      https://docs.github.com/en/actions/reference/environment-variables 
################################################################################
GITHUB_EVENT_PATH="${GITHUB_EVENT_PATH}"         # Github Event Path
GITHUB_REPOSITORY="${GITHUB_REPOSITORY}"         # GitHub Org/Repo passed from system
GITHUB_RUN_ID="${GITHUB_RUN_ID}"                 # GitHub Run ID to point to logs
GITHUB_SHA="${GITHUB_SHA}"                       # GitHub sha from the commit
GITHUB_TOKEN="${GITHUB_TOKEN}"                   # GitHub Token passed from environment
GITHUB_WORKSPACE="${GITHUB_WORKSPACE}"           # Github Workspace
VAR="${VAR:-nothing}"                            # Default var

################################################################################

##################
# Run the script #
##################
echo "----------------------------------------"
echo "Welcome to this container action!"
echo "----------------------------------------"
echo ""

echo "----------------------------------------"
echo "Here's whats in the env..."
printenv
echo "----------------------------------------"

echo "You passed the Var:[${VAR}]"
