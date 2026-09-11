#!/usr/bin/env bash
#
# CLAUDE.md: state the active milestone and its done-when at the start of every
# session. A hook is more reliable than remembering to, so this puts the two
# lines that matter in front of Claude before the first prompt.
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
echo "Build and test with tools/dev.sh (import, test, play, shot). Feel criteria"
echo "are Matt's to answer by playing, never yours to answer by reasoning."
