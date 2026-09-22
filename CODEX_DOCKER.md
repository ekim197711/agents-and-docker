# Running Codex YOLO mode in Docker

Running Codex in a container is a useful way to give it freedom to work while limiting its access to your computer. Docker provides an outer isolation boundary, and a disposable environment makes experimentation easier to recover from.

Codex's `--yolo` flag is an alias for `--dangerously-bypass-approvals-and-sandbox`. It disables approval prompts and Codex's own sandbox. Commands still operate within the permissions and resources available to the container. See the [official OpenAI documentation on agent approvals and security](https://learn.chatgpt.com/docs/agent-approvals-security).

The benefit depends on how the container is configured: every writable mount, credential, and network connection you expose remains available to the agent.

## Why a container helps

- **Less host exposure.** With narrowly scoped mounts, the agent can work on the project without directly accessing unrelated host folders, personal files, or host system configuration.
- **Fewer interruptions.** YOLO mode lets the agent edit files, run builds, and iterate on tests without command approval prompts. Docker supplies the external boundary for that autonomy.
- **A cleaner development machine.** Tools and dependencies installed in the container stay in its filesystem unless their destination is a mounted directory. Experiments do not need to alter your host's toolchain.
- **Easier resets.** You can remove and recreate the container to discard changes to its writable layer. Project files and named volumes persist separately.
- **A consistent toolchain.** A Dockerfile records the runtime and tools used by the agent, making the environment easier to recreate and share. Pinning versions improves consistency.

For example, an incorrect cleanup command can delete files the container user can write. Keeping unrelated host directories outside the container reduces the potential damage. The mounted project still needs backups and review.

## How this repository runs Codex

The [Compose configuration](codex_docker/docker-compose.yml), [Dockerfile](codex_docker/Dockerfile), and [entrypoint](codex_docker/entrypoint.sh) provide the following behavior:

| Setting | Effect |
| --- | --- |
| `CODEX_YOLO=true` by default | The entrypoint adds `--dangerously-bypass-approvals-and-sandbox`. |
| Non-root `node` user | Commands run with that user's permissions inside the container. |
| Project root mounted at `/workspace` | Project edits and deletions immediately affect the host copy. |
| `codex-home` mounted at `/home/node/.codex` | Authentication, settings, and sessions persist separately from host Codex configuration. |
| `OPENAI_API_KEY` passed through | A supplied API key is available inside the container. |
| `docker compose run --rm` in the npm script | The container is removed after exit; mounted files and the named volume remain. |

From the project root:

```sh
npm run codex:build
npm run codex -- login --device-auth
npm run codex
```

To disable this repository's automatic YOLO flag for a run in a POSIX shell:

```sh
CODEX_YOLO=false npm run codex
```

This leaves permissions to Codex's normal configuration, including any settings saved in the persistent volume. See the [README](README.md) for authentication and setup details.

## Keep the isolation meaningful

Mount only the working files the task needs. Avoid mounting your entire home directory, SSH keys, cloud credentials, or the Docker socket. Access to the Docker socket can allow control of the host through the Docker daemon. Avoid privileged containers and unnecessary host access.

Treat the mounted workspace as fully editable. Keep a backup or separate clone for valuable work, and review changes before using them. Removing a container does not undo edits to bind mounts, changes in named volumes, or actions taken against external services.

Keep credentials limited to the task. In this setup, the agent can access its persisted Codex credentials, a supplied API key, and any secrets in the mounted project, including a project-root `.env` file. This Compose configuration does not define an outbound network allowlist; Docker alone does not prevent data from being sent out.

Containers are not an absolute security boundary. Linux containers share the kernel of their Docker host, and excessive privileges or runtime vulnerabilities can weaken isolation. OpenAI recommends using this full-access container pattern only with trusted repositories because malicious project content can expose data available inside the container. See [OpenAI's container security guidance](https://learn.chatgpt.com/docs/agent-approvals-security#run-codex-in-dev-containers).

Use containerized YOLO mode when the task benefits from unattended execution and you are comfortable granting access to everything exposed inside the container. Keep Codex's sandbox enabled when that additional protection fits the workflow.
