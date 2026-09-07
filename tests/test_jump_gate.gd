## Coyote time and jump buffering, which are the two things that decide whether
## a jump you meant to make happens.
extends TestCase

const DT := 1.0 / 60.0
const COYOTE := 0.10
const BUFFER := 0.12


func test_a_jump_needs_both_windows_open() -> void:
	check(JumpGate.should_jump(0.05, 0.05), "both open")
	check(not JumpGate.should_jump(0.0, 0.05), "no ground, no jump")
	check(not JumpGate.should_jump(0.05, 0.0), "no press, no jump")
	check(not JumpGate.should_jump(0.0, 0.0), "neither")


func test_coyote_time_survives_walking_off_a_ledge_and_then_expires() -> void:
	var timer := JumpGate.coyote_next(true, 0.0, COYOTE, DT)
	check_eq(timer, COYOTE, "standing on the floor keeps it full")

	# Five frames off the ledge is well inside a 0.10 s window.
	for i in 5:
		timer = JumpGate.coyote_next(false, timer, COYOTE, DT)
	check(timer > 0.0, "still legal five frames after the ledge")

	for i in 10:
		timer = JumpGate.coyote_next(false, timer, COYOTE, DT)
	check_eq(timer, 0.0, "expired, and clamped at zero rather than going negative")


func test_a_press_before_landing_is_remembered() -> void:
	var buffer := JumpGate.buffer_next(true, 0.0, BUFFER, DT)
	var coyote := 0.0
	# Falling, six frames between the press and the floor.
	for i in 6:
		buffer = JumpGate.buffer_next(false, buffer, BUFFER, DT)
		coyote = JumpGate.coyote_next(false, coyote, COYOTE, DT)
	check(not JumpGate.should_jump(coyote, buffer), "nothing to jump from yet")

	coyote = JumpGate.coyote_next(true, coyote, COYOTE, DT)
	check(JumpGate.should_jump(coyote, buffer), "the press is still good on landing")


func test_a_press_too_early_is_forgotten() -> void:
	var buffer := JumpGate.buffer_next(true, 0.0, BUFFER, DT)
	for i in 12:
		buffer = JumpGate.buffer_next(false, buffer, BUFFER, DT)
	check_eq(buffer, 0.0, "a press held over the window is dropped")


func test_tick_never_goes_negative() -> void:
	check_eq(JumpGate.tick(0.001, DT), 0.0, "clamped at zero")
