# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-12 · **Phase:** 1, the verb · **Active milestone:** M3

**M3 done-when:** death to respawn to moving again is **under one second**,
measured, and dying twenty times in a row is annoying but not tedious.

## Where this is

**Lava, spikes, the death loop, the checkpoint and now falling platforms are
built**, and the loop measures 0.417 s in a real build on all three. A falling
platform is the first M3 hazard that asks about time rather than about space:
`scripts/logic/platform_cycle.gd` owns the clock, `config/hazards.tres` the five
numbers, `scripts/falling_platform.gd` the sensing and the carrying,
`room_m3_falling` the bench.

**A slab stays solid all the way down**: the punish is that the floor leaves
with you on it, the out is that you can still jump off it, and a running build
measures **0.52 s from landing to the last survivable takeoff** (0.53 s dies).
**A respawn puts every platform back at home**, or a death would cost you the
jump you missed and then a wait.

## The next action

**The remaining hazards: moving platforms, then geysers.** A moving platform is
the same node with a different clock and no trigger. A geyser needs the throw
before it needs art.

## Blocked on Matt

1. **Play all three benches and answer the felt half of the done-when.** Twenty
   deaths at the marginal gap, twenty at the marginal bed, twenty in the second
   moat. Open: spacing on the first two, and whether 0.45 s reads as a warning.
2. **Is `spike_grace` a dial you can feel?** `BACKLOG.md` has the experiment
   and M14 can settle it.

## Traps that will bite again

**Opening the project rewrites `project.godot`, and a stale editor deletes from
it.** One save dropped `[physics]` and `[rendering]`, taking engine gravity from
0 to 980. Close the editor, read `git diff project.godot`, restore it, then
pull. `tests/test_project_settings.gd` catches that one loss.

**CI runs the game and logs what happened**, and the spike and platform steps
fail on what the log says rather than only keeping the picture (the older steps
do not, which is in `BACKLOG.md`). A platform's whole content is a clock and no
screenshot can show one, so `tools/capture.gd` prints the phase.

**Docs go stale silently.** `.claude/hooks/` warns on a checkout behind
`origin/main` and on a branch that commits code without touching this file.

## Settled, do not relitigate

**M3:** the loop is 0.25 s hold plus 0.15 s freeze, measured at 0.417 s, and the
death messages outlast it. A brazier lights once and has no way back out, so
"the last lit brazier" is the furthest one you reached. Spikes and lava kill
identically and a falling platform kills nothing, it drops you into something
that does. Every bench keeps a brazier between its two hazards.

**Colour**, to `ART_DIRECTION.md`'s own rules: wood is warm in hue and matte in
saturation, spikes are `#7a2434` iron and `#e0956f` tip, a falling slab is stone.

**M2:** standing on a thrown sword and recall-on-hold both feel right. The sword
ledge is 16 px against an 18 px hero and that margin is fine.

**M1:** you miss by changing height, a catch beats a solid hit in the same frame,
and only flight destroys a sword (a spent one lands).

**M0:** a storey is climbed, never jumped. `SPEC.md` carries why. **Lothar of
the Hill People** is the name, and M5 paints him.

**The gates:** no art before M5, no level building before M10, G1 after M5.
`BUILD_PLAN.md` carries the reasoning, unchanged.

## Pointers

`SPEC.md` what the game is · `BUILD_PLAN.md` what to build next ·
`ART_DIRECTION.md` how it looks · `ANIMATION.md` what moves ·
`ART.md` and `GEMINI_NOTES.md` before any art · `CLAUDE.md` how to work here ·
`README.md` running it · `BACKLOG.md` raised and not judged · `assets/reference/`
the original.
