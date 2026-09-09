# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-09 · **Phase:** 1, the verb · **Active milestone:** M1
closing, M2 next

**M2 done-when:** a grey room that **cannot be finished** without standing on
your own thrown sword, and a second one that cannot be finished without
recalling it while it holds a switch down.

## Where this is

M0 and M1 both meet their done-when in a running build. Matt has Godot installed
and has played it. **The feel questions are still open**, and one of them just
moved.

**Tab was bound to physical keycode 9 instead of `KEY_TAB` (4194306), so the
preset swap never worked.** Fixed, and `tests/test_input_map.gd` now checks every
action against the key the overlay advertises. The other debug keys were fine.

## The jump, which is now the thing blocking M2

Matt played the strong preset (the only one Tab could reach) and read it as too
high, preferring the first attempt's "more normal" jump. That build's numbers are
in history at `29fa013:config.js`:

| | height | apex | gravity | vs hero | vs tier |
|---|---|---|---|---|---|
| old Phaser build | 56 px | 0.375 s | 800 | 1.76x (32 px hero) | 0.75 (75 px tier) |
| current, strong | 112 px | 0.360 s | 1728 | 2.80x (40 px hero) | 1.17 (96 px tier) |
| current, ladders | 56 px | 0.255 s | 1728 | 1.40x (40 px hero) | 0.58 |

**The jump he liked is 56 px, which is the ladders preset's height exactly.** So
the preference points at `SPEC.md` → *ladders vs jump* being answered against
what `SPEC.md` currently says. It is not a clean vote yet: the old build was low
**and floaty** (gravity 800), the ladders preset is low **and snappy** (1728), so
neither preset reproduces what he remembers. A third preset at 56 px / 0.375 s
would, and it would break `test_config.gd`'s controlled-experiment assertion,
which is a deliberate cost and not a bug.

**M2's rooms are the reason this blocks.** A room built to need an embedded-sword
ledge is sized by jump distance, and 112 px and 56 px are different games.

## Next action

1. **Play both presets now that Tab works**, and answer: low or high, floaty or
   snappy. This is the last M0 question and everything downstream is sized by it.
2. **Build M2's mechanics** (embed in wood, recall on hold, stand on the sword)
   which are jump-independent and can start before 1 is answered.
3. **Build M2's two rooms** only after 1 is answered.

## Blocked on Matt

1. **The jump.** See above. Blocks M2's rooms, not M2's mechanics.
2. **Is 40 px the right hero height?** `[` and `]` cycle 28 / 34 / 40 / 46 / 54.
   Blocks M5 too, being the hero's pixel height.
3. **The repo About panel** still describes the Phaser build. Needs one
   `gh repo edit` locally; there is no `gh` in the session container.
4. **The hero's name.** Needed before M5 paints him, not before.

## Distribution

`BUILD_PLAN.md` → M16 owns it and nothing needs deciding now. The two settings
that would have been locks are already right: GL Compatibility (the renderer web
export needs) and a fixed 640x360 viewport.

## Settled in M1, do not relitigate

You miss by changing height, a catch beats a solid hit in the same frame, and
only flight destroys a sword (a spent one lands).

## The gates

No art before M5, no level building before M10, and G1 after M5.
`BUILD_PLAN.md` carries the reasoning and it has not changed.

## Pointers

| for | read |
|---|---|
| what the game is | `SPEC.md` |
| what to build next | `BUILD_PLAN.md` |
| how it looks | `ART_DIRECTION.md` |
| what moves, and how | `ANIMATION.md` |
| getting a picture into the game | `ART.md` |
| before writing any prompt | `GEMINI_NOTES.md` |
| how to work in this repo | `CLAUDE.md` |
| running it, and the test command | `README.md` |
| the original, 53 screenshots | `assets/reference/` |
