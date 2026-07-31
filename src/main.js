import { CONFIG } from '../config.js';
import { GameScene } from './scenes/GameScene.js';

const gameConfig = {
  type: Phaser.AUTO,
  width: CONFIG.width,
  height: CONFIG.height,
  backgroundColor: CONFIG.backgroundColor,
  physics: {
    default: 'arcade',
    arcade: {
      gravity: { y: CONFIG.gravity },
      debug: false,
    },
  },
  scene: GameScene,
};

const game = new Phaser.Game(gameConfig);
