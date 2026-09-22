FROM node:22-alpine

ARG CODEX_VERSION=0.155.1

RUN apk add --no-cache bash ca-certificates git ripgrep \
    && npm install --global "@openai/codex@${CODEX_VERSION}" \
    && npm cache clean --force \
    && codex --version

ENV CODEX_HOME=/home/node/.codex
RUN mkdir -p /workspace /home/node/.codex \
    && chown -R node:node /workspace /home/node/.codex

COPY --chmod=755 entrypoint.sh /usr/local/bin/codex-entrypoint

USER node
WORKDIR /workspace

ENTRYPOINT ["codex-entrypoint"]
