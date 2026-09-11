# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-11 · **Phase:** 1, the verb · **Active milestone:** M3

**M3 done-when:** death to respawn to moving again is **under one second**,
measured, and dying twenty times in a row is annoying but not tedious.

## Where this is

**M3's done-when is already met, on the death loop alone.** Measured at 0.417 s
in a real build, and played: dying repeatedly is not annoying. The milestone
stays open because its hazard list does not: **only lava exists.**

Still to build: spikes, geysers, moving and falling platforms, and **braziers as
checkpoints**. The braziers are the interesting one, being the first thing that
moves `spawn_point` rather than leaving it where the player started.

Lava reads as lava, confirmed by looking. It is a flat rectangle standing in for
the shader M9 owns.

## The next action

**Braziers before the other hazards.** Everything else is a variation on lava
(an area that kills), and a checkpoint is the only piece that changes what a
death means. Building it last would mean retuning the loop twice.

## Blocked on Matt

1. **Wood's colour.** `ART_DIRECTION.md` says deep darks are warm umber in wood
   and also that anything you stand on is cold and matte. M2 wood is both. Read
   as warm in hue, matte in saturation. Two constants in `Palette` to change. It
   blocks nothing and it is the only open question in the repo.

## Traps that will bite again

**Opening the project rewrites `project.godot`, and a stale editor deletes from
it.** One save dropped the whole `[physics]` and `[rendering]` sections, taking
engine gravity from 0 to 980. Close the editor, read `git diff project.godot`,
restore it, then pull. `tests/test_project_settings.gd` catches that specific
loss and not every one. M3 adds input actions to this file and has not yet.

**CI runs the game and logs what happened**: where a thrown sword landed, and
the measured death loop. Four M2 geometry bugs got past green assertions and
every one was caught by a number out of a running build. Read those lines.

**Docs go stale silently.** Two cost real work this week: a `HANDOFF.md` read
through six merges, and a `SPEC.md` claim about the reference set written from
memory. `.claude/hooks/` now warns on both a checkout behind `origin/main` and a
branch that commits code without touching this file.

## Settled, do not relitigate

**M3:** the loop is 0.25 s hold plus 0.15 s freeze, measured at 0.417 s, and it
feels right. Death messages are centred, large, and outlast the respawn.

**M2:** standing on a thrown sword and recall-on-hold both feel right as built.
The sword ledge is 16 px against an 18 px hero and that margin is fine.

**M1:** you miss by changing height, a catch beats a solid hit in the same frame,
and only flight destroys a sword (a spent one lands).

**M0:** a storey is climbed, never jumped. `SPEC.md` carries why.

**Lothar of the Hill People** is the name, and M5 paints him.

## The gates

No art before M5, no level building before M10, and G1 after M5.
`BUILD_PLAN.md` carries the reasoning and it has not changed.

## Pointers

`SPEC.md` what the game is · `BUILD_PLAN.md` what to build next ·
`ART_DIRECTION.md` how it looks · `ANIMATION.md` what moves ·
`ART.md` and `GEMINI_NOTES.md` before any art · `CLAUDE.md` how to work here ·
`README.md` running it · `BACKLOG.md` raised and not judged · `assets/reference/`
the original.
