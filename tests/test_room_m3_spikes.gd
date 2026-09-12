## The spike bench, as arithmetic.
##
## Same claim as `test_room_m3.gd` makes for the lava bench: not that the room
## is clever, but that it can be finished at all. A death bench you cannot cross
## stops measuring the death loop and starts measuring frustration with the room.
##
## The bed widths are made of `config/hazards.tres`, so retuning the teeth in
## M14 moves these numbers and this file says whether the room survived it.
extends TestCase

const HAZARDS := "res://config/hazards.tres"


func _move() -> MovementConfig:
	return load("res://config/movement.tres")


func _reach() -> float:
	var move := _move()
	# Rise of zero: the floor never changes height in this room.
	return Motion.jump_reach(
		move.jump_height, move.time_to_apex, move.fall_gravity_multiplier,
		move.max_run_speed, 0.0
	)


func _bed_width(teeth: int) -> float:
	var hazards: HazardConfig = load(HAZARDS)
	return Spikes.bed_width(teeth, hazards.spike_tooth_pitch)


## What clearing a bed actually costs, which is not the same as clearing a gap
## of the same width. You can take off with half your feet hanging over a gap's
## lip and land the same way, so a gap is cheaper than it looks by about a hero.
## You cannot stand on teeth at all, so a bed is dearer by the same amount, and
## every number below is against this rather than against the drawn width.
func _cost_of(teeth: int) -> float:
	var world: WorldConfig = load("res://config/world.tres")
	return _bed_width(teeth) + world.hero_width


func test_both_beds_can_be_jumped() -> void:
	var reach := _reach()
	for entry in [
		["easy", RoomM3Spikes.EASY_BED_TEETH], ["marginal", RoomM3Spikes.MARGINAL_BED_TEETH]
	]:
		var cost := _cost_of(entry[1])
		check(
			cost < reach,
			"the %s bed costs %.0f px against a reach of %.0f" % [entry[0], cost, reach]
		)


## The second bed earns its name, and the first one does not. The deaths this
## bench exists to produce come from the jump you nearly made, and the easy bed
## is there to teach the reading before anything is riding on it.
func test_the_two_beds_are_not_the_same_jump() -> void:
	var reach := _reach()
	var easy := _cost_of(RoomM3Spikes.EASY_BED_TEETH) / reach
	var marginal := _cost_of(RoomM3Spikes.MARGINAL_BED_TEETH) / reach
	check(
		easy < 0.8,
		"the easy bed is %.0f%% of a full-speed jump, which is comfortable" % [easy * 100.0]
	)
	check(
		marginal > 0.85,
		"the marginal bed is %.0f%% of a full-speed jump" % [marginal * 100.0]
	)


## Marginal is not the same as pixel perfect. The takeoff has to have a window
## of more than a frame or two, or this room reproduces the 1984 complaint
## SPEC.md exists to throw away.
##
## This is the conservative figure: it ignores that the hero's feet are a
## capsule and that the killing box is inset from the teeth. Swept in a running
## build the real window is 5 frames on the marginal bed and at least 7 on the
## easy one, so the assertion is a guard and not the measurement.
func test_the_marginal_bed_is_not_a_pixel_perfect_jump() -> void:
	var move := _move()
	var slack := _reach() - _cost_of(RoomM3Spikes.MARGINAL_BED_TEETH)
	var frames := slack / move.max_run_speed * 60.0
	check(
		frames > 2.0,
		"the marginal bed leaves %.1f frames of takeoff window" % frames
	)


func test_the_beds_do_not_overlap_and_leave_a_run_up() -> void:
	var easy_end := RoomM3Spikes.EASY_BED_X + _bed_width(RoomM3Spikes.EASY_BED_TEETH)
	check(easy_end < RoomM3Spikes.MARGINAL_BED_X, "the beds are separated by floor")
	var marginal_end := (
		RoomM3Spikes.MARGINAL_BED_X + _bed_width(RoomM3Spikes.MARGINAL_BED_TEETH)
	)
	check(marginal_end < RoomM3Spikes.ROOM_WIDTH, "there is floor past the last bed to land on")


func test_the_mid_brazier_banks_the_easy_bed() -> void:
	var easy_end := RoomM3Spikes.EASY_BED_X + _bed_width(RoomM3Spikes.EASY_BED_TEETH)
	check(
		RoomM3Spikes.MID_BRAZIER_X > easy_end,
		"the mid brazier is at %.0f, past the easy bed which ends at %.0f" % [
			RoomM3Spikes.MID_BRAZIER_X, easy_end
		]
	)
	check(
		RoomM3Spikes.MID_BRAZIER_X < RoomM3Spikes.MARGINAL_BED_X,
		"and before the marginal bed, which is the one you die at"
	)


## A checkpoint you cannot make the next jump from is worse than no checkpoint,
## because you only find out after you have already died once.
func test_the_marginal_bed_is_still_jumpable_from_the_mid_brazier() -> void:
	var move := _move()
	var run_up := RoomM3Spikes.MARGINAL_BED_X - RoomM3Spikes.MID_BRAZIER_X
	var needed := Motion.run_up_distance(move.max_run_speed, move.ground_accel)
	check(
		run_up > needed,
		"the respawn has %.0f px of floor before the bed and needs %.0f to reach full speed" % [
			run_up, needed
		]
	)


func test_the_start_brazier_is_at_the_start() -> void:
	check(
		RoomM3Spikes.START_BRAZIER_X < RoomM3Spikes.EASY_BED_X,
		"the start brazier is on the first run of floor"
	)
