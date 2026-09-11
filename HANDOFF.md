# HANDOFF.md

> **Rewrite this file, never append.** State snapshot and pointers only. No
> session narrative, that is what `git log` is for. Keep it under 80 lines.

**Updated:** 2026-09-11 · **Phase:** 1, the verb · **Active milestone:** M2

**M2 done-when:** a grey room that **cannot be finished** without standing on
your own thrown sword, and a second one that cannot be finished without
recalling it while it holds a switch down. **Both are built.** M2 closes when
they have been played, since a room being possible and a room being good are
different claims and only one of them is asserted.

## Where this is

M0 and M1 meet their done-when. **M2's mechanics are built and M2's two rooms are
not**, because the rooms are sized by a jump height nobody has picked. The M2
bench (F2 cycles to it) demonstrates all four behaviours and gates nothing.

The sword embeds in wood, holds a one-tile ledge you stand on, and comes home
when the throw button is held past `recall_hold_time`. Wood is a group, not a
layer. `SwordFlight` carries two more states and a `Contact` enum.

**Rooms assert their own claim, not their geometry.** `test_room_m2_gap.gd` and
`test_room_m2_switch.gd` check "cannot be finished without the sword" against
`config/`, via `Motion.jump_reach`. Retune the jump in M14 and those files name
the rooms that broke. That is the difference between a tuning pass and a
rebuild, and it is only possible because every such number lives in `config/`.

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

## The jump is settled: ladders won

Both presets were played and the 56 px one is the better game. **A storey is
climbed, never jumped.** `config/movement.tres` now holds those numbers and
`config/movement_strong.tres` keeps the alternative for Tab and for M14.

`SPEC.md` said this section would be rewritten if ladders won, and it has been.
The reason it went that way is worth keeping: with a jump that cannot reach the
next storey, an embedded sword is one of only two ways to gain height at all.
That makes the sword the game in the level geometry and not only in the combat.

**The risk `SPEC.md` named is now the thing to watch at G1**: a platformer whose
traversal is climbing may have traded away the fun of moving.

## Next action

1. **Play M2's two rooms** (F2 cycles to them). They are proved possible, not
   proved good. The switch room hands you one sword on purpose.
2. **Feel questions**: does standing on a thrown sword feel good, and does
   holding J to recall read as one verb or two?
3. **M3, hazards and the death loop**, once M2 is closed.

## Blocked on Matt

1. **A sword ledge is 16 px and the hero is 18 px wide.** You can stand on it,
   because a body needs only its centre supported, but there is no margin. First
   number to look at if standing on a sword feels fiddly.
2. **Wood's colour.** `ART_DIRECTION.md` says deep darks are warm umber in wood
   and also that anything you stand on is cold and matte. M2 wood is both. Read
   as warm in hue, matte in saturation. Two constants in `Palette` to change.
3. **Is Lothar of the Hill People the real name?** Held deliberately, not
   forgotten. It is a Mike Myers bit, so the question is tone rather than
   spelling, and M5 paints him. Answer it before there is a face, not after.

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
