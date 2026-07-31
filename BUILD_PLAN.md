# Conan Spike: Build Plan

## Spike M1: Playable Core (CURRENT)

Feasibility check: Can we make platforming that feels tight and fair with mid-air control and coyote time?

### Done
- Single level geometry (6 platforms + exit)
- Conan: movement (left/right), jump with coyote time, mid-air X-correction
- Boomerang: throw (X key), max 3 in flight, return mechanic, catch by proximity
- Enemy: single patrol type, destroyed by boomerang hit
- Collision: player/platform, enemy/platform, boomerang/enemy, player/enemy (lose)
- Win state: reach green exit zone
- Basic visual design (CGA-style colors, geometric shapes)

### Tuning Notes
All constants live in `config.js`. Key values to iterate on:
- `player.jumpPower`: 450 (higher = higher jump)
- `player.jumpCoyoteFrames`: 6 (allows jump up to 6 frames after leaving ground)
- `gravity`: 800 (higher = faster fall)
- `player.moveSpeed`: 200
- `player.maxFallSpeed`: 500

## Next: Iterate Jump Feel (M2)

Play the spike. If jump feels good, move to full game. If it feels off:

1. Record what's wrong (floaty? too snappy? landing feels unfair?)
2. Adjust tuning constants in config.js
3. Reload and test
4. Rinse, repeat

Target: Jump should feel responsive but not punishing. You should be able to thread tight gaps, but it should still take practice.

## Path to Full Game (M3+)

Once spike feels right:

1. **Level design**: Map 7 original levels from Conan: Hall of Volta (or longplay video)
2. **Art**: Replace geometric shapes with sprite art (retro-style pixel art, consistent with 1984 aesthetic)
3. **Audio**: Ambient background loop, jump/land/boomerang SFX, enemy hit, win/lose stings
4. **Polish**: Screen transitions, pause menu, high score tracking (localStorage)

## Assumptions Logged

- No mid-jump height control (player cannot modulate jump; full commit on space)
- Boomerang always returns if not caught (no max time-in-air)
- Enemies are simple patrol AI, no vision/attack
- Single button throws boomerang in direction of last movement (or right if stationary)
- Game is 60fps, canvas-based, Phaser 3 arcade physics
- No touch/mobile controls yet (desktop only)

## Running

```bash
# Start local dev server in project root
python3 -m http.server 8080

# Open http://localhost:8080 in browser
```

No build step. All code in src/, config in config.js, assets inline (colors).
