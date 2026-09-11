#!/usr/bin/env bash
#
# Fires when Claude finishes a turn, and says so when this branch has committed
# code without touching HANDOFF.md.
#
# **This hook cannot write the docs.** It runs a shell command, so it can notice
# that the snapshot is behind and name the command that fixes it. The writing is
# `/handoff`, which is a person or Claude reading the diff and deciding what the
# state actually is.
#
# It is gated on a **commit** rather than on an edited file on purpose. Nobody
# wants to rewrite the handoff after every keystroke, and uncommitted work is
# work in progress. A commit is the closest thing a hook can see to a finished
# piece of work.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

# Where the state that HANDOFF.md describes actually lives.
CODE_PATHS=(scripts config scenes tests tools project.godot .github)

# No upstream to compare against means nothing useful to say.
git rev-parse --verify --quiet origin/main >/dev/null 2>&1 || exit 0

base="$(git merge-base origin/main HEAD 2>/dev/null || true)"
[[ -n "$base" ]] || exit 0

code="$(git diff --name-only "$base"..HEAD -- "${CODE_PATHS[@]}" 2>/dev/null || true)"
docs="$(git diff --name-only "$base"..HEAD -- HANDOFF.md 2>/dev/null || true)"

# Nothing committed, or the handoff already moved with it.
[[ -n "$code" ]] || exit 0
[[ -z "$docs" ]] || exit 0

count="$(printf '%s\n' "$code" | grep -c . || true)"
echo "HANDOFF.md is behind: $count file(s) of code committed on this branch and"
echo "the snapshot untouched. It is the first thing the next session reads, and a"
echo "stale one has already cost this project a settled decision being re-asked."
echo "Run /handoff before opening the PR, or say why it does not need changing."
