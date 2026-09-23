# Antigravity, Codex, and Claude Code in Docker

Run a CLI from the project root using npm. Requires Node.js/npm and Docker with Compose v2 and a running Linux container engine.

## Quick start

```sh
# Existing Antigravity workflow
npm start

# Build Codex, authenticate, and launch
npm run codex:build
npm run codex -- login --device-auth
npm run codex

# Build and launch Claude Code in YOLO mode
npm run claude:build
npm run claude
```

Device login uses a browser on your host and may need to be enabled in your ChatGPT security settings. See the [official Codex authentication documentation](https://developers.openai.com/codex/auth).

Codex and Claude Code mount this project's root at `/workspace`, so edits persist on your host. Arguments after `--` are passed to the CLI, for example `npm run codex -- --help` or `npm run claude -- --help`. See [Claude Docker setup](CLAUDE_DOCKER.md) for authentication, version pinning, and YOLO-mode details.

## Commands

| Command | Purpose |
| --- | --- |
| `npm start` / `npm run agy` | Run Antigravity interactively. |
| `npm run agy:build` | Build the Antigravity image. |
| `npm run agy:rebuild` | Build and run Antigravity. |
| `npm run down` | Remove Antigravity containers and network. |
| `npm run codex` | Run Codex interactively. |
| `npm run codex:build` | Build the Codex image. |
| `npm run codex:rebuild` | Build and run Codex. |
| `npm run codex:down` | Remove Codex containers and network; preserve login data. |
| `npm run claude` | Run Claude Code interactively in YOLO mode. |
| `npm run claude:build` | Build the Claude Code image. |
| `npm run claude:rebuild` | Build and run Claude Code. |
| `npm run claude:down` | Remove Claude containers and network; preserve login data. |

Run commands automatically build an image when it does not exist. Build commands reuse Docker's layer cache.

## Project structure

```text
antigravity_docker/
  Dockerfile
  docker-compose.yml
  .dockerignore
codex_docker/
  Dockerfile
  docker-compose.yml
  .dockerignore
  entrypoint.sh
claude_docker/
  Dockerfile
  docker-compose.yml
  .dockerignore
  entrypoint.sh
package.json
README.md
CLAUDE_DOCKER.md
```

## Codex

The [Codex Dockerfile](codex_docker/Dockerfile) uses `node:22-alpine`, installs the official `@openai/codex` npm package, and includes Git, Bash, ripgrep, and CA certificates. It runs as the non-root `node` user. Installation follows the [official Codex CLI documentation](https://developers.openai.com/codex/cli).

Codex is pinned to version `0.155.1`. To build another version:

```sh
npm run codex:build -- --build-arg CODEX_VERSION=<version>
```

Authentication, settings, and session data persist in the `codex-home` Docker volume, mounted at `/home/node/.codex`. This is separate from your host Codex settings. Device login avoids the need to forward a browser callback port from the container.

For API key authentication, set `OPENAI_API_KEY` in your host environment or a project-root `.env` file, then run:

```sh
docker compose -f codex_docker/docker-compose.yml run --rm --entrypoint sh codex -c 'printenv OPENAI_API_KEY | codex login --with-api-key'
```

Do not commit `.env` files containing credentials. Compose sets `CODEX_YOLO=true` by default. The container entrypoint translates this into `--dangerously-bypass-approvals-and-sandbox`, disabling Codex approval prompts and sandboxing. Set `CODEX_YOLO=false` in your host environment or project-root `.env` file to use normal permissions. Rebuild the image after changing the entrypoint with `npm run codex:rebuild`. On Linux, the workspace must be writable by the container's `node` user (UID 1000).

## Antigravity

The existing Debian Bookworm Slim image and CLI options are retained in [antigravity_docker](antigravity_docker/). The Compose configuration mounts `~/.gemini` at `/root/.gemini` and passes through `GEMINI_API_KEY` from your environment or project-root `.env` file.

For OAuth login issues, the existing commented `SSH_*` variables in [the Compose file](antigravity_docker/docker-compose.yml) can be enabled to request the remote copy/paste login flow.

Antigravity retains its existing `--dangerously-skip-permissions` default. It can modify the mounted project and mounted Gemini credentials.
