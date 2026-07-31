# Conan: Hall of Volta Spike

A faithful browser remake of the 1984 Datasoft platformer, starting with a tight jump-feel spike to validate core mechanics.

The original was punishingly difficult due to rigid jump mechanics (no mid-air correction, brutal precision requirements). This spike explores whether modern platforming feel (coyote time, horizontal air control) can keep the challenge while making the input less arbitrary.

## Quick Start

```bash
# Clone or cd into the repo
cd conan-spike

# Start a local dev server
python3 -m http.server 8080

# Open http://localhost:8080 in browser
```

No npm, no build step. Just Python's built-in server and Phaser 3 from CDN.

## Controls

- **Arrow keys**: Move left/right
- **Space**: Jump
- **X**: Throw boomerang (max 3 in flight)
- **R**: Restart level

## Project Structure

```
conan-spike/
├── index.html           # Entry point
├── config.js            # All tuning constants
├── src/
│   ├── main.js         # Phaser initialization (unused currently, inline in HTML)
│   └── scenes/
│       └── GameScene.js # Core gameplay loop
├── BUILD_PLAN.md       # Development milestones
└── README.md           # This file
```

## What's In This Spike

- One level: 6 platforms, climbing challenge layout
- Conan: tight controls with coyote time jump window, mid-air horizontal movement
- Boomerang: throw and return mechanic, max 3 in flight, catch by proximity
- Enemies: two patrol-type enemies, destroyed by boomerang, game-over if touched
- Exit: green zone on upper right, win condition

## Tuning

All magic numbers are in `config.js`. If the jump feels floaty, snappy, or unfair, the constants to tweak are:

- `player.jumpPower`: 450 (higher = higher/floatier)
- `player.jumpCoyoteFrames`: 6 (higher = more forgiving timing)
- `gravity`: 800 (higher = faster fall, snappier feel)

Edit, reload browser. No build needed.

## Known Limitations (Spike Scope)

- Geometric art only (no sprites yet)
- Single level
- No audio
- No high score / persistence
- No pause or menu
- No mobile/touch support

## Next Steps

See BUILD_PLAN.md for the roadmap. After validating jump feel, the path is: map 7 original levels, add sprite art, add audio, polish.

## References

- Original game: Conan: Hall of Volta (Datasoft, 1984)
- Phaser 3 docs: https://phaser.io/docs/3.55.2
