# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-07 · **Phase:** 1, the verb · **Active milestone:** M0

**M0 done-when:** a capsule crosses a grey room, the jump feels good enough that
you stop noticing it, and every number that decides that lives in one file.

## Where this is

**M0 is built and it is not signed off.** The code half is done and verified.
The done-when is a feel criterion and only Matt can discharge it.

Godot 4.7.1, GDScript, no addons. `godot --path .` plays the M0 room.
26 tests and 129 checks pass headless. CI runs them on every push and also boots
the real build under Xvfb and uploads a screenshot of the room.

Movement carries coyote time, jump buffering, variable height by hold duration
and air control. Every number is in `config/`: `movement.tres`,
`movement_ladders.tres`, `world.tres`. No script sets one.

## Next action

**Play it and answer three questions.** Nothing else in M0 is outstanding.

1. **Does the jump feel good?** If not, change `config/movement.tres` and only
   that file. If you have to open a script to fix the feel, that is a bug.
2. **Is 40 px the right hero height?** `[` and `]` cycle 28 / 34 / 40 / 46 / 54
   against fixed geometry. `ART_DIRECTION.md` calls this the number most likely
   to be wrong and it should be settled before M5 paints anything.
3. **Strong jump or weak jump and ladders?** Tab swaps the two presets live. The
   room is completable either way: the strong preset jumps the tiers, the ladder
   preset must climb them. `SPEC.md` prefers the strong jump and says decide by
   feel. If ladders win, `SPEC.md` → *Structure* gets rewritten.

The two presets differ in **jump height only**. Derived gravity is identical, on
purpose, so the comparison means something. A test enforces it.

## Blocked on Matt

1. **Rename the repo**, `Conan` to `volta-redux`. Settings → General. No API for
   it, and GitHub redirects the old URL so nothing breaks meanwhile.
2. **The hero's name.** Needed before M5 paints him, not before.
3. **The three questions above.**

## Worth knowing before touching the movement code

The takeoff speed in `Motion.jump_speed_for` carries a half-frame gravity term.
It is not a fudge and its **sign depends on the order `player.gd` does things
in**. A 112 px jump measured 122 px in the running game while the test was
green, because the test simulated a different integration order. Both are now
written to the order the player actually uses, and `test_motion.gd` says so.
This is the `CLAUDE.md` rule about drawing what you measured, paid for once.

## Deferred, deliberately

- **A palette check over generated art.** `ColourRules` and `test_palette.gd`
  cover the colours the code chooses. Extending it to PNGs belongs in M5, when
  there is a PNG.
- **One-way platforms**, so ladders can pass through a floor. Not needed while
  ladders sit flush against the ledge they serve.

## The two gates worth not walking past

**No art before M5, no level building before M10.** The first attempt spent
itself tracing and ripping before the core was decided.

**G1, after M5.** One room, finished, played for an hour. If it is not fun, the
fault is in `SPEC.md` and that is where the fix goes.

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
