## The sword's state machine. SPEC.md calls the sword the whole reason to build
## this, so its transitions get walked one at a time rather than trusted.
extends TestCase

const DT := 1.0 / 60.0
const S := SwordFlight.State


## Every transition out of every live state, in one place, because that is what
## a transition table is for.
func test_the_machine_goes_where_it_says_it_goes() -> void:
	check_eq(_step(S.FLYING), S.FLYING, "flying stays flying")
	check_eq(_step(S.FLYING, {"at_max_range": true}), S.RETURNING, "range turns it around")
	check_eq(_step(S.FLYING, {"hit_solid": true}), S.DESTROYED, "a wall consumes it")

	check_eq(_step(S.RETURNING), S.RETURNING, "returning stays returning")
	check_eq(_step(S.RETURNING, {"caught": true}), S.CAUGHT, "a catch ends it well")
	check_eq(_step(S.RETURNING, {"hit_solid": true}), S.DESTROYED, "a wall ends it badly")
	check_eq(_step(S.RETURNING, {"overshot": true}), S.FALLING, "passing you spends it")
	check_eq(_step(S.RETURNING, {"return_spent": true}), S.FALLING, "so does running away")

	check_eq(_step(S.FALLING), S.FALLING, "falling stays falling")
	check_eq(_step(S.FALLING, {"on_floor": true}), S.GROUNDED, "it lands")

	check_eq(_step(S.GROUNDED), S.GROUNDED, "it waits")
	check_eq(_step(S.GROUNDED, {"picked_up": true}), S.CAUGHT, "you walk over to it")


## A catch beats a wall in the same frame. If the sword got inside your catch
## radius the throw already worked, and standing near a wall should not cost you
## a sword you had your hand on.
func test_a_catch_beats_a_solid_hit() -> void:
	check_eq(
		_step(S.RETURNING, {"caught": true, "hit_solid": true}), S.CAUGHT,
		"catch wins the tie"
	)


## A falling sword is already spent, and the floor it lands on is not what
## killed it. Without this a missed catch would destroy itself on landing and
## the done-when would be unreachable.
func test_landing_is_not_the_same_event_as_hitting_a_wall() -> void:
	check_eq(
		_step(S.FALLING, {"hit_solid": true, "on_floor": true}), S.GROUNDED,
		"it lands rather than shatters"
	)
	check_eq(_step(S.FALLING, {"hit_solid": true}), S.FALLING, "and a wall does not stop it")


func test_terminal_states_are_terminal() -> void:
	check_eq(_step(S.CAUGHT, {"hit_solid": true}), S.CAUGHT, "caught stays caught")
	check_eq(_step(S.DESTROYED, {"caught": true}), S.DESTROYED, "destroyed stays destroyed")


func test_range_and_return_budget_are_distances_not_guesses() -> void:
	check(not SwordFlight.at_max_range(199.0, 200.0), "still going out")
	check(SwordFlight.at_max_range(200.0, 200.0), "turns exactly at range")
	check(not SwordFlight.return_spent(299.0, 300.0), "still coming back")
	check(SwordFlight.return_spent(300.0, 300.0), "gives up exactly at the budget")


## The miss. The sword steers in x only, so crossing your x without catching is
## what a miss is, and it has to survive the player moving during the return.
func test_overshoot_is_a_sign_change_and_not_a_position() -> void:
	check(SwordFlight.has_overshot(12.0, -3.0), "crossed from ahead to behind")
	check(SwordFlight.has_overshot(-12.0, 3.0), "and the other way")
	check(not SwordFlight.has_overshot(12.0, 4.0), "still closing")
	check(not SwordFlight.has_overshot(-12.0, -4.0), "still closing, other side")
	check(not SwordFlight.has_overshot(0.0, -4.0), "landing exactly on you is not a miss")
	check(not SwordFlight.has_overshot(4.0, 0.0), "nor is arriving exactly on you")


func test_the_return_always_steers_at_full_speed_toward_you() -> void:
	check_eq(SwordFlight.return_velocity_x(100.0, 300.0, 420.0), 420.0, "you are to the right")
	check_eq(SwordFlight.return_velocity_x(300.0, 100.0, 420.0), -420.0, "you are to the left")
	check_eq(SwordFlight.return_velocity_x(100.0, 100.0, 420.0), 0.0, "you are right here")


func test_the_catch_window_is_a_radius() -> void:
	var origin := Vector2(100.0, 200.0)
	check(SwordFlight.is_within(origin, Vector2(110.0, 200.0), 14.0), "inside horizontally")
	check(SwordFlight.is_within(origin, Vector2(100.0, 213.0), 14.0), "inside vertically")
	check(not SwordFlight.is_within(origin, Vector2(115.0, 200.0), 14.0), "just outside")
	check(
		not SwordFlight.is_within(origin, Vector2(110.0, 210.0), 14.0),
		"diagonal distance is real distance, not the larger axis"
	)


## The height rule, stated as a test. A hero is 40 px tall and the catch radius
## is 14, so jumping is enough to miss and standing still is not.
func test_a_jump_is_enough_to_miss_and_standing_still_is_not() -> void:
	var throw_height := Vector2(100.0, 300.0)
	check(
		SwordFlight.is_within(throw_height, Vector2(100.0, 300.0), 14.0),
		"stood where you threw, you catch it"
	)
	check(
		not SwordFlight.is_within(throw_height, Vector2(100.0, 300.0 - 40.0), 14.0),
		"one hero height up and it goes under you"
	)


func test_a_spent_sword_falls_and_bleeds_off_its_speed() -> void:
	var speed := 420.0
	var drag := 600.0
	var velocity := Vector2(speed, 0.0)
	var frames := 0
	while not is_zero_approx(velocity.x) and frames < 600:
		velocity = SwordFlight.step_fall(velocity, 900.0, drag, 500.0, DT)
		frames += 1
	check_eq(velocity.x, 0.0, "horizontal speed reaches zero and stops there")
	check(velocity.y > 0.0, "and it is going down")
	# Time to stop is speed over drag, and saying so here means a change to
	# either number has to be a deliberate one.
	check_near(float(frames) * DT, speed / drag, DT * 1.5, "it takes speed over drag to stop")

	var terminal := Vector2.ZERO
	for i in 120:
		terminal = SwordFlight.step_fall(terminal, 900.0, 600.0, 500.0, DT)
	check_eq(terminal.y, 500.0, "capped at max fall speed")


func test_every_state_has_a_readable_name() -> void:
	for state in S.values():
		check(not SwordFlight.state_name(state).is_empty(), "state %d is named" % state)


## Defaults are "nothing has happened", so each case above states only the one
## fact it is about.
func _step(state: SwordFlight.State, facts: Dictionary = {}) -> SwordFlight.State:
	return SwordFlight.next_state(
		state,
		facts.get("at_max_range", false),
		facts.get("return_spent", false),
		facts.get("caught", false),
		facts.get("picked_up", false),
		facts.get("hit_solid", false),
		facts.get("overshot", false),
		facts.get("on_floor", false)
	)
