# Running Claude Code in Docker YOLO mode

Running Claude Code in a container provides an outer isolation boundary for its full-access mode. The Compose setup enables `--dangerously-skip-permissions` by default, so Claude Code can run tools and modify files without permission prompts. The container still has access to the mounted workspace, its persisted home volume, the configured API key, and the network; Docker does not make those resources safe from agent actions.

## Quick start

From the project root:

```sh
npm run claude:build
npm run claude
```

The first run prompts for Claude authentication. Claude home and settings persist in the `claude-home` Docker volume. To supply an API key, set `ANTHROPIC_API_KEY` in your environment or project-root `.env` file. Do not commit a `.env` file containing credentials.

Pass CLI arguments after `--`:

```sh
npm run claude -- --help
```

To disable the automatic YOLO flag for a run in a POSIX shell:

```sh
CLAUDE_CODE_YOLO=false npm run claude
```

This leaves permission behavior to Claude Code's normal configuration.

## Container configuration

| Setting | Effect |
| --- | --- |
| `CLAUDE_CODE_YOLO=true` by default | The entrypoint adds `--dangerously-skip-permissions`. |
| Non-root `node` user | CLI processes run without root privileges inside the container. |
| Project root mounted at `/workspace` | File edits and deletions affect the host checkout immediately. |
| `claude-home` mounted at `/home/node` | Claude authentication, settings, and other home data persist in a named volume, separate from host configuration. |
| `ANTHROPIC_API_KEY` passed through | An optional API key is available inside the container. |

The image uses `node:22-bookworm-slim` because Claude Code's Linux runtime requires glibc; Alpine uses musl. The CLI version defaults to `latest`. Pin a version for repeatable builds with `CLAUDE_CODE_VERSION`:

```sh
CLAUDE_CODE_VERSION=<version> npm run claude:build
```

## Security considerations

YOLO mode lets Claude Code act without its own permission prompts. The container is the remaining boundary, and Claude can use everything exposed to it—including project secrets, the persisted Claude home volume, and outbound network access. Keep the workspace limited to the files needed for the task; avoid mounting your home directory, SSH keys, cloud credentials, or the Docker socket. Treat the mounted project as fully editable and keep backups or a separate clone for valuable work.

Removing the container does not undo workspace edits or erase the named volume. `npm run claude:down` removes the Compose containers and network while preserving authentication data in `claude-home`; remove that volume separately if you want to delete the persisted data.

Containers are not an absolute security boundary. Use this setup only for repositories and tasks you trust, and review changes before using them.
