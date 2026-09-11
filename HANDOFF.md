# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-11 · **Phase:** 1, the verb · **Active milestone:** M3

**M3 done-when:** death to respawn to moving again is **under one second**,
measured, and dying twenty times in a row is annoying but not tedious.

## Where this is

**M0, M1 and M2 all meet their done-when. M3 has not been started**: no hazard,
no brazier and no death loop exist yet. `BUILD_PLAN.md` has its contents.

The toolchain is pinned to **Godot 4.7.2**, in CI and `README.md`, so the
screenshot guard runs the build a human plays on. The pin was checked rather
than assumed: every logged sword landing is identical between 4.7.1 and 4.7.2.

`tools/dev.sh test` is **67 tests, 309 checks, 0 failed**, and that same count
passes on CI's headless Linux and on a windowed macOS build. A lower count means
the run did not pick up every file.

## The next action

**Build the death timer before any hazard exists to die to.** M3 is the only
milestone whose done-when carries a number, and instrumenting it now is cheap
where retrofitting it onto a finished death loop is not.

## Blocked on Matt

1. **Wood's colour.** `ART_DIRECTION.md` says deep darks are warm umber in wood
   and also that anything you stand on is cold and matte. M2 wood is both. Read
   as warm in hue, matte in saturation. Two constants in `Palette` to change. It
   blocks nothing in M3 and it is the only open question in the repo.

## Traps that will bite again

**Opening the project rewrites `project.godot`, and a stale editor deletes from
it.** An editor holding settings older than the checkout writes that older state
back: one save dropped the whole `[physics]` and `[rendering]` sections, taking
engine gravity from 0 to 980 and the renderer to forward_plus. Close the editor,
read `git diff project.godot`, restore it, then pull.
`tests/test_project_settings.gd` now fails on that specific loss, but the
header comment is not covered and `tools/dev.sh import` can dirty the file too.
M3 adds input actions to this same file.

**CI throws a sword into wood, screenshots it, and logs where it landed.** Four
M2 geometry bugs got past green assertions and every one was caught by arithmetic
on paper or a number out of a running build. That log line is the cheapest guard
in the repo.

## Settled, do not relitigate

**M2:** standing on a thrown sword and recall-on-hold both feel right as built.
The sword ledge is 16 px against an 18 px hero and that margin is fine. Playing
it corrected `SPEC.md` on what the jump owns and how rare the sword stair is.

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
