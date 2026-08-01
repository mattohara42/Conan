# Black-screen fix — notes

## Root cause
`GameScene.create()` threw on its first line of platform styling, so the scene
never finished building and the canvas stayed black. Two mistakes, same origin:

1. Objects were made with `this.physics.add.sprite(x, y, null)` — an Arcade
   **Sprite with no texture renders nothing**.
2. Then `.setFillStyle(color)` was called on them. `setFillStyle` only exists on
   Phaser **Shape** objects (e.g. `add.rectangle`), **not on Sprites**, so it
   threw `TypeError: setFillStyle is not a function`. Phaser swallows create-time
   throws, which is why the browser console looked clean.

## Fix (src/scenes/GameScene.js)
Kept everything as Sprites (so all the existing `setVelocityX / setBounce /
setCollideWorldBounds / setTint` calls keep working — no rewrite to Shape bodies).
Just gave them a real texture and tinted it:

- Generate one 16×16 white texture `'block'` at the top of `create()`.
- Create every sprite with `'block'` instead of `null`.
- Replace every `.setFillStyle(color)` with `.setTint(color)`.

## Also
- `index.html`: added `window.game = game;` — a debug/tuning handle (lets you
  poke `window.game.scene.scenes[0].player` from the console while iterating on
  jump feel).

## Verified
Renders correctly (Conan, 6 platforms, 2 enemies, green exit, HUD). Control
logic confirmed by driving the scene directly: Right/Left → ±200 velocity,
Space (grounded) → −450 (jumpPower), X → boomerang count +1, gravity 800 applies.

## Assumption worth knowing
Automated headless testing showed bodies "not moving" — that was only because the
automation tab is `visibilityState: hidden`, which pauses Phaser's RAF loop. In a
normal focused browser tab it runs at 60fps. Not a bug.

## Palette + Level 1 + ladders (added after the black-screen fix)
- **Palette** (`config.js` → `palette`): sampled from the original C64 release —
  black bg, magenta platforms, green ladders, white Conan; Apple II orange for the
  thrown weapon, a distinct red for enemies (originals drew them white, unplayable).
  Full source set in `assets/reference/`.
- **Level 1** (`config.js` → `platforms`/`ladders`/`enemies`/`exit`): traced from
  `assets/reference/sharp-x1/level-1.png` — 5 stacked tiers (~75px apart) joined by
  a right→left→right ladder zigzag, floor start bottom-right, exit at top.
- **Climb mechanic** (`GameScene.update`): on a ladder, Up/Down climbs at
  `player.climbSpeed` with gravity off; a left/right press, Space, or leaving the
  ladder dismounts. The player↔platform collider has a process callback that
  disables collision while `player.climbing`, so you pass through platforms on a
  ladder and land on the tier when you step off the top. Jumping still works too.

## Sprites (real art)
- Ripped 10 sprites from the Apple II reference screenshots into `assets/sprites/`
  (see that folder's README). Background keyed transparent, native pixel sizes.
- Wired **Conan** and the **dragonfly enemy** into the game: loaded in
  `GameScene.preload`, created from their textures, scaled uniformly to the target
  height so pixels aren't distorted, flipped to face travel direction.
  `pixelArt: true` in the Phaser config (index.html) keeps nearest-neighbour scaling.
- Remaining sprites (doors, gem, key, gem-holder, volta, avian-ally) slot in when
  those mechanics land. The generated white 'block' texture still backs platforms,
  the tree, and the boomerang.

## Sword combat (fixed)
The old boomerang-vs-enemy block was dead: gated on `gameState.boomerangThrown`
(never set) and iterating a non-existent `this.boomerangs`. Rewritten in
`update()` to filter `this.player.boomerangs`: a thrown sword that overlaps an
enemy destroys the enemy and is spent. Verified (enemy 1→0, sword 1→0 on contact).
Note: Arcade `physics.overlap` relies on the quadtree populated by `world.step`,
so it only registers in the live loop — headless tests must set `world.useTree=false`.
