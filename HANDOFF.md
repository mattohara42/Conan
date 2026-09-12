# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-12 · **Phase:** 1, the verb · **Active milestone:** M3

**M3 done-when:** death to respawn to moving again is **under one second**,
measured, and dying twenty times in a row is annoying but not tedious.

## Where this is

**Lava, spikes, the death loop, the checkpoint, falling platforms and now moving
platforms are built**, and the loop measures 0.417 s in a real build on all four
benches. A ferry is the falling slab's node with a different clock and no
trigger: `scripts/logic/platform_ferry.gd` owns the clock, `scripts/platform.gd`
what the two kinds share, `scripts/moving_platform.gd` the carrying and the rail,
`config/hazards.tres` two numbers, `room_m3_moving` the bench.

**A respawn set the ferry's numbers.** A platform put back at its dock starts its
clock when the controls come back, not when the body is placed: before that the
second ferry left two frames before a respawn could reach the lip, every time,
and no assertion counting pixels saw it. CI now dies in the second moat and
catches the ferry from the checkpoint.

## The next action

**Geysers, the last M3 hazard**, and the only one whose effect is on the hero's
velocity rather than on the floor. `SPEC.md` has them in Act 2, `BACKLOG.md` the
argument for using one as a route.

## Blocked on Matt

1. **Play all four benches and answer the felt half of the done-when.** Twenty
   deaths at each second hazard. Open: spacing on the first two benches, whether
   0.45 s reads as a warning, whether a 0.7 s dock reads as an invitation or as
   dead time, and whether the 2.45 s a missed ferry costs is too long (a death
   never costs it, only being alive and late does).
2. **Is `spike_grace` a dial you can feel?** `BACKLOG.md` has the experiment
   and M14 can settle it.

## Traps that will bite again

**Opening the project rewrites `project.godot`, and a stale editor deletes from
it.** One save dropped `[physics]` and `[rendering]`, taking engine gravity from
0 to 980. Close the editor, read `git diff project.godot`, restore it, then pull.
`tests/test_project_settings.gd` catches that one loss.

**CI fails on what the log says** for the spike, falling and ferry steps, not
only on keeping the picture (the older ones do not: `BACKLOG.md`). No screenshot
shows a clock, so `tools/capture.gd` prints each platform's phase and position.

**Docs go stale silently.** `.claude/hooks/` warns on a checkout behind
`origin/main`, and on a branch committing code without touching this file.

## Settled, do not relitigate

**M3:** the loop is 0.25 s hold plus 0.15 s freeze, measured at 0.417 s, and the
death messages outlast it. A brazier lights once and has no way back out, so
"the last lit brazier" is the furthest one you reached. Spikes and lava kill
identically and neither kind of platform kills at all, it puts you in something
that does. Every bench keeps a brazier between its two hazards, and a respawn
puts every platform back at the start of its clock.

**The ferry** docks at each end rather than turning round, because the dock is
the window you board in, and crosses at a constant speed, so halfway along is
halfway through. The first moat's docks flush and the second's reaches neither
bank, which is one new thing at a time.

**Colour**, to `ART_DIRECTION.md`'s own rules: wood is warm in hue and matte in
saturation, spikes are `#7a2434` iron and `#e0956f` tip, both platforms are
stone, and the tell between them is shape: a falling slab is bitten off and
cracked, a ferry is intact on a rail that reaches both its docks.

**Closed milestones.** M2: standing on a thrown sword and recall-on-hold both
feel right, and a 16 px ledge against an 18 px hero is a fine margin. M1: you
miss by changing height, a catch beats a solid hit in the same frame, and only
flight destroys a sword. M0: a storey is climbed and never jumped (`SPEC.md`
carries why), and **Lothar of the Hill People** is the name M5 paints.

**The gates:** no art before M5, no level building before M10, G1 after M5.
`BUILD_PLAN.md` carries the reasoning, unchanged.

## Pointers

`SPEC.md` what the game is · `BUILD_PLAN.md` what to build next ·
`ART_DIRECTION.md` how it looks · `ANIMATION.md` what moves ·
`ART.md` and `GEMINI_NOTES.md` before any art · `CLAUDE.md` how to work here ·
`README.md` running it · `BACKLOG.md` raised and not judged · `assets/reference/`
the original.
