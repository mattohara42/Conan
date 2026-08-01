import { CONFIG } from '../../config.js';

export class GameScene extends Phaser.Scene {
  constructor() {
    super('GameScene');
  }

  preload() {
    // Sprites ripped from the original (assets/sprites/). More slot in as
    // their mechanics land (doors, gem, key, volta, avian-ally).
    this.load.spritesheet('conan', 'assets/sprites/conan-walk.png',
      { frameWidth: 16, frameHeight: 34 });
    this.load.image('enemy-dragonfly', 'assets/sprites/enemy-dragonfly.png');
  }

  create() {
    // Input handling
    this.cursors = this.input.keyboard.createCursorKeys();
    this.spaceKey = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE);
    this.xKey = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.X);
    this.rKey = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.R);

    // Arcade Sprites need a texture to render; make one 16x16 white block we tint per-object.
    // (Sprites have no setFillStyle — that's a Shape method — so we tint instead.)
    const g = this.add.graphics();
    g.fillStyle(0xffffff, 1).fillRect(0, 0, 16, 16);
    g.generateTexture('block', 16, 16);
    g.destroy();

    // Create platforms
    this.platforms = this.physics.add.staticGroup();
    CONFIG.platforms.forEach(p => {
      this.platforms.create(p.x + p.width / 2, p.y + p.height / 2, 'block')
        .setScale(p.width / 16, p.height / 16)
        .setOrigin(0.5, 0.5)
        .refreshBody();
    });
    this.platforms.children.entries.forEach((platform, i) => {
      const p = CONFIG.platforms[i];
      platform.displayWidth = p.width;
      platform.displayHeight = p.height;
      platform.setTint(CONFIG.palette.platform);
    });

    // Tree — a landable green spot off the right edge. Added to the platforms
    // group (so player/enemy collisions just work) after the magenta tint loop
    // so it keeps its foliage green.
    if (CONFIG.tree) {
      const t = CONFIG.tree;
      const tree = this.platforms.create(t.x + t.width / 2, t.y + t.height / 2, 'block')
        .setScale(t.width / 16, t.height / 16)
        .setOrigin(0.5, 0.5)
        .refreshBody();
      tree.displayWidth = t.width;
      tree.displayHeight = t.height;
      tree.setTint(CONFIG.palette.ladder); // foliage green
    }

    // Ladders — visual rects drawn over platforms + geom bounds for overlap tests
    this.ladderRects = (CONFIG.ladders || []).map(l => {
      this.add.rectangle(l.x + l.width / 2, l.y + l.height / 2, l.width, l.height,
        CONFIG.palette.ladder, 0.6);
      return new Phaser.Geom.Rectangle(l.x, l.y, l.width, l.height);
    });

    // Create player (Conan) — start bottom-right on the floor, like the original
    const startX = 740;
    const startY = CONFIG.platforms[0].y - CONFIG.player.height;
    // Walk cycle: frame 0 = stand, frame 1 = opposite stride. Idle holds frame 0.
    // (anims are global, so guard against re-creating them on scene.restart)
    if (!this.anims.exists('conan-walk')) {
      this.anims.create({
        key: 'conan-walk',
        frames: this.anims.generateFrameNumbers('conan', { start: 0, end: 1 }),
        frameRate: 8,
        repeat: -1,
      });
      this.anims.create({ key: 'conan-idle', frames: [{ key: 'conan', frame: 0 }] });
    }

    this.player = this.physics.add.sprite(startX, startY, 'conan');
    // Scale uniformly to the target height so the ripped pixels aren't distorted.
    this.player.setScale(CONFIG.player.height / this.player.height);
    this.player.setBounce(0.2);
    this.player.setCollideWorldBounds(true);
    this.player.setMaxVelocity(300, CONFIG.player.maxFallSpeed);

    // Player state
    this.player.isJumping = false;
    this.player.coyoteCounter = 0;
    this.player.climbing = false;
    this.player.boomerangs = [];

    // Collide player with platforms — but pass through them while climbing a ladder
    this.physics.add.collider(this.player, this.platforms, () => {
      this.player.coyoteCounter = CONFIG.player.jumpCoyoteFrames;
    }, () => !this.player.climbing);

    // Create enemies
    this.enemies = this.physics.add.group();
    CONFIG.enemies.forEach(e => {
      const enemy = this.physics.add.sprite(e.x, e.y, 'enemy-dragonfly');
      enemy.setScale(CONFIG.enemy.height / enemy.height); // preserve pixel aspect
      enemy.patrolLeft = e.patrolLeft;
      enemy.patrolRight = e.patrolRight;
      enemy.direction = 1; // 1 = right, -1 = left
      this.enemies.add(enemy);
      // Configure after adding to the group (group.add can reset the body).
      enemy.setVelocityX(CONFIG.enemy.moveSpeed * enemy.direction);
      if (e.fly) {
        enemy.fly = true;
        enemy.baseY = e.y; // hover centre; y bobs around this
        enemy.body.setAllowGravity(false);
      }
    });

    // Ground enemies collide with platforms; flyers ignore terrain
    this.physics.add.collider(this.enemies, this.platforms, null, (enemy) => !enemy.fly);

    // Enemy patrol AI (horizontal drift + vertical hover for flyers)
    this.events.on('update', (time) => {
      this.enemies.children.entries.forEach(enemy => {
        if (enemy.x <= enemy.patrolLeft && enemy.direction === -1) {
          enemy.direction = 1;
          enemy.setVelocityX(CONFIG.enemy.moveSpeed);
        } else if (enemy.x >= enemy.patrolRight && enemy.direction === 1) {
          enemy.direction = -1;
          enemy.setVelocityX(-CONFIG.enemy.moveSpeed);
        }
        enemy.setFlipX(enemy.direction < 0); // face travel direction
        if (enemy.fly) {
          enemy.y = enemy.baseY +
            Math.sin(time / 1000 * CONFIG.enemy.hoverSpeed) * CONFIG.enemy.hoverAmp;
        }
      });
    });

    // Exit zone (visual indicator)
    this.add.rectangle(
      CONFIG.exit.x + CONFIG.exit.width / 2,
      CONFIG.exit.y + CONFIG.exit.height / 2,
      CONFIG.exit.width,
      CONFIG.exit.height,
      CONFIG.palette.exit,
      0.3
    ).setStrokeStyle(2, CONFIG.palette.exit);

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
    // Restart must work after a win/death too, so check it before the early-return.
    if (Phaser.Input.Keyboard.JustDown(this.rKey)) {
      this.scene.restart();
      return;
    }
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
    if (velocityX < 0) this.player.setFlipX(true);
    else if (velocityX > 0) this.player.setFlipX(false);

    // Ladder climb: on a ladder, up/down climbs (gravity off); a direction or
    // jump dismounts, as does climbing off the top/bottom.
    const px = this.player.x;
    const pTop = this.player.y - CONFIG.player.height / 2;
    const pBot = this.player.y + CONFIG.player.height / 2;
    const ladder = this.ladderRects.find(r =>
      px >= r.x && px <= r.x + r.width && pBot >= r.y && pTop <= r.y + r.height);
    const up = this.cursors.up.isDown;
    const down = this.cursors.down.isDown;

    if (ladder && (up || down) && !this.player.climbing) {
      this.player.climbing = true;
      this.player.x = ladder.x + ladder.width / 2; // snap onto the rungs
    }
    if (this.player.climbing) {
      this.player.body.setAllowGravity(false);
      this.player.setVelocityY(up ? -CONFIG.player.climbSpeed : down ? CONFIG.player.climbSpeed : 0);
      const dismount = !ladder || velocityX !== 0 || this.spaceKey.isDown;
      if (dismount) {
        this.player.climbing = false;
        this.player.body.setAllowGravity(true);
      }
    }

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

    // Animate: climbing (legs pump, face the ladder) > walking (grounded + moving) > idle
    const onGround = this.player.body.blocked.down || this.player.body.touching.down;
    if (this.player.climbing) {
      this.player.setFlipX(false);
      if (up || down) this.player.anims.play('conan-walk', true);
      else this.player.anims.stop();
    } else if (onGround && velocityX !== 0) {
      this.player.anims.play('conan-walk', true);
    } else {
      this.player.anims.play('conan-idle', true);
    }

    // Coyote counter
    this.player.coyoteCounter--;

    // Boomerang throw: X key
    if (Phaser.Input.Keyboard.JustDown(this.xKey)) {
      this.throwBoomerang();
    }

    // Update boomerangs
    this.updateBoomerangs();

    // Check collision with enemies
    this.physics.overlap(this.player, this.enemies, () => {
      this.gameOver();
    });

    // A thrown sword kills any enemy it touches, then is spent
    this.player.boomerangs = this.player.boomerangs.filter(boom => {
      let hit = false;
      this.physics.overlap(boom.sprite, this.enemies, (bs, enemy) => {
        enemy.destroy();
        hit = true;
      });
      if (hit) {
        boom.sprite.destroy();
        return false;
      }
      return true;
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
      this.freezePlayer();
    }

    // Update HUD
    this.hudText.setText(`Boomerangs: ${this.player.boomerangs.length}`);
  }

  throwBoomerang() {
    if (this.player.boomerangs.length >= 3) return; // Max 3 in flight

    const boom = this.physics.add.sprite(this.player.x, this.player.y, 'block');
    boom.displayWidth = CONFIG.boomerang.width;
    boom.displayHeight = CONFIG.boomerang.height;
    boom.setTint(CONFIG.palette.weapon);

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
    this.freezePlayer();
  }

  // Stop the player dead when the round ends — update() early-returns on a
  // finished round, so without this the sprite keeps its last velocity and slides.
  freezePlayer() {
    this.player.setVelocity(0, 0);
    this.player.body.setAllowGravity(false);
    this.player.climbing = false;
  }
}
