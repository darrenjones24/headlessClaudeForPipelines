# Claude Code Docker

A Docker container for running Anthropic's Claude Code CLI with Google Cloud Vertex AI integration.

## Overview

This container packages the Claude Code CLI tool for use with Google Cloud Vertex AI, allowing you to interact with Claude's coding capabilities via command line.

## Prerequisites

- Docker installed on your system
- Google Cloud account with Vertex AI access configured
- Google Cloud SDK configured with application default credentials

## Building the Container

Build the Docker image locally:

```bash
docker build -t claude .
```

## Usage

Run the container with the following command:

```bash
docker run -it \
  -e GOOGLE_APPLICATION_CREDENTIALS="/app/.config/gcloud/application_default_credentials.json" \
  --mount type=bind,source=${HOME}/.config/gcloud,target=/app/.config/gcloud \
  -e CLAUDE_CODE_USE_VERTEX=1 \
  -e CLOUD_ML_REGION=us-east5 \
  -e ANTHROPIC_VERTEX_PROJECT_ID=ai-sre-dev-84b7 \
  -e PROMPT="your prompt here" \
  claude
```

### Environment Variables

- `GOOGLE_APPLICATION_CREDENTIALS`: Path to Google Cloud credentials within the container
- `CLAUDE_CODE_USE_VERTEX=1`: Enable Vertex AI integration
- `CLOUD_ML_REGION`: Google Cloud region for Vertex AI
- `ANTHROPIC_VERTEX_PROJECT_ID`: Your Google Cloud project ID
- `PROMPT`: Initial prompt to send to Claude Code

## Example

```bash
# Run with a simple prompt
docker run -it \
  -e GOOGLE_APPLICATION_CREDENTIALS="/app/.config/gcloud/application_default_credentials.json" \
  --mount type=bind,source=${HOME}/.config/gcloud,target=/app/.config/gcloud \
  -e CLAUDE_CODE_USE_VERTEX=1 \
  -e CLOUD_ML_REGION=us-east5 \
  -e ANTHROPIC_VERTEX_PROJECT_ID=ai-sre-dev-84b7 \
  -e PROMPT="write a hello world in python" \
  claude
```

## Container Details

- Based on Python 3.13 slim image
- Includes Node.js and npm
- Installs Claude Code CLI via npm
- Uses a custom entrypoint script to handle commands

## Mount Your Code

To work with your own code, mount your project directory:

```bash
docker run -it \
  -e GOOGLE_APPLICATION_CREDENTIALS="/app/.config/gcloud/application_default_credentials.json" \
  --mount type=bind,source=${HOME}/.config/gcloud,target=/app/.config/gcloud \
  --mount type=bind,source=/path/to/your/project,target=/workspace \
  -e CLAUDE_CODE_USE_VERTEX=1 \
  -e CLOUD_ML_REGION=us-east5 \
  -e ANTHROPIC_VERTEX_PROJECT_ID=<project id> \
  -e PROMPT="type your prompt for claude" \
  claude
```