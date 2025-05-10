#!/bin/bash
set -e

# Print banner
echo "=================================="
echo "Claude Code Docker - Vertex AI Mode"
echo "=================================="

# Check required environment variables
required_vars=("GOOGLE_APPLICATION_CREDENTIALS" "CLAUDE_CODE_USE_VERTEX" "CLOUD_ML_REGION" "ANTHROPIC_VERTEX_PROJECT_ID")
missing_vars=()

for var in "${required_vars[@]}"; do
  if [[ -z "${!var}" ]]; then
    missing_vars+=("$var")
  fi
done

if [[ ${#missing_vars[@]} -gt 0 ]]; then
  echo "ERROR: Missing required environment variables:"
  for var in "${missing_vars[@]}"; do
    echo "  - $var"
  done
  echo ""
  echo "Please set these variables when running the container."
  exit 1
fi

# Verify credentials exist
if [[ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]]; then
  echo "ERROR: Google credentials file not found at $GOOGLE_APPLICATION_CREDENTIALS"
  echo "Make sure you mounted your gcloud credentials correctly."
  echo "Example: --mount type=bind,source=\${HOME}/.config/gcloud,target=/app/.config/gcloud"
  exit 1
fi

# Set prompt if provided
if [[ -n "$PROMPT" ]]; then
  echo "Running Claude Code with prompt: $PROMPT"
  claude --print "echo $PROMPT" --output-format json -d
else
  echo "Starting Claude Code CLI..."
  echo "No PROMPT variable provided. You can set one via -e PROMPT=\"your prompt\""
  claude --version
fi