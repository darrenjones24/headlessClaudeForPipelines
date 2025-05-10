# Dockerfile for Claude Code CLI with Vertex AI

# ARG declarations for versions (can be overridden at build time)
ARG PYTHON_VERSION=3.13-slim
ARG NODE_VERSION_BUILDER=20-slim # Node.js version for the builder stage
ARG NODE_MAJOR_VERSION_RUNTIME=20 # Node.js major version for the final runtime stage
ARG APP_USER=claudeuser
ARG APP_GROUP=claudegroup

# ---- Builder Stage ----
# Used to compile Node.js native dependencies and install global CLIs
# This keeps build tools out of the final image.
FROM node:${NODE_VERSION_BUILDER} AS builder

LABEL stage="builder"

# Set environment variables for npm
ENV NPM_CONFIG_LOGLEVEL warn
ENV PATH /usr/local/bin:$PATH # Ensure npm global binaries are findable

# Install build dependencies required for native Node modules 
# python3-dev is often needed by node-gyp.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        python3-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI and its dependencies globally.
RUN npm install -g better-sqlite3 && \
    npm install -g @anthropic-ai/claude-code && \
    npm cache clean --force

# ---- Final Runtime Stage ----
FROM python:${PYTHON_VERSION}

LABEL stage="runtime"

# Re-declare ARGs if used in this stage (standard practice)
ARG APP_USER
ARG APP_GROUP
ARG NODE_MAJOR_VERSION_RUNTIME


# Install runtime dependencies:
# - bash: For the entrypoint script.
# - ca-certificates: For HTTPS connections.
# - curl & gnupg: Temporarily, to add NodeSource repository for Node.js.
# - nodejs: Runtime for the Claude Code CLI.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        gnupg && \
    # Add NodeSource repository for Node.js
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR_VERSION_RUNTIME}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    # Clean up packages used only for Node.js installation and apt caches
    apt-get purge -y --auto-remove curl gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the globally installed Node.js modules and executables from the builder stage.
# This includes the pre-compiled native modules.
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=builder /usr/local/bin /usr/local/bin

# Ensure Node.js can find the copied global modules.
ENV NODE_PATH=/usr/local/lib/node_modules

# Set up the working directory for code projects.
# Create it and set ownership before switching user.
WORKDIR /workspace


# Copy the entrypoint script.
# It's placed in /usr/local/bin, which is standard for custom scripts.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh # Make it executable by all.

# Set the default command to run when the container starts.
ENTRYPOINT ["entrypoint.sh"]
