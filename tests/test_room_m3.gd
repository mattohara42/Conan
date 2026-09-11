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
