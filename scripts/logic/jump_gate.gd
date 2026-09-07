## Coyote time and jump buffering, as four pure functions and no state.
##
## The character script owns the two timers. This file owns what they mean, so
## the forgiveness window is testable without a floor to walk off.
class_name JumpGate


## Counts a timer down, never past zero.
static func tick(timer: float, delta: float) -> float:
	return maxf(timer - delta, 0.0)


## Refilled while standing on something, draining once you are not. A jump is
## still legal until it empties, which is coyote time.
static func coyote_next(on_floor: bool, timer: float, coyote_time: float, delta: float) -> float:
	return coyote_time if on_floor else tick(timer, delta)


## Refilled by a press, draining afterwards. A press that arrives just before
## landing is still legal when you land, which is jump buffering.
static func buffer_next(just_pressed: bool, timer: float, buffer_time: float, delta: float) -> float:
	return buffer_time if just_pressed else tick(timer, delta)


## The jump happens when both windows are open at the same moment.
static func should_jump(coyote_timer: float, buffer_timer: float) -> bool:
	return coyote_timer > 0.0 and buffer_timer > 0.0
