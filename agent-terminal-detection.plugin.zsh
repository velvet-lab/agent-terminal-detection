#!/usr/bin/env zsh
# Oh My Zsh Plugin: Agent Terminal Detection (Generic)
# Detects if the current terminal is controlled by an agent
# Sets AGENT_DETECTED environment variable

# Source generic agent detection functions (root loader)
if [[ -f "${0:A:h}/agent-terminal-detection.zsh" ]]; then
    source "${0:A:h}/agent-terminal-detection.zsh"
elif [[ -f "./agent-terminal-detection.zsh" ]]; then
    source "./agent-terminal-detection.zsh"
fi

# Main detection logic - runs only once per shell session
if [[ -z "$AGENT_DETECTED" ]]; then
    if _runs_a_agent_in_terminal; then
        export AGENT_DETECTED=true
    else
        export AGENT_DETECTED=false
    fi
fi

# Clean up private functions to avoid polluting the namespace
unset -f _runs_a_agent_in_terminal _agent_check_legacy_marker

# --- Auto-update helper (git) ----------------------------------------------
# Configuration (override in your ~/.zshrc before loading plugin):
# - AGENT_TD_AUTO_UPDATE_ON_START: if "true", run a background update check on shell start
# - AGENT_TD_AUTO_UPDATE: if "true", allow update operations (safety gate)
# - AGENT_TD_AUTO_UPDATE_INTERVAL_DAYS: minimum days between auto-start checks
: ${AGENT_TD_AUTO_UPDATE_ON_START:=false}
: ${AGENT_TD_AUTO_UPDATE:=false}
: ${AGENT_TD_AUTO_UPDATE_INTERVAL_DAYS:=7}

_agent_td__cache_dir() {
    if [[ -n "${XDG_CACHE_HOME:-}" ]]; then
        echo "${XDG_CACHE_HOME}/agent-terminal-detection"
    else
        echo "${HOME}/.cache/agent-terminal-detection"
    fi
}

agent_terminal_detection_autoupdate() {
    # Performs a safe, fast-forward only pull of the plugin repository.
    # Returns 0 on success or when already up-to-date; non-zero on error.
    local repo_dir="${0:A:h}"
    local cache_dir last_file now last_ts age_seconds max_seconds

    # Safety: only allow if enabled
    if [[ "${AGENT_TD_AUTO_UPDATE:-false}" != "true" ]]; then
        return 1
    fi

    # Ensure git repo
    if [[ ! -d "${repo_dir}/.git" ]]; then
        return 2
    fi

    # Fetch remote
    if ! git -C "${repo_dir}" fetch --prune origin >/dev/null 2>&1; then
        return 3
    fi

    # Abort if there are local changes
    if [[ -n "$(git -C "${repo_dir}" status --porcelain)" ]]; then
        return 4
    fi

    # Determine upstream remote/branch; fall back to origin/main
    local upstream remote branch
    upstream=$(git -C "${repo_dir}" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null) || upstream=""
    if [[ -n "$upstream" ]]; then
        remote=${upstream%%/*}
        branch=${upstream#*/}
    else
        remote=origin
        branch=main
    fi

    # Fast-forward pull only
    if git -C "${repo_dir}" pull --ff-only "$remote" "$branch" >/dev/null 2>&1; then
        return 0
    fi

    return 5
}

# Auto-start logic: run a background update check only when enabled and not too frequent
if [[ "${AGENT_TD_AUTO_UPDATE_ON_START}" == "true" && "${AGENT_TD_AUTO_UPDATE}" == "true" && "$-" == *i* ]]; then
    cache_dir="$(_agent_td__cache_dir)"
    last_file="$cache_dir/last_autoupdate"
    mkdir -p "$cache_dir" 2>/dev/null || true
    now=$(date +%s)
    if [[ -f "$last_file" ]]; then
        last_ts=$(cat "$last_file" 2>/dev/null || echo 0)
    else
        last_ts=0
    fi
    max_seconds=$((AGENT_TD_AUTO_UPDATE_INTERVAL_DAYS * 86400))
    age_seconds=$((now - last_ts))
    if (( age_seconds >= max_seconds )); then
        # run in background, don't block shell startup
        ( agent_terminal_detection_autoupdate >/dev/null 2>&1 && date +%s >"$last_file" ) &
    fi
fi
