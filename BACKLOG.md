# BACKLOG.md

Mid-build ideas land here, never in the active milestone. Nothing in this file is
committed to.

## Deferred from v1 deliberately

- **A forgiving mode**, for a kid. Checkpoint density, hazard lethality and sword
  count are already the three dials that would do it. Stays here until the game
  exists, because a difficulty mode built before the base difficulty is tuned is
  two untuned games.
- **Per-hazard death animations.** v1 has one. Lava, spikes and falls all
  deserve their own.
- **Sword variants.** A heavier sword that does not return. A pair thrown
  together. Both are real design space and both would dilute a single clean verb
  before that verb has proved itself.
- **A speedrun timer and ghost.** Fits the game's shape well. Post-ship.

## Ideas not yet judged

- **Ricochet off metal surfaces**, for angle puzzles. Listed in `SPEC.md` as one
  of the sword's five behaviours but cut down to four for v1. Add it only if Act
  3 turns out thin.
- **The avian ally as a mid-game traversal tool** rather than only the ending.
  Risk: it is a second verb, and the game is about having one.
- **Sword abilities as upgrades**, rather than all five from the first room.
  Recall, and embedding as a standable platform, become things you earn: better
  throwing, a potion, gold spent somewhere. Raised while playing M2, from the
  real observation that **the player currently gets every verb at once and
  nothing is staged**. That observation is correct and the pacing problem is
  real.

  Three things to weigh before building it. **It changes the genre**: SPEC.md's
  thesis is one verb and puzzles that are uses of it, and an upgrade turns "I
  cannot do this" from a thing you solve by understanding into a thing you solve
  by coming back later. **It is a lot of new system** (currency or items,
  persistent unlock state, save data, UI) in a project whose first attempt died
  of scope, and G1 has not happened. **It multiplies authoring**: every room
  must be solvable under every capability set a player could arrive with.

  The cheap version costs nothing and gets most of it: stage the **situations**
  rather than the abilities. Act 1 simply never presents a problem that wants
  recall; Act 2's rooms need it. SPEC.md's Structure already says each act
  introduces one thing the sword does, so this is level design the plan has
  asked for, not a new system.

- **A jump upgrade.** Same thought applied to movement. Flagged rather than
  filed neutrally, because it **contradicts the decision M0 just made**: ladders
  won on the argument that a jump which cannot reach the next storey is what
  makes an embedded sword one of only two ways to gain height. A jump that grows
  later takes that back mid-game, and the sword goes back to being a small
  extension in exactly the acts where SPEC.md wants it to be the whole vocabulary.
  Worth having only if the ladders decision is being reopened with it.

- **Volta's dialogue.** The original had none worth keeping. A wizard who
  comments on your deaths is either very good or very bad and there is no middle.
- **Desktop builds signed and on itch.io**, beyond the web export in M16.
