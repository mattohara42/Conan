#!/usr/bin/env bash
#
# CLAUDE.md: state the active milestone and its done-when at the start of every
# session. A hook is more reliable than remembering to, so this puts the two
# lines that matter in front of Claude before the first prompt.
#
# It also checks that this checkout is current. A long-lived session reading a
# stale HANDOFF.md will confidently report state that main moved past hours ago,
# which has already happened once and cost a decision being re-asked.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

echo "Volta Redux. Read HANDOFF.md before doing anything, then SPEC.md for any"
echo "question about what the game is. From HANDOFF.md right now:"
echo

if [[ -f HANDOFF.md ]]; then
	grep -A1 -m1 "Active milestone" HANDOFF.md || true
	grep -A1 -m1 "done-when:\*\*" HANDOFF.md || true
else
	echo "  HANDOFF.md is missing, which it should never be."
fi

echo

# Network can be absent or slow, and a hook that hangs is worse than a hook that
# skips this. The fetch is best effort; the warning only fires on a real answer.
if timeout 15 git fetch --quiet origin main 2>/dev/null; then
	behind="$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)"
	if [[ "$behind" -gt 0 ]]; then
		echo "STALE: this checkout is $behind commit(s) behind origin/main, so the"
		echo "lines above may describe state that has already moved. Read HANDOFF.md"
		echo "from origin/main before trusting them:"
		echo "    git log --oneline HEAD..origin/main"
		echo "    git show origin/main:HANDOFF.md"
		echo
	fi
else
	echo "Could not reach origin, so the freshness of HANDOFF.md above is unverified."
	echo
fi

echo "Build and test with tools/dev.sh (import, test, play, shot). Feel criteria"
echo "are Matt's to answer by playing, never yours to answer by reasoning."
