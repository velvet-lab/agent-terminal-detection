# agent-terminal-detection

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