## The capsule. Runs, jumps, climbs, and reads every number it uses out of a
## MovementConfig, so M14 can retune the whole game without opening this file.
##
## The rules live in scripts/logic/. This script owns state and the engine calls;
## it owns no arithmetic that a headless test would want to reach.
class_name Player
extends CharacterBody2D

## The two answers to the jump-versus-ladders question in SPEC.md. Swap between
## them live with Tab and decide by feel, which is the only way it can be decided.
@export var preset_strong: MovementConfig
@export var preset_ladders: MovementConfig
@export var world: WorldConfig

## Hero heights to cycle with [ and ], around ART_DIRECTION.md's estimate of 40.
const HERO_HEIGHT_STEPS: PackedFloat32Array = [28.0, 34.0, 40.0, 46.0, 54.0]

var config: MovementConfig
var spawn_point := Vector2.ZERO

# Forgiveness windows, owned here and interpreted by JumpGate.
var _coyote_timer := 0.0
var _buffer_timer := 0.0

# Ladders currently overlapping the body.
var _ladders_touched := 0
## Read by the debug overlay.
var climbing := false

# Read by the debug overlay. The apex of the jump you are in or just finished,
# measured in px above the point you left the floor.
var peak_height := 0.0
var _takeoff_y := 0.0

@onready var _shape: CollisionShape2D = $CollisionShape2D
@onready var _ladder_probe: Area2D = $LadderProbe
@onready var _probe_shape: CollisionShape2D = $LadderProbe/CollisionShape2D


func _ready() -> void:
	add_to_group("player")
	config = preset_strong
	spawn_point = global_position
	_apply_hero_size(world.hero_height)
	_ladder_probe.area_entered.connect(func(_a: Area2D) -> void: _ladders_touched += 1)
	_ladder_probe.area_exited.connect(func(_a: Area2D) -> void: _ladders_touched = maxi(_ladders_touched - 1, 0))


func _physics_process(delta: float) -> void:
	_handle_debug_keys()

	var on_floor := is_on_floor()
	var input_dir := Input.get_axis("move_left", "move_right")
	var climb_dir := Input.get_axis("climb_up", "climb_down")

	_coyote_timer = JumpGate.coyote_next(on_floor, _coyote_timer, config.coyote_time, delta)
	_buffer_timer = JumpGate.buffer_next(
		Input.is_action_just_pressed("jump"), _buffer_timer, config.jump_buffer_time, delta
	)

	if climbing:
		_step_climbing(input_dir, climb_dir, delta)
	else:
		_step_airborne(input_dir, climb_dir, on_floor, delta)

	move_and_slide()
	# After the move, so the apex is the position the body actually reached and
	# not the one it held a frame earlier.
	_track_peak()
	queue_redraw()


func _step_climbing(input_dir: float, climb_dir: float, delta: float) -> void:
	if _ladders_touched == 0 or Input.is_action_just_pressed("jump"):
		climbing = false
		if Input.is_action_just_pressed("jump"):
			_jump(delta)
		return
	velocity.y = climb_dir * config.climb_speed
	velocity.x = Motion.step_horizontal(
		velocity.x, input_dir, config.air_accel, config.ground_friction,
		config.climb_speed, delta
	)


func _step_airborne(input_dir: float, climb_dir: float, on_floor: bool, delta: float) -> void:
	if _ladders_touched > 0 and not is_zero_approx(climb_dir):
		climbing = true
		velocity = Vector2.ZERO
		return

	var gravity := Motion.gravity_for(config.jump_height, config.time_to_apex)
	velocity.y = Motion.step_vertical(
		velocity.y, gravity, config.fall_gravity_multiplier, config.max_fall_speed, delta
	)
	if Input.is_action_just_released("jump"):
		velocity.y = Motion.damp_on_release(velocity.y, config.jump_release_damping)

	velocity.x = Motion.step_horizontal(
		velocity.x,
		input_dir,
		config.ground_accel if on_floor else config.air_accel,
		config.ground_friction if on_floor else config.air_friction,
		config.max_run_speed,
		delta
	)

	if JumpGate.should_jump(_coyote_timer, _buffer_timer):
		_jump(delta)


func _jump(delta: float) -> void:
	velocity.y = -Motion.jump_speed_for(config.jump_height, config.time_to_apex, delta)
	# Taken here, before the body has moved. Sampling it from the floor check
	# instead reads the position after the first frame of the jump and reports
	# every apex one frame short.
	_takeoff_y = global_position.y
	peak_height = 0.0
	# Spend both windows, or one press keeps buying jumps all the way up.
	_coyote_timer = 0.0
	_buffer_timer = 0.0


## Records the apex of each jump so the overlay can answer "did that clear a
## tier" with a measurement instead of a guess. Called after the move, so it
## reads the height the body actually reached.
func _track_peak() -> void:
	if not is_on_floor():
		peak_height = maxf(peak_height, _takeoff_y - global_position.y)


func _apply_hero_size(height: float) -> void:
	world.hero_height = height
	var capsule := _shape.shape as CapsuleShape2D
	capsule.height = height
	capsule.radius = world.hero_width * 0.5
	var probe := _probe_shape.shape as RectangleShape2D
	probe.size = Vector2(world.hero_width * 0.5, height * 0.8)
	queue_redraw()


func _handle_debug_keys() -> void:
	if Input.is_action_just_pressed("debug_next_preset"):
		config = preset_ladders if config == preset_strong else preset_strong
	if Input.is_action_just_pressed("debug_respawn"):
		global_position = spawn_point
		velocity = Vector2.ZERO
		peak_height = 0.0
	var step := 0
	if Input.is_action_just_pressed("debug_size_up"):
		step = 1
	elif Input.is_action_just_pressed("debug_size_down"):
		step = -1
	if step != 0:
		var i := _nearest_size_index(world.hero_height)
		_apply_hero_size(HERO_HEIGHT_STEPS[clampi(i + step, 0, HERO_HEIGHT_STEPS.size() - 1)])


func _nearest_size_index(height: float) -> int:
	var best := 0
	for i in HERO_HEIGHT_STEPS.size():
		if absf(HERO_HEIGHT_STEPS[i] - height) < absf(HERO_HEIGHT_STEPS[best] - height):
			best = i
	return best


## A capsule, drawn rather than imported, because no PNG enters the repo before
## M5 and the shape of this thing is the point of the milestone.
func _draw() -> void:
	var h := world.hero_height
	var r := world.hero_width * 0.5
	var top := -h * 0.5 + r
	var bottom := h * 0.5 - r
	# ART_DIRECTION.md makes silhouette a rule rather than a taste, and against
	# STONE_MID platforms a STONE_LIT capsule does not separate. The fix the
	# direction names is a rim light from the nearest real light source, so the
	# grey box gets one too.
	var body := Color(Palette.GOLD_FACE, 0.95) if climbing else Palette.STONE_LIT
	draw_circle(Vector2(0.0, top), r, body)
	draw_circle(Vector2(0.0, bottom), r, body)
	draw_rect(Rect2(-r, top, r * 2.0, bottom - top), body)
	var facing := signf(velocity.x) if not is_zero_approx(velocity.x) else 1.0
	draw_line(
		Vector2(-facing * r * 0.85, top),
		Vector2(-facing * r * 0.85, bottom),
		Palette.FIRE_CORE,
		2.0
	)
	# A facing mark, so "which way am I pointing" is answerable at 40 px.
	draw_circle(Vector2(facing * r * 0.4, top + r * 0.2), r * 0.22, Palette.STONE_DEEP)
