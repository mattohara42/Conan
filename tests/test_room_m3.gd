## M3's bench, as arithmetic.
##
## The room's claim is narrower than M2's: not that it needs the sword, but that
## **it can be finished at all**. A death bench you cannot cross stops measuring
## the death loop and starts measuring frustration with the room, and those are
## different findings.
##
## If M14 retunes the jump and this goes red, the gaps need resizing.
extends TestCase


func _reach() -> float:
	var move: MovementConfig = load("res://config/movement.tres")
	# Rise of zero: both landings are level with both takeoffs.
	return Motion.jump_reach(
		move.jump_height, move.time_to_apex, move.fall_gravity_multiplier,
		move.max_run_speed, 0.0
	)


func test_both_gaps_can_be_jumped() -> void:
	var reach := _reach()
	var easy := RoomM3.EASY_GAP.y - RoomM3.EASY_GAP.x
	var marginal := RoomM3.MARGINAL_GAP.y - RoomM3.MARGINAL_GAP.x
	check(
		easy < reach,
		"the easy gap is %.0f px against a reach of %.0f" % [easy, reach]
	)
	check(
		marginal < reach,
		"the marginal gap is %.0f px against a reach of %.0f" % [marginal, reach]
	)


## The second gap earns its name. Comfortably clearable is not what it is for:
## the deaths this bench exists to produce come from a jump you nearly made.
func test_the_marginal_gap_is_actually_marginal() -> void:
	var reach := _reach()
	var marginal := RoomM3.MARGINAL_GAP.y - RoomM3.MARGINAL_GAP.x
	var fraction := marginal / reach
	check(
		fraction > 0.85,
		"the marginal gap is %.0f%% of a full-speed jump, which is too easy to fall into" % [
			fraction * 100.0
		]
	)


func test_the_gaps_do_not_overlap_the_floor() -> void:
	check(
		RoomM3.EASY_GAP.y < RoomM3.MARGINAL_GAP.x,
		"the two gaps are separated by a run of floor to build speed on"
	)
	check(
		RoomM3.MARGINAL_GAP.y < RoomM3.ROOM_WIDTH,
		"there is floor past the last gap to land on"
	)


## The checkpoint has to be past the first gap, or a death at the second one
## charges you for a jump you already made. That is the whole reason braziers
## exist and it is one comparison.
func test_the_mid_brazier_banks_the_first_gap() -> void:
	check(
		RoomM3.MID_BRAZIER_X > RoomM3.EASY_GAP.y,
		"the mid brazier is at %.0f, past the easy gap which ends at %.0f" % [
			RoomM3.MID_BRAZIER_X, RoomM3.EASY_GAP.y
		]
	)
	check(
		RoomM3.MID_BRAZIER_X < RoomM3.MARGINAL_GAP.x,
		"the mid brazier is before the marginal gap, which is the one you die at"
	)


## A checkpoint you cannot make the next jump from is worse than no checkpoint,
## because you only find that out after you have already died once. The respawn
## stands still, so the floor between it and the gap has to be long enough to
## accelerate across.
func test_the_marginal_gap_is_still_jumpable_from_the_mid_brazier() -> void:
	var move: MovementConfig = load("res://config/movement.tres")
	var run_up := RoomM3.MARGINAL_GAP.x - RoomM3.MID_BRAZIER_X
	var needed := Motion.run_up_distance(move.max_run_speed, move.ground_accel)
	check(
		run_up > needed,
		"the respawn has %.0f px of floor before the gap and needs %.0f to reach full speed" % [
			run_up, needed
		]
	)


## The start brazier is where the room puts you, so the first frame of the room
## already has a checkpoint in it.
func test_the_start_brazier_is_at_the_start() -> void:
	check(
		RoomM3.START_BRAZIER_X < RoomM3.EASY_GAP.x,
		"the start brazier is on the first run of floor"
	)
