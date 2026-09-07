# Volta Redux

A 2D puzzle platformer in Godot 4, reimagining Datasoft's *Conan: Hall of Volta*
(1984). **M0: the project and how it feels to move.**

## What it is

The 1984 original is not a good game. Seven one-screen levels solved by
memorising a fixed sequence, jumps you cannot steer, and hazards that kill on
contact with no cheap retry. This is not a remake of it, and an earlier attempt
at one is in this repo's history.

**One mechanic in it is worth a whole game.** The boomerang sword flies out,
turns, and comes back. Catch it and you keep it. Hit a wall or an enemy and it is
gone. That is a risk and reward economy inside a single button, and this game
makes it the core verb: throw it, catch it, embed it in wood as a ledge you stand
on, recall it, and run current through it.

Volta is a unit of electric potential, and the original's boss hazard was already
an electrical generator gone haywire, so the third act is wiring.

Faithful and hard. Lava kills, spikes kill, no health bar, three swords. The
modernisation is in the cost of dying rather than the chance of it: under a
second from death to moving again.

## Where to start

**`SPEC.md`** is the source of truth, and its section *The sword is the game* is
what everything else hangs off. **`HANDOFF.md`** is the state snapshot and the
first thing to read at the start of a session.

| file | owns |
|---|---|
| `SPEC.md` | what the game is: the verb, the rooms, the enemies |
| `BUILD_PLAN.md` | M0 to M16 in four phases, each with a done-when |
| `HANDOFF.md` | where the project is right now, and what is blocked |
| `CLAUDE.md` | how to work in this repo |
| `ART_DIRECTION.md` | palette, light, treatment |
| `ANIMATION.md` | what is rigged, what is painted, and why |
| `ART.md` | how a picture gets from a prompt into the game |
| `GEMINI_NOTES.md` | how the image generator behaves |
| `BACKLOG.md` | what is deliberately not in v1 |

## Running it

Godot 4.7.1, no addons and no build step. Open the project and press play, or:

```
godot --path . --import                          # once, after a fresh clone
godot --path .                                   # play the M0 room
godot --headless --path . --script res://tests/run_tests.gd
```

The tests are a plain script, not a framework. They find `tests/test_*.gd`, run
every method named `test_*`, and exit non-zero on a failure.

To take a screenshot from a real running build, which is the only way to check
anything visual (see `CLAUDE.md`):

```
xvfb-run -a godot --path . --resolution 1280x720 --script res://tools/capture.gd -- \
    --scene=res://scenes/rooms/room_m0.tscn --out=room.png --zoom=0.38 --centre=800,180
```

`--overwrite` is required to replace an existing file.

## Where the numbers live

Every value that decides how the game feels is in `config/`, and nothing in a
script sets one. `config/movement.tres` and `config/movement_ladders.tres` are
the two answers to the open jump question in `SPEC.md`, and Tab swaps between
them while you play. `config/world.tres` holds hero size and tier height.

## The first attempt

A Phaser 3 remake, through 2026-08-01. It got Level 1 pixel-traced from the Sharp
X1 release, ladder climbing, coyote time, a walk cycle and a working sword throw,
then stopped one board into seven. It is deleted from `main` and kept in history:

```
git log --all -- src/
git show <sha>:src/scenes/GameScene.js
```

## Credits and references

Original game: *Conan: Hall of Volta*, Datasoft, 1984, designed by Eric Robinson
and Eric Parker.

`assets/reference/` holds 53 screenshots of the original across four platforms,
downloaded from [MobyGames](https://www.mobygames.com/game/9293/conan/) as
research. They are not traced, not ripped from, and not shipped. All rights
belong to the respective holders.
