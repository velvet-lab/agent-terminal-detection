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
