# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-10 · **Phase:** 1, the verb · **Active milestone:** M2

**M2 done-when:** a grey room that **cannot be finished** without standing on
your own thrown sword, and a second one that cannot be finished without
recalling it while it holds a switch down.

## Where this is

M0 and M1 meet their done-when. **M2's mechanics are built and M2's two rooms are
not**, because the rooms are sized by a jump height nobody has picked. The M2
bench (F2 cycles to it) demonstrates all four behaviours and gates nothing.

The sword embeds in wood, holds a one-tile ledge you stand on, and comes home
when the throw button is held past `recall_hold_time`. Wood is a group, not a
layer. `SwordFlight` carries two more states and a `Contact` enum.

**Four geometry bugs in M2, none of which a test caught**, and all found either
by arithmetic on paper or by a number out of a running build. The last one was
a ledge with 7.9 px standing clear of the plank against an 18 px hero. CI now
throws a sword into wood, screenshots it, and logs where it landed. That log
line is the cheapest guard in the repo: use it.

**Tab was bound to physical keycode 9 instead of `KEY_TAB` (4194306), so the
preset swap never worked.** Fixed on `main`, and `tests/test_input_map.gd` now
checks every action against the key the overlay advertises.

**Opening the project rewrites `project.godot`**, which leaves it dirty and makes
the next `git pull` refuse, so a change to the input map silently never arrives.
Close the editor, `git checkout -- project.godot`, then pull. Standing fix: commit
Godot's own serialisation of that file and keep the notes somewhere it cannot
delete them. Worth doing, since M3 adds actions too.

## The jump, which is now the thing blocking M2

Matt read the strong preset as too high and preferred the first attempt's "more
normal" jump. That build's numbers, from `29fa013:config.js`:

| | height | apex | gravity | vs hero | vs tier |
|---|---|---|---|---|---|
| old Phaser build | 56 px | 0.375 s | 800 | 1.76x (32 px hero) | 0.75 (75 px tier) |
| current, strong | 112 px | 0.360 s | 1728 | 2.80x (40 px hero) | 1.17 (96 px tier) |
| current, ladders | 56 px | 0.255 s | 1728 | 1.40x (40 px hero) | 0.58 |

**The jump he liked is 56 px, the ladders preset's height exactly**, so the
preference points against what `SPEC.md` currently argues. Not a clean vote: the
old build was low **and floaty** (gravity 800), the ladders preset low **and
snappy** (1728), so neither reproduces it. A third preset at 56 px / 0.375 s
would, at the cost of `test_config.gd`'s controlled-experiment assertion.

**M2's rooms are sized by this.** 112 px and 56 px are different games.

## Next action

1. **Play both presets now that Tab works**, and answer: low or high, floaty or
   snappy. This is the last M0 question and everything downstream is sized by it.
2. **Play the M2 bench.** Does standing on a thrown sword feel good, and does
   holding J to recall feel like one verb or two?
3. **Build M2's two rooms** once 1 is answered. Only then is M2 done.

## Blocked on Matt

1. **The jump.** See above. Blocks M2's rooms, not M2's mechanics.
2. **Is 40 px the right hero height?** `[` and `]` cycle 28 / 34 / 40 / 46 / 54.
   Blocks M5 too, being the hero's pixel height.
3. **A sword ledge is 16 px and the hero is 18 px wide.** You can stand on it,
   because a body needs only its centre supported, but there is no margin. First
   number to look at if standing on a sword feels fiddly.
4. **Wood's colour.** `ART_DIRECTION.md` says deep darks are warm umber in wood
   and also that anything you stand on is cold and matte. M2 wood is both. Read
   as warm in hue, matte in saturation. Two constants in `Palette` to change.
5. **The hero's name.** Needed before M5 paints him, not before.

## Distribution

`BUILD_PLAN.md` → M16 owns it and nothing needs deciding now. The two settings
that would have been locks are already right: GL Compatibility (the renderer web
export needs) and a fixed 640x360 viewport.

## Settled in M1, do not relitigate

You miss by changing height, a catch beats a solid hit in the same frame, and
only flight destroys a sword (a spent one lands).

## The gates

No art before M5, no level building before M10, and G1 after M5.
`BUILD_PLAN.md` carries the reasoning and it has not changed.

## Pointers

`SPEC.md` what the game is · `BUILD_PLAN.md` what to build next ·
`ART_DIRECTION.md` how it looks · `ANIMATION.md` what moves ·
`ART.md` and `GEMINI_NOTES.md` before any art · `CLAUDE.md` how to work here ·
`README.md` running it · `assets/reference/` the original.
