#!/usr/bin/env bash
# Example agent detector template
# This file is intentionally documentation-only and does NOT register a detector.
# It is safe to leave in the `agents/` directory because it contains only comments
# and no runtime code. To enable a real detector, copy this file to a new
# filename (e.g. `agents/myagent.sh`) and register the detector as shown below.

# Example (enable by copying and uncommenting):
# AGENT_DETECT_FUNCS[myagent]=_detect_myagent
#
# _detect_myagent() {
#   # Method 1: check env vars
#   # if [[ -n "${MYAGENT_MARKER}" ]]; then
#   #   return 0
#   # fi
#
#   # Method 2: check for non-TTY
#   # if [[ ! -t 0 ]]; then
#   #   return 0
#   # fi
#
#   return 1
# }
