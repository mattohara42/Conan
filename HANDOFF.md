# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-11 · **Phase:** 1, the verb · **Active milestone:** M3

**M3 done-when:** death to respawn to moving again is **under one second**,
measured, and dying twenty times in a row is annoying but not tedious.

## Where this is

**M0, M1 and M2 all meet their done-when.** M2's two rooms were played and both
feel criteria came back good: standing on a thrown sword feels fine, and holding
the throw button to recall reads as one verb rather than two.

Nothing in Phase 1 is blocked. `BUILD_PLAN.md` has M3's contents.

**The one-second figure is a measurement, not a vibe.** Build the timer first:
M3 is the only milestone whose done-when carries a number, and instrumenting it
now is cheap where retrofitting it is not.

Playing M2 corrected `SPEC.md` twice, in `Structure` and in the jump section:
the jump owns holes, plinths and short steps rather than storeys, and the sword
route up is uncommon by design. Read them there. **Lothar of the Hill People is
the name**, settled, and M5 paints him.

## Blocked on Matt

1. **Wood's colour.** `ART_DIRECTION.md` says deep darks are warm umber in wood
   and also that anything you stand on is cold and matte. M2 wood is both. Read
   as warm in hue, matte in saturation. Two constants in `Palette` to change.

## Traps that will bite again

**Opening the project rewrites `project.godot`**, which leaves it dirty and makes
the next `git pull` refuse, so a change to the input map silently never arrives.
Close the editor, `git checkout -- project.godot`, then pull. M3 adds actions, so
this is due to happen again.

**CI throws a sword into wood, screenshots it, and logs where it landed.** Four
M2 geometry bugs got past green assertions and every one was caught by arithmetic
on paper or a number out of a running build. That log line is the cheapest guard
in the repo.

**A long session goes stale.** A checkout that sat through six merges reported
two-day-old state and a settled decision got re-asked. The SessionStart hook now
warns when HEAD is behind `origin/main`.

## Settled, do not relitigate

**M1:** you miss by changing height, a catch beats a solid hit in the same frame,
and only flight destroys a sword (a spent one lands).

**M2:** standing on a thrown sword and recall-on-hold both feel right as built.
The sword ledge is 16 px against an 18 px hero and that margin is fine.

**M0:** a storey is climbed, never jumped. `SPEC.md` carries why.

## The gates

No art before M5, no level building before M10, and G1 after M5.
`BUILD_PLAN.md` carries the reasoning and it has not changed.

## Pointers

`SPEC.md` what the game is · `BUILD_PLAN.md` what to build next ·
`ART_DIRECTION.md` how it looks · `ANIMATION.md` what moves ·
`ART.md` and `GEMINI_NOTES.md` before any art · `CLAUDE.md` how to work here ·
`README.md` running it · `BACKLOG.md` raised and not judged · `assets/reference/`
the original.
