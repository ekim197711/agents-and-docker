FROM node:22-bookworm-slim

ARG CLAUDE_CODE_VERSION=latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends bash ca-certificates git ripgrep \
    && npm install --global "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/* \
    && claude --version

RUN mkdir -p /workspace /home/node/.claude \
    && chown -R node:node /workspace /home/node

COPY --chmod=755 entrypoint.sh /usr/local/bin/claude-entrypoint

USER node
WORKDIR /workspace

ENTRYPOINT ["claude-entrypoint"]
