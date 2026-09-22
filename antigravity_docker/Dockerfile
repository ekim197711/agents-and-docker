# Stage 1: Download & extract Antigravity CLI
FROM debian:bookworm-slim AS downloader

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    tar \
    && rm -rf /var/lib/apt/lists/*
RUN echo "DEBUG: Installing Antigravity CLIasd fdasfsdaadsfafdsafddasfsadfadsf"
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash

# Stage 2: Minimal lightweight runtime
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy the agy binary directly to standard system bin
COPY --from=downloader /root/.local/bin/agy /usr/local/bin/agy

WORKDIR /workspace

ENTRYPOINT ["agy"]
CMD ["--dangerously-skip-permissions"]
