## Pure motion arithmetic. No nodes, no state, no engine singletons, so the
## headless tests can reach every line of it.
##
## Godot's Y axis points down, so a rising velocity is negative and a falling
## one is positive. Every function here is written in those terms.
class_name Motion


## Constant gravity that makes a jump of `height` reach its apex in
## `time_to_apex`. Derived rather than authored: see MovementConfig.
static func gravity_for(height: float, time_to_apex: float) -> float:
	if time_to_apex <= 0.0:
		return 0.0
	return (2.0 * height) / (time_to_apex * time_to_apex)


## Takeoff speed for that same jump, as a positive magnitude. Apply it upward.
##
## The `delta` term is half a step of gravity and it is not a fudge. A jump sets
## velocity and the body then moves that whole frame before gravity touches it
## again, so the textbook takeoff speed overshoots the authored height by half a
## frame: at 60 Hz an authored 112 px jump measures 122. Subtracting
## `gravity * delta / 2` cancels that exactly, and it lands the apex on the
## authored time as well.
##
## The sign here depends on the order the character script does things in, which
## is why a green test was not enough to get it right. Pass the physics delta.
## Leaving it at zero gives the uncompensated textbook value.
static func jump_speed_for(height: float, time_to_apex: float, delta: float = 0.0) -> float:
	if time_to_apex <= 0.0:
		return 0.0
	return (2.0 * height) / time_to_apex - gravity_for(height, time_to_apex) * delta * 0.5


## One physics step of vertical motion. Falling uses a heavier gravity than
## rising, which is the single cheapest thing that stops a jump feeling floaty.
static func step_vertical(
	velocity_y: float,
	gravity: float,
	fall_multiplier: float,
	max_fall_speed: float,
	delta: float
) -> float:
	var g: float = gravity * (fall_multiplier if velocity_y > 0.0 else 1.0)
	return minf(velocity_y + g * delta, max_fall_speed)


## One physics step of horizontal motion. With no input the mover decelerates to
## a stop and does not overshoot into the opposite direction.
static func step_horizontal(
	velocity_x: float,
	input_dir: float,
	accel: float,
	friction: float,
	max_speed: float,
	delta: float
) -> float:
	if is_zero_approx(input_dir):
		return move_toward(velocity_x, 0.0, friction * delta)
	return move_toward(velocity_x, signf(input_dir) * max_speed, accel * delta)


## Releasing jump while still rising cuts the climb short. This is what makes
## jump height variable by hold duration without a second jump state.
static func damp_on_release(velocity_y: float, damping: float) -> float:
	if velocity_y >= 0.0:
		return velocity_y
	return velocity_y * damping
