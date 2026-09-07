# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-07 · **Phase:** not started · **Active milestone:** none

## Where this is

The doc set is in. **No Godot project yet, and no code of any kind on `main`.**

This repo held the first attempt, a Phaser 3 remake that got Level 1 traced from
the Sharp X1 release, ladders, coyote time, a walk cycle and a working throw, and
then stopped one board into seven. **That code is deleted from `main` and kept in
history**: `git log --all -- src/` finds it, `git show <sha>:src/scenes/GameScene.js`
reads it. `assets/reference/` survives and is worth keeping (`SPEC.md` → *What
the repo inherits*).

## Next action

**M0**, in `BUILD_PLAN.md`: Godot 4 project, one grey room, a capsule that runs
and jumps with coyote time, jump buffering, variable height and air control, and
every number in `config/movement.tres`.

Its done-when is a feel criterion and it cannot be discharged by a test. Play it.

## Blocked on Matt

1. **Rename the repo**, `Conan` to `volta-redux`. GitHub Settings → General →
   Repository name. There is no API for it, so it is a manual click. GitHub
   redirects the old URL, so nothing breaks in the meantime and no clone needs
   fixing.
2. **The hero's name.** `SPEC.md` → *Name* drops Conan the Barbarian and keeps
   Volta. Nothing in the plan depends on the character, but the hero needs
   something to be called before M5 paints him.
3. **Hero size.** `ART_DIRECTION.md` puts it at roughly 40 design px against a
   640x360 design resolution. **This is the number most likely to be wrong** and
   it should be settled with a grey capsule in M0, before any art exists.

## The one live design disagreement

`SPEC.md` → *One thing the first attempt decided differently*. That build made
the jump deliberately too weak to clear a tier so that **ladders** carried you
between them. This plan gives you a strong steerable jump instead and keeps the
precision.

**Build both in M0 and decide by feel.** If ladders win, `Structure` changes.

## Open questions the docs already carry

Both in `GEMINI_NOTES.md` → *What this project will have to learn on its own*,
and both are M5 experiments rather than blockers:

- Does the multi-subject sheet trick work for **six poses of the same
  character**, where the sheet's usual job is to differentiate subjects and here
  it needs to unify them? Test with a throwaway sheet before anything depends
  on it.
- Can the generator hold one character's identity across separate sheets, or does
  every sheet after the first have to be an attach-and-edit of the first?

## The two gates worth not walking past

**No art before M5, no level building before M10.** The first attempt is the
evidence: it spent itself tracing and ripping before the core was decided.

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
| the original, 53 screenshots | `assets/reference/` |
