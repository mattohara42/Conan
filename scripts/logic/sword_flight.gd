## The sword's state machine, as pure functions.
##
## CLAUDE.md: the sword is one scene and one script, and every behaviour it has
## is a state in that one machine. This file is that machine's rules, kept out
## of the node so a headless test can walk every transition without a room.
##
## The return leg is flat. The sword comes back along the height it was thrown
## at, steering only in x toward wherever the player now is, which is what makes
## a missed catch possible at all: you miss by changing height, not by being in
## the wrong place. SPEC.md calls it a flat arc and the floating eyeball exists
## to sit on that line.
class_name SwordFlight

enum State {
	## Outbound, to max range.
	FLYING,
	## Coming back, steering in x toward the player's current position.
	RETURNING,
	## Spent. Gravity has it now.
	FALLING,
	## Lying on the floor, waiting to be walked over.
	GROUNDED,
	## Terminal: back in the player's hand.
	CAUGHT,
	## Terminal: hit something solid mid-flight and is gone.
	DESTROYED,
}


## The whole transition table in one function, so the machine can be read rather
## than reconstructed from scattered ifs.
##
## Order matters in RETURNING: a catch beats a solid hit. If the sword got
## inside your catch radius the throw already succeeded, and standing near a
## wall should not cost you the sword.
##
## A solid hit only destroys during flight. A sword that is already falling is
## already spent, and the floor it lands on is not what killed it.
static func next_state(
	state: State,
	at_max_range: bool,
	return_spent: bool,
	caught: bool,
	picked_up: bool,
	hit_solid: bool,
	overshot: bool,
	on_floor: bool
) -> State:
	match state:
		State.FLYING:
			if hit_solid:
				return State.DESTROYED
			if at_max_range:
				return State.RETURNING
			return State.FLYING
		State.RETURNING:
			if caught:
				return State.CAUGHT
			if hit_solid:
				return State.DESTROYED
			if overshot or return_spent:
				return State.FALLING
			return State.RETURNING
		State.FALLING:
			if on_floor:
				return State.GROUNDED
			return State.FALLING
		State.GROUNDED:
			if picked_up:
				return State.CAUGHT
			return State.GROUNDED
	return state


## True once the outbound leg has run its length.
static func at_max_range(distance_travelled: float, max_range: float) -> bool:
	return distance_travelled >= max_range


## True once the return leg has run out of patience, which is what happens when
## you run away from your own sword.
static func return_spent(return_distance: float, max_return_distance: float) -> bool:
	return return_distance >= max_return_distance


## The sword steers in x only, so passing the player's x without catching is the
## miss. Compared as signs rather than positions because the player is moving.
static func has_overshot(offset_before: float, offset_after: float) -> bool:
	if is_zero_approx(offset_before) or is_zero_approx(offset_after):
		return false
	return signf(offset_before) != signf(offset_after)


## Horizontal steering for the return leg. Full speed toward the player's x, and
## the height it was thrown at is not up for negotiation.
static func return_velocity_x(sword_x: float, target_x: float, speed: float) -> float:
	var offset := target_x - sword_x
	if is_zero_approx(offset):
		return 0.0
	return signf(offset) * speed


## True when the sword is close enough to be back in your hand.
static func is_within(sword_position: Vector2, target: Vector2, radius: float) -> bool:
	return sword_position.distance_squared_to(target) <= radius * radius


## One physics step of a spent sword falling, with its horizontal speed bleeding
## off so a miss lands near where it passed you.
static func step_fall(
	velocity: Vector2, gravity: float, drag: float, max_fall_speed: float, delta: float
) -> Vector2:
	return Vector2(
		move_toward(velocity.x, 0.0, drag * delta),
		minf(velocity.y + gravity * delta, max_fall_speed)
	)


## For the debug overlay, and for a test failure that should say more than "2".
static func state_name(state: State) -> String:
	return State.keys()[state].to_lower()
