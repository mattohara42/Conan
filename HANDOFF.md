# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-08 · **Phase:** 1, the verb · **Active milestone:** M1

**M1 done-when:** all four sword states work in a grey room, the catch window is
a tunable number, and a missed catch leaves a sword on the floor you can walk
over to pick up.

## Where this is

**M1's done-when is met and verified in a running build.** Whether the throw
*feels* right is a separate question and it needs playing.

Two benches, F2 cycles between them. `godot --path .` opens the M0 one.
40 tests, 189 checks. CI runs them and screenshots the game under Xvfb.

The sword: `J` throws along your facing, it flies 200 px, turns, and comes back
along **the height you threw at**, steering only in x toward where you now are.
Stand there and you catch it. Jump and it passes under you, sails on, and lands
on the floor with a ring round it to walk to. Hit the pillar and it is gone.
Three swords, spent on throw, returned on catch or pickup.

`SwordFlight.next_state` is the whole machine in one function, and
`test_sword_flight.gd` walks every transition.

## Next action

**Play both benches and answer four questions.** Three are M0's and they are
still open, because a feel criterion cannot be discharged from a container.

1. **Does the jump feel good?** Change `config/movement.tres` and only that file.
2. **Is 40 px the right hero height?** `[` and `]` cycle 28 / 34 / 40 / 46 / 54.
3. **Strong jump, or weak jump and ladders?** Tab swaps the presets live. The M0
   bench is completable either way. If ladders win, `SPEC.md` → *Structure* gets
   rewritten.
4. **Does the throw feel good?** `config/sword.tres`. The numbers most likely to
   be wrong are `max_range` (200) and `catch_radius` (14).

## Blocked on Matt

1. **The four questions above.** M0 cannot be closed without the first three.
2. **The repo About panel** still describes the Phaser build. There is no `gh` in
   the session container, so it needs one `gh repo edit` locally. The composed
   description and topics are in the session log.
3. **The hero's name.** Needed before M5 paints him, not before.

## Decisions made in M1, worth not relitigating

- **You miss by changing height.** The return leg is flat, so the miss is a
  decision about where you stand rather than a physics accident. This is what
  makes the floating eyeball ("tracks you slowly, at your height") a real threat
  to your return line in M4.
- **A catch beats a solid hit in the same frame.** If the sword got inside your
  catch radius the throw already worked.
- **Landing is not the same event as hitting a wall.** Only flight destroys a
  sword; a spent one lands.

## Deferred, deliberately

- **A palette check over generated art.** `ColourRules` covers the colours the
  code chooses. Extending it to PNGs belongs in M5, when there is a PNG.
- **One-way platforms**, so ladders can pass through a floor. Not needed while
  ladders sit flush against the ledge they serve.
- **A real HUD for the sword count.** It is in the debug overlay. M16 owns UI.

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
