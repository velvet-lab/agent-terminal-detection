#!/usr/bin/env bash
# Copilot agent detection module (moved to top-level agents/)
# Registers itself by adding an entry to `AGENT_DETECT_FUNCS` and provides `_detect_copilot`.

# Module registers its detection function by appending the function name to the
# indexed array `AGENT_DETECT_FUNCS` (simple list of detection function names).
# shellcheck disable=SC2034
# shellcheck disable=SC2154
# Register the detection function in the indexed array
AGENT_DETECT_FUNCS+=(_detect_copilot)

_detect_copilot() {
    # Method 1 (PRIMARY): Check for GIT_PAGER=cat
    if [[ "${GIT_PAGER:-}" == "cat" ]]; then
        return 0
    fi

    # Method 2: Check explicit Copilot environment variables
    if [[ -n "${COPILOT_THREAD_ID}" ]] || \
       [[ -n "${GH_COPILOT}" ]] || \
       [[ -n "${GITHUB_COPILOT_CLI}" ]]; then
        return 0
    fi

    # Method 3: Non-TTY input fallback
    if [[ ! -t 0 ]]; then
        return 0
    fi

    return 1
}
