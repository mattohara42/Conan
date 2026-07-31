import { CONFIG } from '../../config.js';

export class GameScene extends Phaser.Scene {
  constructor() {
    super('GameScene');
  }

  create() {
    // Input handling
    this.cursors = this.input.keyboard.createCursorKeys();
    this.spaceKey = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE);

    // Create platforms
    this.platforms = this.physics.add.staticGroup();
    CONFIG.platforms.forEach(p => {
      this.platforms.create(p.x + p.width / 2, p.y + p.height / 2)
        .setScale(p.width / 16, p.height / 16)
        .setOrigin(0.5, 0.5)
        .refreshBody();
    });
    this.platforms.children.entries.forEach((platform, i) => {
      const p = CONFIG.platforms[i];
      platform.displayWidth = p.width;
      platform.displayHeight = p.height;
      platform.setFillStyle(0x2c3e50);
    });

    // Create player (Conan)
    const startX = 110;
    const startY = CONFIG.platforms[1].y - CONFIG.player.height;
    this.player = this.physics.add.sprite(startX, startY, null);
    this.player.setScale(1);
    this.player.displayWidth = CONFIG.player.width;
    this.player.displayHeight = CONFIG.player.height;
    this.player.setFillStyle(0xe8b4b8);
    this.player.setBounce(0.2);
    this.player.setCollideWorldBounds(true);
    this.player.setMaxVelocity(300, CONFIG.player.maxFallSpeed);

    // Player state
    this.player.isJumping = false;
    this.player.coyoteCounter = 0;
    this.player.boomerangs = [];

    // Collide player with platforms
    this.physics.add.collider(this.player, this.platforms, () => {
      this.player.coyoteCounter = CONFIG.player.jumpCoyoteFrames;
    });

    // Create enemies
    this.enemies = this.physics.add.group();
    CONFIG.enemies.forEach(e => {
      const enemy = this.physics.add.sprite(e.x, e.y, null);
      enemy.displayWidth = CONFIG.enemy.width;
      enemy.displayHeight = CONFIG.enemy.height;
      enemy.setFillStyle(0xe74c3c);
      enemy.patrolLeft = e.patrolLeft;
      enemy.patrolRight = e.patrolRight;
      enemy.direction = 1; // 1 = right, -1 = left
      enemy.setVelocityX(CONFIG.enemy.moveSpeed * enemy.direction);
      this.enemies.add(enemy);
    });

    // Collide enemies with platforms
    this.physics.add.collider(this.enemies, this.platforms);

    // Enemy patrol AI
    this.events.on('update', () => {
      this.enemies.children.entries.forEach(enemy => {
        if (enemy.x <= enemy.patrolLeft && enemy.direction === -1) {
          enemy.direction = 1;
          enemy.setVelocityX(CONFIG.enemy.moveSpeed);
        } else if (enemy.x >= enemy.patrolRight && enemy.direction === 1) {
          enemy.direction = -1;
          enemy.setVelocityX(-CONFIG.enemy.moveSpeed);
        }
      });
    });

    // Exit zone (visual indicator)
    this.add.rectangle(
      CONFIG.exit.x + CONFIG.exit.width / 2,
      CONFIG.exit.y + CONFIG.exit.height / 2,
      CONFIG.exit.width,
      CONFIG.exit.height,
      0x27ae60,
      0.3
    ).setStrokeStyle(2, 0x27ae60);

    // HUD text
    this.hudText = this.add.text(20, 20, '', {
      fontSize: '16px',
      fill: '#ecf0f1',
      fontFamily: 'monospace',
    });

