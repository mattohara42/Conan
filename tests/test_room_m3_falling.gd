## The falling-platform bench, as arithmetic.
##
## Same claim as the other two M3 benches: not that the room is clever, but that
## it can be finished at all. A death bench you cannot cross stops measuring the
## death loop and starts measuring frustration with the room.
##
## The difference here is that the room is built against a clock as well as
## against a jump, so half of these check distance and half check time.
extends TestCase

const HAZARDS := "res://config/hazards.tres"


func _move() -> MovementConfig:
	return load("res://config/movement.tres")


## How far a full-speed jump carries you on the flat, which is what every hop in
## this room is measured against. The crossings are level start to finish.
func _reach() -> float:
	var move := _move()
	return Motion.jump_reach(
		move.jump_height, move.time_to_apex, move.fall_gravity_multiplier,
		move.max_run_speed, 0.0
	)


func test_every_hop_is_a_comfortable_jump() -> void:
	var fraction := RoomM3Falling.HOP / _reach()
	check(
		fraction < 0.6,
		"a hop is %.0f%% of a full-speed jump" % [fraction * 100.0]
	)


## The distance is deliberately easy, because the question this room asks is
## about time. A hop that was also marginal would produce deaths that cannot be
## told apart, and then neither half is being measured.
func test_the_room_asks_about_time_and_not_about_distance() -> void:
	var move := _move()
	var hazards: HazardConfig = load(HAZARDS)
	var crossing := RoomM3Falling.SLAB_SIZE.x / move.max_run_speed
	check(
		hazards.platform_warn_time > crossing,
		"a slab holds you for %.2f s and takes %.2f s to cross at a run" % [
			hazards.platform_warn_time, crossing
		]
	)
	check(
		hazards.platform_warn_time < crossing * 2.5,
		"and not so long that you can stand on it and think about it"
	)


## You land on a slab at whatever speed the last jump left you, but the honest
## case is the one where you land badly and stop. A slab you cannot get back to
## full speed on would make the next hop unmakeable for reasons the room never
## shows you.
func test_a_slab_is_long_enough_to_take_off_from_standing() -> void:
	var move := _move()
	var needed := Motion.run_up_distance(move.max_run_speed, move.ground_accel)
	check(
		RoomM3Falling.SLAB_SIZE.x * 0.5 > needed,
		"half a slab is %.0f px and reaching full speed needs %.0f" % [
			RoomM3Falling.SLAB_SIZE.x * 0.5, needed
		]
	)


## The point of the room. If either moat could be jumped, the platforms are
## scenery and nothing in here is being measured.
func test_neither_moat_can_be_jumped() -> void:
	var reach := _reach()
	var moats := {
		"the first": RoomM3Falling.ISLAND_START - RoomM3Falling.FIRST_BANK_END,
		"the second": RoomM3Falling.LAST_BANK_START - RoomM3Falling.ISLAND_END,
	}
	for name in moats:
		check(
			moats[name] > reach * 1.5,
			"%s moat is %.0f px against a reach of %.0f" % [name, moats[name], reach]
		)


## The slabs and the banks are generated from the same two numbers, so this is
## the check that they still meet. A crossing that lands half a hop short of the
## far bank is a room nobody can finish, and it draws perfectly well.
func test_both_crossings_reach_the_bank_they_are_aimed_at() -> void:
	check_eq(
		RoomM3Falling.far_bank_of(RoomM3Falling.first_crossing()),
		RoomM3Falling.ISLAND_START,
		"the first crossing lands on the island"
	)
	check_eq(
		RoomM3Falling.far_bank_of(RoomM3Falling.second_crossing()),
		RoomM3Falling.LAST_BANK_START,
		"the second crossing lands on the far bank"
	)
	check_eq(RoomM3Falling.first_crossing().size(), 2, "two slabs in the first moat")
	check_eq(RoomM3Falling.second_crossing().size(), 3, "three in the second")


func test_every_slab_stands_clear_of_the_lava_it_is_over() -> void:
	check(
		RoomM3Falling.LAVA_INSET > RoomM3Falling.SLAB_SIZE.y,
		"a resting slab hangs above the lava rather than in it"
	)
	for slab in RoomM3Falling.first_crossing() + RoomM3Falling.second_crossing():
		check_eq(slab.position.y, Bench.FLOOR_TOP, "and its top face is level with the floor")


## Same rule as the other two benches: the mid brazier sits between the two
## hazards, so a death at the second one costs you that crossing and not the one
## you already made.
func test_the_mid_brazier_banks_the_first_crossing() -> void:
	check(
		RoomM3Falling.MID_BRAZIER_X > RoomM3Falling.ISLAND_START,
		"the mid brazier is on the island, past the first moat"
	)
	check(
		RoomM3Falling.MID_BRAZIER_X < RoomM3Falling.ISLAND_END,
		"and before the second one, which is the one you die in"
	)


## A checkpoint you cannot make the next jump from is worse than no checkpoint,
## because you only find out after you have already died once.
func test_the_second_crossing_is_still_makeable_from_the_mid_brazier() -> void:
	var move := _move()
	var run_up := RoomM3Falling.ISLAND_END - RoomM3Falling.MID_BRAZIER_X
	var needed := Motion.run_up_distance(move.max_run_speed, move.ground_accel)
	check(
		run_up > needed,
		"the respawn has %.0f px of island before the moat and needs %.0f" % [run_up, needed]
	)


func test_the_start_brazier_is_on_the_first_bank() -> void:
	check(
		RoomM3Falling.START_BRAZIER_X < RoomM3Falling.FIRST_BANK_END,
		"the start brazier is on the floor you begin on"
	)


func test_there_is_floor_past_the_last_crossing() -> void:
	check(
		RoomM3Falling.LAST_BANK_START < RoomM3Falling.ROOM_WIDTH - 60.0,
		"the far bank is long enough to hold the exit you are running at"
	)
