/**
 * Conan Spike - Game Configuration
 * All tuning constants in one place for easy iteration.
 */

export const CONFIG = {
  // Canvas
  width: 800,
  height: 600,
  backgroundColor: '#0a1e2e',

  // Physics
  gravity: 800,
  
  // Conan
  player: {
    width: 20,
    height: 32,
    moveSpeed: 200,
    jumpPower: 450,
    jumpCoyoteFrames: 6, // frames after leaving ground where jump still works
    maxFallSpeed: 500,
    color: '#e8b4b8',
  },

  // Boomerang
  boomerang: {
    width: 8,
    height: 8,
    speed: 350,
    maxDistance: 250, // distance before it returns
    returnAccel: 800,
    color: '#ff9f43',
  },

  // Enemies
  enemy: {
    width: 24,
    height: 24,
    moveSpeed: 60,
    color: '#e74c3c',
  },

  // Level geometry (platforms as rects)
  platforms: [
    // Floor
    { x: 0, y: 550, width: 800, height: 50 },
    // Starting platform
    { x: 50, y: 480, width: 120, height: 20 },
    // Mid platforms (staggered climb)
    { x: 220, y: 420, width: 120, height: 20 },
    { x: 380, y: 360, width: 120, height: 20 },
    { x: 540, y: 300, width: 120, height: 20 },
    // Bridge to exit
    { x: 650, y: 240, width: 130, height: 20 },
  ],

  // Enemies: patrol between two points
  enemies: [
    { x: 230, y: 390, patrolLeft: 200, patrolRight: 320 },
    { x: 550, y: 270, patrolLeft: 480, patrolRight: 650 },
  ],

  // Exit zone (right side of level)
  exit: {
    x: 700,
    y: 200,
    width: 80,
    height: 60,
  },
};
