/**
 * Conan Spike - Game Configuration
 * All tuning constants in one place for easy iteration.
 */

export const CONFIG = {
  // Canvas
  width: 800,
  height: 600,

  // Physics
  gravity: 800,

  // Palette — sampled from the original Conan (Datasoft, 1984), C64 release.
  // See assets/reference/. All 4 platforms share the scheme: black bg, magenta
  // structures, green ladders/foliage, white Conan. Accents differ per platform
  // (Apple II had orange; Sharp X1 had red) — we borrow both for gameplay clarity.
  palette: {
    background: 0x191d19, // C64 near-black
    platform:   0xd27ded, // magenta walls / terrain (the signature color)
    ladder:     0x6acf6f, // green ladders & foliage (unused until ladders land)
    conan:      0xfcf9fc, // white
    enemy:      0xff5555, // originals drew enemies white; kept distinct for playability
    weapon:     0xfc8204, // Apple II orange (thrown sword)
    exit:       0x6acf6f, // green
    accent:     0xd89c5b, // tan bridges/wood (C64 level 3)
  },

  // Conan
  player: {
    width: 20,
    height: 32,
    moveSpeed: 200,
    jumpPower: 300, // peak ~56px — a hop, deliberately under a tier (75px) so ladders matter
    jumpCoyoteFrames: 6, // frames after leaving ground where jump still works
    maxFallSpeed: 500,
    climbSpeed: 150, // up/down speed while on a ladder
  },

  // Boomerang
  boomerang: {
    width: 8,
    height: 8,
    speed: 350,
    maxDistance: 250, // distance before it returns
    returnAccel: 800,
  },

  // Enemies
  enemy: {
    width: 24,
    height: 24,
    moveSpeed: 60,
    hoverAmp: 35,     // flyers: vertical bob amplitude (px)
    hoverSpeed: 2.2,  // flyers: bob rate (radians/sec)
  },

  // Level 1 geometry — traced pixel-for-pixel from the original Conan Level 1
  // (assets/reference/sharp-x1/level-1.png) via scan of the magenta platform
  // rows and green ladder columns, then mapped to the 800x600 canvas.
  // A castle interior of 5 stacked levels joined by ladders; climb from the
  // bottom-right floor up to the exit on the top wall.
  // Tier tops (game y): TOP 120, T2 225, T3 341, T4 469, floor 560.
  platforms: [
    { x: 0,   y: 560, width: 800, height: 40 }, // floor (added; original has hazard-poles here)
    { x: 50,  y: 469, width: 546, height: 16 }, // T4 — long lower run
    { x: 55,  y: 341, width: 316, height: 16 }, // T3
    { x: 50,  y: 225, width: 386, height: 16 }, // T2 left
    { x: 510, y: 225, width: 136, height: 16 }, // T2 right (real gap before it)
    { x: 105, y: 120, width: 541, height: 16 }, // TOP wall (spans to the turrets on the right)
  ],

  // Ladders — 4 forming the main climb path (the original's extra right-wall
  // ladder is omitted for now). Positions traced from the green columns; a couple
  // nudged so each lands cleanly on the platform above.
  ladders: [
    { x: 467, y: 469, width: 28, height: 107 }, // floor -> T4
    { x: 250, y: 341, width: 28, height: 144 }, // T4 -> T3
    { x: 97,  y: 225, width: 28, height: 132 }, // T3 -> T2 left
    { x: 542, y: 120, width: 28, height: 121 }, // T2 right -> TOP (true position: right, by the turrets)
  ],

  // Level 1 has a single enemy — the flying dragonfly creature that patrols the
  // mid area (assets/reference/apple2/level-1.png). Modeled as a ground patroller
  // on the middle tier for now; the original actually flies. ponytail: upgrade to
  // a hovering/flying enemy type when enemy variety matters.
  enemies: [
    // The dragonfly flies: y is its hover centre (in open air above T3), and it
    // drifts left/right between patrolLeft/patrolRight while bobbing vertically.
    { x: 200, y: 285, patrolLeft: 70, patrolRight: 360, fly: true },
  ],

  // Exit — top-left of the top wall (top of the climb)
  exit: {
    x: 120,
    y: 65,
    width: 80,
    height: 55,
  },

  // Tree — a landable green spot off the right side (reference: the tree at the
  // right edge of Level 1). Just a reachable spot, not the exit. Reachable by
  // jumping off the right end of the top-right platform (T2 right).
  tree: {
    x: 660,
    y: 310,
    width: 120,
    height: 18,
  },

};
