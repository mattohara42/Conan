## Motion is the arithmetic behind the jump. These are the checks that stop a
## tuning change in a .tres from silently meaning something other than it says.
extends TestCase

const DT := 1.0 / 60.0


## The contract of the whole config file: author a height and a time, get a jump
## that reaches that height at that time.
func test_a_jump_reaches_the_authored_height_at_the_authored_time() -> void:
	var height := 112.0
	var time_to_apex := 0.36
	var gravity := Motion.gravity_for(height, time_to_apex)
	var velocity_y := -Motion.jump_speed_for(height, time_to_apex, DT)
	var y := 0.0
	var peak := 0.0
	var elapsed := 0.0
	var time_at_peak := 0.0
	# The order matters and it is the player's order: a jump sets velocity, the
	# body moves that whole frame, and gravity arrives at the top of the next
	# one. Simulating it the other way around is how the compensation term in
	# jump_speed_for got the right size with the wrong sign, green, for an hour.
	while elapsed < 1.0 and velocity_y < 0.0:
		y += velocity_y * DT
		elapsed += DT
		if -y > peak:
			peak = -y
			time_at_peak = elapsed
		velocity_y = Motion.step_vertical(velocity_y, gravity, 1.0, 10000.0, DT)
	# Tight, because the half-step compensation in jump_speed_for makes the
	# discrete apex exact rather than approximate. If this drifts, that term is
	# wrong or the integration order in the player has changed.
	check_near(peak, height, 0.05, "apex height")
	check_near(time_at_peak, time_to_apex, DT, "time to apex")


func test_gravity_and_takeoff_are_zero_for_a_zero_time_to_apex() -> void:
	check_eq(Motion.gravity_for(112.0, 0.0), 0.0, "gravity guards a zero time")
	check_eq(Motion.jump_speed_for(112.0, 0.0, DT), 0.0, "takeoff guards a zero time")


## Without the half-step term the jump overshoots, which is the bug the
## compensation exists to fix. Keeping the uncompensated case here means the
## reason for that term stays visible.
func test_the_uncompensated_takeoff_overshoots() -> void:
	var plain := Motion.jump_speed_for(112.0, 0.36)
	var compensated := Motion.jump_speed_for(112.0, 0.36, DT)
	check(compensated < plain, "compensation removes speed")
	check_near(
		plain - compensated, Motion.gravity_for(112.0, 0.36) * DT * 0.5, 0.001,
		"and it removes exactly half a frame of gravity"
	)


func test_falling_is_heavier_than_rising() -> void:
	var gravity := 1728.0
	var rising := Motion.step_vertical(-100.0, gravity, 1.6, 700.0, DT)
	var falling := Motion.step_vertical(100.0, gravity, 1.6, 700.0, DT)
	check_near(rising - -100.0, gravity * DT, 0.001, "rising uses plain gravity")
	check_near(falling - 100.0, gravity * 1.6 * DT, 0.001, "falling uses the multiplier")


func test_fall_speed_is_capped() -> void:
	var velocity_y := 0.0
	for i in 600:
		velocity_y = Motion.step_vertical(velocity_y, 1728.0, 1.6, 700.0, DT)
	check_eq(velocity_y, 700.0, "terminal velocity")


func test_running_accelerates_to_top_speed_and_stops_there() -> void:
	var velocity_x := 0.0
	for i in 60:
		velocity_x = Motion.step_horizontal(velocity_x, 1.0, 1600.0, 2400.0, 200.0, DT)
	check_eq(velocity_x, 200.0, "reaches and holds top speed")


func test_friction_stops_dead_without_overshooting() -> void:
	var velocity_x := 200.0
	for i in 60:
		velocity_x = Motion.step_horizontal(velocity_x, 0.0, 1600.0, 2400.0, 200.0, DT)
	check_eq(velocity_x, 0.0, "friction settles at zero, not past it")


func test_turning_around_crosses_zero_rather_than_snapping() -> void:
	var velocity_x := 200.0
	velocity_x = Motion.step_horizontal(velocity_x, -1.0, 1600.0, 2400.0, 200.0, DT)
	check_near(velocity_x, 200.0 - 1600.0 * DT, 0.001, "turn is an acceleration")


func test_releasing_jump_cuts_a_rise_and_leaves_a_fall_alone() -> void:
	check_near(Motion.damp_on_release(-400.0, 0.4), -160.0, 0.001, "a rise is cut")
	check_eq(Motion.damp_on_release(300.0, 0.4), 300.0, "a fall is untouched")
	check_eq(Motion.damp_on_release(0.0, 0.4), 0.0, "the apex is untouched")


## The distance and the time have to agree, or a room designed against one and
## played against the other is designed against nothing. Stepping the real
## horizontal integrator is the only honest check of the closed form.
func test_run_time_agrees_with_running() -> void:
	var distance := 48.0
	var stepped := 0.0
	var velocity_x := 0.0
	var elapsed := 0.0
	while stepped < distance and elapsed < 5.0:
		velocity_x = Motion.step_horizontal(velocity_x, 1.0, 1600.0, 2400.0, 200.0, DT)
		stepped += velocity_x * DT
		elapsed += DT
	check_near(
		Motion.run_time(distance, 200.0, 1600.0), elapsed, DT * 2.0,
		"the closed form matches the integrator over %.0f px" % distance
	)


func test_run_time_holds_top_speed_once_it_has_it() -> void:
	var ramp := Motion.run_up_distance(200.0, 1600.0)
	var to_ramp := Motion.run_time(ramp, 200.0, 1600.0)
	check_near(to_ramp, 200.0 / 1600.0, 0.001, "the ramp takes speed over acceleration")
	check_near(
		Motion.run_time(ramp + 200.0, 200.0, 1600.0), to_ramp + 1.0, 0.001,
		"and every second after it is another top speed of floor"
	)
	check_eq(Motion.run_time(0.0, 200.0, 1600.0), 0.0, "going nowhere takes no time")
	check_eq(
		Motion.run_time(10.0, 200.0, 0.0), INF,
		"and a mover that cannot accelerate never arrives"
	)
