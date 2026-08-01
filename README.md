# Conan: Hall of Volta — browser remake

A browser remake of the 1984 Datasoft platformer *Conan: Hall of Volta*, built
on Phaser 3 with no build step. It began as a jump-feel spike and now has a
pixel-traced Level 1, ladder climbing, ripped sprites, and animation.

The original was punishing because of rigid jump mechanics — no mid-air
correction, brutal precision. This remake keeps the layout faithful while giving
the input modern feel (coyote time, horizontal air control) and using ladders
(not pixel-perfect jumps) to move between tiers.

## Quick start

```bash
python3 serve.py          # dev server on http://localhost:8080 (no-cache)
```

Then open http://localhost:8080. No npm, no build — just Python's stdlib server
and Phaser 3 from a CDN. `serve.py` disables caching so edits to `config.js` and
the ES modules show up on a plain reload; `python3 -m http.server 8080` also works
but caches modules, so you'd need a hard refresh.

## Controls

| Key | Action |
|-----|--------|
| ← → | Move |
| ↑ ↓ | Climb (while on a ladder) |
| Space | Jump |
| X | Throw sword (max 3 in flight; kills enemies on contact) |
| R | Restart |

Reach the green zone at the top-left to win.

## What's built

- **Level 1**, pixel-traced from the original (Sharp X1 reference): five stacked
  tiers plus a floor, joined by four ladders, with the exit on the top wall and a
  landable tree off the right side. Start bottom-right, climb the ladder zigzag up.
- **Ladder climbing** — gravity off while on a ladder, pass through platforms,
  up/down to climb, dismount by moving off / jumping / reaching the end.
- **Conan** — sprite ripped from the Apple II original, 2-frame walk cycle
  (reused for climbing), flips to face travel direction.
- **Flying enemy** — the dragonfly drifts horizontally and hovers (gravity off,
  ignores terrain). Throw a sword to knock it down.
- **Original palette** — sampled from the C64 release (magenta platforms, green
  ladders, black background), centralized in `config.palette`.

## Project structure

```
config.js              # ALL tuning: palette, physics, Level 1 geometry, enemies
index.html             # entry point (Phaser config inline)
serve.py               # no-cache dev server
src/scenes/GameScene.js# the whole game: create() + update() loop
assets/
  reference/           # original game screenshots (per platform) used for tracing
  sprites/             # sprites ripped from the reference, transparent PNGs
NOTES.md               # running handoff log of fixes and decisions
BUILD_PLAN.md          # roadmap
```

## Tuning

Every magic number lives in `config.js`. Common dials:

- `player.jumpPower` (300) — deliberately below a tier's height so ladders matter
- `player.climbSpeed` (150), `player.jumpCoyoteFrames` (6)
- `gravity` (800) — higher = snappier fall
- `enemy.hoverAmp` / `hoverSpeed` / `moveSpeed` — the dragonfly's flight
- `platforms` / `ladders` / `exit` / `tree` — Level 1 layout

Edit, reload. No build.

## Not done yet

- Only Level 1 (the original has seven boards; references for all are in `assets/reference/`)
- Object mechanics (gem / key / doors) — sprites are ripped and waiting; they belong to board 2+
- No audio, no menu/pause, no persistence, no mobile/touch
- Orange support pillars from Level 1 are not modeled (cosmetic)

## Credits & references

- Original game: *Conan: Hall of Volta* — Datasoft, 1984 (Eric Robinson & Eric Parker)
- Reference screenshots via [MobyGames](https://www.mobygames.com/game/9293/conan/)
- Phaser 3.55 — https://phaser.io/docs/3.55.2

The art in `assets/` is from the original game and is included here as reference
for this non-commercial fan remake; all rights belong to the respective holders.
