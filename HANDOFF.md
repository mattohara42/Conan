# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-12 · **Phase:** 1, the verb · **Active milestone:** M3

**M3 done-when:** death to respawn to moving again is **under one second**,
measured, and dying twenty times in a row is annoying but not tedious.

## Where this is

**Lava, the death loop, the checkpoint and now spikes are built.** The loop
measures 0.417 s in a real build, on spikes as on lava. A spike bed is `Hazard`
with different geometry and no new behaviour: `scripts/logic/spikes.gd` owns the
shape, `config/hazards.tres` the three numbers, `room_m3_spikes` the bench.

**The killing box is not the shape that is drawn**: it runs point to point, half
a tooth in from each end, because the first tooth has no height at the bed's
left edge. `tools/capture.gd` prints both, since a picture only shows one.

## The next action

**The remaining hazards, cheapest first: falling platforms, then moving
platforms, then geysers.** None changes what a death means, and a geyser needs
the throw before it needs art.

## Blocked on Matt

1. **Play both benches and answer the felt half of the done-when.** Twenty
   deaths at the marginal gap, twenty at the marginal bed. The loop measured
   fine unplayed; the open question is whether the spacing is right.
2. **Is `spike_grace` a dial you can feel?** Zeroing it changed the takeoff
   window by nothing measurable. `BACKLOG.md` has the experiment, M14 can settle
   it.
3. **Two colour questions, neither blocking.** Wood is warm in hue and matte in
   saturation, resolving `ART_DIRECTION.md` contradicting itself. Spikes had no
   entry, so one was written to its own rules: `#7a2434` iron, `#e0956f` tip.

## Traps that will bite again

**Opening the project rewrites `project.godot`, and a stale editor deletes from
it.** One save dropped `[physics]` and `[rendering]`, taking engine gravity from
0 to 980. Close the editor, read `git diff project.godot`, restore it, then
pull. `tests/test_project_settings.gd` catches that one loss.

**CI runs the game and logs what happened**, and the two spike steps fail on
what the log says rather than only keeping the picture. The older steps do not,
which is in `BACKLOG.md`.

**Docs go stale silently.** `.claude/hooks/` warns on a checkout behind
`origin/main` and on a branch that commits code without touching this file.

## Settled, do not relitigate

**M3:** the loop is 0.25 s hold plus 0.15 s freeze, measured at 0.417 s, and the
death messages outlast it. A brazier lights once and has no way back out, so
"the last lit brazier" is the furthest one you reached. Spikes and lava kill
identically and always will: the difference is where a bed can sit. Both benches
keep a brazier between their two hazards, same reason.

**M2:** standing on a thrown sword and recall-on-hold both feel right. The sword
ledge is 16 px against an 18 px hero and that margin is fine.

**M1:** you miss by changing height, a catch beats a solid hit in the same frame,
and only flight destroys a sword (a spent one lands).

**M0:** a storey is climbed, never jumped. `SPEC.md` carries why. **Lothar of
the Hill People** is the name, and M5 paints him.

## The gates

No art before M5, no level building before M10, G1 after M5. `BUILD_PLAN.md`
carries the reasoning and it has not changed.

## Pointers

`SPEC.md` what the game is · `BUILD_PLAN.md` what to build next ·
`ART_DIRECTION.md` how it looks · `ANIMATION.md` what moves ·
`ART.md` and `GEMINI_NOTES.md` before any art · `CLAUDE.md` how to work here ·
`README.md` running it · `BACKLOG.md` raised and not judged · `assets/reference/`
the original.