    // Game state
    this.gameState = {
      won: false,
    };
  }

  update() {
    if (this.gameState.won) return;

    // Player input
    let velocityX = 0;
    if (this.cursors.left.isDown) {
      velocityX = -CONFIG.player.moveSpeed;
    }
    if (this.cursors.right.isDown) {
      velocityX = CONFIG.player.moveSpeed;
    }
    this.player.setVelocityX(velocityX);

    // Jump logic: can jump if touching ground OR within coyote window
    const canJump = this.player.coyoteCounter > 0;
    if (Phaser.Input.Keyboard.JustDown(this.spaceKey) && canJump && !this.player.isJumping) {
      this.player.setVelocityY(-CONFIG.player.jumpPower);
      this.player.isJumping = true;
      this.player.coyoteCounter = 0;
    }

    // Landing detection (player colliding with platform resets jump state)
    if (this.player.body.blocked.down || this.player.body.touching.down) {
      this.player.isJumping = false;
    }

    // Coyote counter
    this.player.coyoteCounter--;

    // Boomerang throw: X key
    if (Phaser.Input.Keyboard.JustDown(this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.X))) {
      this.throwBoomerang();
    }

    // Update boomerangs
    this.updateBoomerangs();

    // Check collision with enemies
    this.physics.overlap(this.player, this.enemies, () => {
      this.gameOver();
    });

    // Check collision boomerang with enemies
    this.gameState.boomerangThrown && this.boomerangs.forEach(boom => {
      this.physics.overlap(boom.sprite, this.enemies, (boom, enemy) => {
        enemy.destroy();
        boom.destroy();
        this.boomerangs = this.boomerangs.filter(b => b.sprite !== boom);
      });
    });

    // Check win condition: player reaches exit
    if (
      this.player.x >= CONFIG.exit.x &&
      this.player.x <= CONFIG.exit.x + CONFIG.exit.width &&
      this.player.y >= CONFIG.exit.y &&
      this.player.y <= CONFIG.exit.y + CONFIG.exit.height
    ) {
      this.gameState.won = true;
      this.hudText.setText('VICTORY! Press R to restart');
    }

    // Update HUD
    this.hudText.setText(`Boomerangs: ${this.player.boomerangs.length}`);

    // Restart on R
    if (Phaser.Input.Keyboard.JustDown(this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.R))) {
      this.scene.restart();
    }
  }

  throwBoomerang() {
    if (this.player.boomerangs.length >= 3) return; // Max 3 in flight

    const boom = this.physics.add.sprite(this.player.x, this.player.y, null);
    boom.displayWidth = CONFIG.boomerang.width;
    boom.displayHeight = CONFIG.boomerang.height;
    boom.setFillStyle(0xff9f43);

    // Direction: right if moving right or stationary, left if moving left
    const direction = this.player.body.velocity.x >= 0 ? 1 : -1;
    boom.setVelocityX(CONFIG.boomerang.speed * direction);

    const boomerang = {
      sprite: boom,
      startX: boom.x,
      direction,
      returning: false,
    };

    this.player.boomerangs.push(boomerang);
  }

  updateBoomerangs() {
    this.player.boomerangs = this.player.boomerangs.filter(boom => {
      const distFromStart = Math.abs(boom.sprite.x - boom.startX);

      if (!boom.returning && distFromStart > CONFIG.boomerang.maxDistance) {
        boom.returning = true;
      }

      if (boom.returning) {
        // Return to player
        const towardPlayer = Phaser.Math.Distance.Between(
          boom.sprite.x,
          boom.sprite.y,
          this.player.x,
          this.player.y
        );

        if (towardPlayer < 20) {
          // Caught by player
          boom.sprite.destroy();
          return false;
        }

        const angle = Phaser.Math.Angle.Between(boom.sprite.x, boom.sprite.y, this.player.x, this.player.y);
        boom.sprite.setVelocityX(Math.cos(angle) * CONFIG.boomerang.speed);
        boom.sprite.setVelocityY(Math.sin(angle) * CONFIG.boomerang.speed);
      }

      // Out of bounds? destroy
      if (boom.sprite.y > CONFIG.height + 50 || boom.sprite.x < -50 || boom.sprite.x > CONFIG.width + 50) {
        boom.sprite.destroy();
        return false;
      }

      return true;
    });
  }

  gameOver() {
    this.gameState.won = true;
    this.hudText.setText('HIT! Press R to restart');
    this.player.setTint(0xff0000);
  }
}
