# Sprites — ripped from the original Conan (Datasoft, 1984)

Extracted from the Apple II reference screenshots (`assets/reference/apple2/`):
Cast of Characters + Objects screens (isolated on black), and the Level 1 frame
for the enemy. Black background keyed to transparent; native pixel sizes kept.

| File                 | Size   | Source screen        |
|----------------------|--------|----------------------|
| conan.png            | 16×34  | cast-of-characters   |
| volta.png            | 20×39  | cast-of-characters   |
| avian-ally.png       | 31×24  | cast-of-characters   |
| enemy-dragonfly.png  | 36×20  | level-1 (the enemy)  |
| key.png              | 20×8   | objects              |
| door-locked.png      | 28×38  | objects              |
| door-unlocked.png    | 28×38  | objects              |
| gem.png              | 16×12  | objects              |
| gem-holder.png       | 16×16  | objects              |
| sword.png            | 19×12  | objects              |

These are tiny (authentic Apple II resolution) — load them into Phaser and scale
up with nearest-neighbour (`setScale`, no smoothing) to keep the crisp pixels.
Re-extraction script logic lives in the git history of this session's work.
