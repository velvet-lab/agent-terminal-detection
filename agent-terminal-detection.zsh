#!/usr/bin/env zsh
# shellcheck disable=all

# Generic Agent Terminal Detection loader + helpers (root loader)
# This file loads per-agent modules from `functions/agents/*.sh` and
# `agents/*.sh` (top-level) and exposes `_runs_a_agent_in_terminal`.

# Registration of detection functions.
# Modules should append detection function names to the indexed array
# `AGENT_DETECT_FUNCS` (for example: `AGENT_DETECT_FUNCS+=(_detect_myagent)`).
# The runner iterates the array in order.

# Shared helper: check for legacy marker files (backward compatibility)
_agent_check_legacy_marker() {
    local temp_dir="${TMPDIR:-/tmp}"
    local current_pid=$$
    local parent_pid=$PPID

    local prefixes=(".vscode_copilot_agent_" ".vscode_agent_")

    for pid in $current_pid $parent_pid; do
        for prefix in "${prefixes[@]}"; do
            local marker_file="$temp_dir/$prefix$pid"
            if [[ -f "$marker_file" ]]; then
                if grep -q '"isAgentSession":true' "$marker_file" 2>/dev/null; then
                    return 0
                fi
            fi
        done
    done

    return 1
}

# Determine this file's directory reliably in zsh
_agent_script_path="${(%):-%N}"
_agent_script_dir="${_agent_script_path:A:h}"

# Load agent modules from both `functions/agents` (next to this file)
# and from the repository top-level `agents/` directory, if present.
for agent_dir in "${_agent_script_dir}/functions/agents" "${_agent_script_dir}/agents"; do
    if [[ -d "$agent_dir" ]]; then
        for f in "$agent_dir"/*.sh; do
            [[ -r "$f" ]] || continue
            source "$f"
        done
    fi
done

# Generic runner: call each agent's detection function in order
_runs_a_agent_in_terminal() {
    local func

    # Each element of `AGENT_DETECT_FUNCS` is a detection function name.
    for func in "${AGENT_DETECT_FUNCS[@]}"; do
        if [[ -z "$func" ]]; then
            continue
        fi

        if type "$func" >/dev/null 2>&1; then
            if "$func"; then
                return 0
            fi
        fi
    done

    # Final fallback: perform a single legacy marker file check once for the whole loader
    if _agent_check_legacy_marker; then
        return 0
    fi

    return 1
}
