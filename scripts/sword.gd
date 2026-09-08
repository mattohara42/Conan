## The sword. One scene, one script, one state machine, per CLAUDE.md.
##
## The rules are in SwordFlight and the node does not second-guess them: each
## frame it gathers the facts, asks for the next state, and behaves accordingly.
## Embed, recall and conduct are M2 and M3 and they become states here, not a
## second script.
class_name Sword
extends Area2D

## Back in the player's hand, caught in the air or picked up off the floor.
signal recovered
## Hit something solid mid-flight. That sword is gone.
signal destroyed

@export var config: SwordConfig
@export var world: WorldConfig

var state: SwordFlight.State = SwordFlight.State.FLYING

var _thrower: Node2D
var _velocity := Vector2.ZERO
var _distance_travelled := 0.0
var _return_distance := 0.0
var _hit_solid := false
var _landed := false

@onready var _shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("swords")
	var box := _shape.shape as RectangleShape2D
	box.size = Vector2(world.sword_length, world.sword_length * 0.36)
	body_entered.connect(func(_body: Node2D) -> void: _hit_solid = true)


## Called by whoever threw it. `direction` is -1 or 1: the sword has no arc and
## no vertical aim, which is the whole point of the flat return.
func launch(thrower: Node2D, direction: float) -> void:
	_thrower = thrower
	global_position = thrower.global_position
	_velocity = Vector2(signf(direction) * config.speed, 0.0)
	state = SwordFlight.State.FLYING


func _physics_process(delta: float) -> void:
	var target := _target_position()
	var offset_before := target.x - global_position.x

	_advance(delta)

	var offset_after := target.x - global_position.x
	var caught := (
		state == SwordFlight.State.RETURNING
		and SwordFlight.is_within(global_position, target, config.catch_radius)
	)
	var picked_up := (
		state == SwordFlight.State.GROUNDED
		and SwordFlight.is_within(global_position, target, config.pickup_radius)
	)

	var next := SwordFlight.next_state(
		state,
		SwordFlight.at_max_range(_distance_travelled, config.max_range),
		SwordFlight.return_spent(_return_distance, config.max_return_distance),
		caught,
		picked_up,
		_hit_solid,
		state == SwordFlight.State.RETURNING and SwordFlight.has_overshot(
			offset_before, offset_after
		),
		_landed
	)
	_hit_solid = false

	if next != state:
		_enter(next)
	queue_redraw()


## One step of whatever the current state does. Position is moved by hand rather
## than by a body, because a thrown object should pass through nothing and stop
## for nothing until the rules say so.
func _advance(delta: float) -> void:
	match state:
		SwordFlight.State.FLYING:
			var step := _velocity * delta
			global_position += step
			_distance_travelled += step.length()
			rotation += config.spin_speed * delta * signf(_velocity.x)
		SwordFlight.State.RETURNING:
			_velocity.x = SwordFlight.return_velocity_x(
				global_position.x, _target_position().x, config.speed
			)
			# y is untouched. The return leg is flat and that is the rule the
			# whole catch hangs off.
			var step := Vector2(_velocity.x * delta, 0.0)
			global_position += step
			_return_distance += absf(step.x)
			rotation += config.spin_speed * delta * signf(_velocity.x)
		SwordFlight.State.FALLING:
			_velocity = SwordFlight.step_fall(
				_velocity, config.fall_gravity, config.fall_drag,
				config.max_fall_speed, delta
			)
			_fall_by(_velocity * delta)


## Falling is the one time the sword needs the floor, so it looks for it rather
## than waiting to overlap it. Landing on a floor is not the same event as
## hitting a wall at speed, and only one of them destroys a sword.
func _fall_by(step: Vector2) -> void:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position, global_position + step + Vector2(0.0, world.sword_length * 0.5)
	)
	query.collision_mask = 1
	var hit := space.intersect_ray(query)
	if hit.is_empty():
		global_position += step
		return
	global_position = hit["position"] - Vector2(0.0, world.sword_length * 0.25)
	_landed = true


func _enter(next: SwordFlight.State) -> void:
	state = next
	match state:
		SwordFlight.State.RETURNING:
			_return_distance = 0.0
		SwordFlight.State.FALLING:
			# Keeps whatever horizontal speed it had, so a sword that sailed
			# past you lands past you.
			_velocity.y = 0.0
		SwordFlight.State.GROUNDED:
			_velocity = Vector2.ZERO
			rotation = 0.0
		SwordFlight.State.CAUGHT:
			recovered.emit()
			queue_free()
		SwordFlight.State.DESTROYED:
			destroyed.emit()
			queue_free()


## Where the sword is trying to get back to: where you are now, not where you
## threw from. CLAUDE.md lists that as settled and it is what makes moving
## during a throw a decision.
func _target_position() -> Vector2:
	if not is_instance_valid(_thrower):
		return global_position
	return _thrower.global_position


## Gold, because ART_DIRECTION.md reserves gold for things you interact with and
## nothing else gets to use it. Drawn rather than imported: no PNG before M5.
func _draw() -> void:
	var half := world.sword_length * 0.5
	var w := world.sword_length * 0.18
	draw_rect(Rect2(-half, -w * 0.45, half * 0.72, w * 0.9), Palette.GOLD_SHADE)
	draw_circle(Vector2(-half + w * 0.3, 0.0), w * 0.55, Palette.GOLD_SHADE)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-half * 0.28, -w),
		Vector2(half, 0.0),
		Vector2(-half * 0.28, w),
	]), Palette.GOLD_FACE)
	# A crossguard, drawn over the blade's base. Without it the silhouette reads
	# as a dart, and ART_DIRECTION.md makes silhouette a rule rather than taste.
	draw_rect(Rect2(-half * 0.4, -w * 1.6, w * 0.5, w * 3.2), Palette.GOLD_SHADE)
	if state == SwordFlight.State.GROUNDED:
		# A sword you can pick up should say so from across the room.
		draw_arc(
			Vector2.ZERO, config.pickup_radius, 0.0, TAU, 24,
			Color(Palette.GOLD_FACE, 0.35), 1.0
		)
