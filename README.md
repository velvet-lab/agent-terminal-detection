# agent-terminal-detection

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/velvet-lab/agent-terminal-detection?style=social)](https://github.com/velvet-lab/agent-terminal-detection/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/velvet-lab/agent-terminal-detection)](https://github.com/velvet-lab/agent-terminal-detection/issues)
[![Shell](https://img.shields.io/badge/Shell-Zsh-89e051?logo=zsh&logoColor=white)](https://www.zsh.org/)
[![GitHub Forks](https://img.shields.io/github/forks/velvet-lab/agent-terminal-detection?style=social)](https://github.com/velvet-lab/agent-terminal-detection/network/members)
[![GitHub Sponsor](https://img.shields.io/github/sponsors/danlorb?label=Sponsor&logo=githubsponsors)](https://github.com/sponsors/danlorb)

Generic plugin to detect when an "agent" (e.g. Copilot) is driving the terminal.

- Environment variable set by the plugin: `AGENT_DETECTED` ("true" or "false").
- Plugin file: `agent-terminal-detection.plugin.zsh` (loads `agent-terminal-detection.zsh` in repository root).

## Install

### Oh-my-zsh

1. Clone this repository in oh-my-zsh's plugins directory:

``` bash
git clone https://github.com/velvet-lab/agent-terminal-detection.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/agent-terminal-detection
```

2. Activate the plugin in ~/.zshrc:

``` bash
plugins=(
  agent-terminal-detection
  # other plugins...
)
```

3. Restart zsh (such as by opening a new instance of your terminal emulator).

## Usage

Example `.zshrc` snippet that changes the prompt when an agent is detected:

```bash
if [[ "$AGENT_DETECTED" == "true" ]]; then
  PROMPT='$ '
  RPROMPT=''
fi
```

## Module API (for adding agents)

Agent modules live in `agents/*.sh` (top-level) and are loaded automatically by the plugin.

Registration requirement:

- Modules MUST register a detect function by appending the function name to the shared indexed
- array `AGENT_DETECT_FUNCS` so the loader can call them in order.

```bash
# in agents/myagent.sh
AGENT_DETECT_FUNCS+=(_detect_myagent)

_detect_myagent() {
  # return 0 when agent is detected, non-zero otherwise
}
```

The loader iterates elements of `AGENT_DETECT_FUNCS` in order. The loader sets `AGENT_DETECTED=true`
as soon as any registered detect function returns success (exit code 0).

Note: Legacy marker files (for example `.vscode_*` marker files) are checked once globally by the loader as a final fallback if all agent-specific detection methods fail. Agent modules should not perform the legacy marker check themselves.

## Example: Copilot

The repository includes a Copilot module at `agents/copilot.sh` which registers:

```bash
AGENT_DETECT_FUNCS+=(_detect_copilot)

_detect_copilot() { ... }
```

This module checks environment variables, `GIT_PAGER`, non-TTY input, and legacy marker files.

---
If you want, I can add example modules (`enterprise`, `other`) or move the agent list to a configuration file.

## Auto-update (optional)

The plugin exposes a safe git-based auto-update helper you can call manually or enable
on shell startup. Configuration (set these in your `~/.zshrc` before loading the plugin):

- `AGENT_TD_AUTO_UPDATE` (default: `false`) — allow update operations.
- `AGENT_TD_AUTO_UPDATE_ON_START` (default: `false`) — if `true` the plugin will check for
  updates on shell start (runs in background and respects `AGENT_TD_AUTO_UPDATE_INTERVAL_DAYS`).
- `AGENT_TD_AUTO_UPDATE_INTERVAL_DAYS` (default: `7`) — minimum days between auto-start checks.

Functions:

- `agent_terminal_detection_autoupdate` — performs a safe `git fetch` + `git pull --ff-only`
  on the plugin repository. Returns 0 on success or when already up-to-date. It will refuse to
  update if there are local changes.

Example `~/.zshrc` snippet to enable weekly auto-checks on interactive shells:

```bash
export AGENT_TD_AUTO_UPDATE=true
export AGENT_TD_AUTO_UPDATE_ON_START=true
export AGENT_TD_AUTO_UPDATE_INTERVAL_DAYS=7
plugins+=(agent-terminal-detection)
```

You can also run the update manually from a shell:

```bash
agent_terminal_detection_autoupdate
```

## Support & Sponsoring

If you find this plugin useful, please consider supporting its development:

- ⭐ **Star this repository** to show your support
- 💖 **[Become a sponsor](https://github.com/sponsors/danlorb)** to help maintain and improve the plugin
- 🐛 **[Report issues](https://github.com/velvet-lab/agent-terminal-detection/issues)** to help make it better
- 🤝 **Contribute** by submitting pull requests or adding new agent modules

Your support helps keep this project maintained and growing!

## Authors & Contributors

The original setup of this repository was done by [Roland Breitschaft](https://github.com/danlorb).

For questions or discussions, visit the [GitHub Discussions](https://github.com/orgs/velvet-lab/discussions).