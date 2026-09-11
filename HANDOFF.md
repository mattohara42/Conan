# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-11 · **Phase:** 1, the verb · **Active milestone:** M3

**M3 done-when:** death to respawn to moving again is **under one second**,
measured, and dying twenty times in a row is annoying but not tedious.

## Where this is

**The death loop and the checkpoint are both built.** The loop measures 0.417 s
in a real build. A brazier lights by being walked past, lights once, and a death
puts you at the last one you lit. The M3 bench carries two: one at the start and
one just past the easy gap, so a death at the marginal gap costs you that jump
and not the one before it. Both read correctly, confirmed by looking, and both
are flat stand-ins for what M9 owns.

## The next action

**The remaining hazards, cheapest first: spikes, then falling platforms, then
moving platforms, then geysers.** All of them are a variation on lava, none
changes what a death means, and that is why the brazier went first. A geyser
throws you as well as killing you, so it needs the throw before it needs art.

## Blocked on Matt

1. **Play the bench and answer the felt half of the done-when.** Twenty deaths
   at the marginal gap, with the checkpoint in. The loop already measured fine
   without it, so the open question is whether the spacing is right.
2. **Wood's colour.** `ART_DIRECTION.md` says deep darks are warm umber in wood
   and also that anything you stand on is cold and matte. M2 wood is both, read
   as warm in hue and matte in saturation. Two `Palette` constants, blocks nothing.

## Traps that will bite again

**Opening the project rewrites `project.godot`, and a stale editor deletes from
it.** One save dropped the whole `[physics]` and `[rendering]` sections, taking
engine gravity from 0 to 980. Close the editor, read `git diff project.godot`,
restore it, then pull. `tests/test_project_settings.gd` catches that specific
loss and not every one.

**CI runs the game and logs what happened**: where a sword landed, the death
loop, which braziers are lit, where a respawn put the player. Four M2 geometry
bugs got past green assertions and a running build caught every one.

**Docs go stale silently.** `.claude/hooks/` warns on a checkout behind
`origin/main` and on a branch that commits code without touching this file.

## Settled, do not relitigate

**M3:** the loop is 0.25 s hold plus 0.15 s freeze, measured at 0.417 s, and the
death messages outlast it. A brazier lights once and has no way back out, so
"the last lit brazier" is the furthest one you reached: walking back past an old
one does not move the checkpoint back.

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
