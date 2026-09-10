## M2's first room, as arithmetic.
##
## The room's whole claim is that it **cannot be finished without standing on
## your own thrown sword**, and that claim is a function of numbers in
## `config/`: the jump, the run speed, the fall gravity, the blade length. None
## of those are the room's to own, so any of them can move and quietly turn the
## puzzle into a walk, or into something impossible.
##
## These are the assertions that say which. If M14 retunes the jump and this
## file goes red, the room needs rebuilding and the number is not wrong.
extends TestCase


func _reach(rise: float) -> float:
	var move: MovementConfig = load("res://config/movement.tres")
	return Motion.jump_reach(
		move.jump_height, move.time_to_apex, move.fall_gravity_multiplier,
		move.max_run_speed, rise
	)


## Where the player's centre sits when standing at the very lip of the near
## side, and where a sword thrown from there ends up.
func _near_lip() -> float:
	var world: WorldConfig = load("res://config/world.tres")
	return RoomM2Gap.NEAR_EDGE - world.hero_width * 0.5


func _ledge_centre() -> float:
	var world: WorldConfig = load("res://config/world.tres")
	# SwordFlight.embed_position, for a rightward throw into the post's face.
	return SwordFlight.embed_position(RoomM2Gap.POST.position.x, 1.0, world.sword_length)


func test_the_gap_cannot_be_jumped() -> void:
	var rise := Bench.FLOOR_TOP - RoomM2Gap.FAR_TOP
	var needed := RoomM2Gap.FAR_EDGE - RoomM2Gap.NEAR_EDGE
	check(
		needed > _reach(rise),
		"the bare gap is %.0f px and a jump rising %.0f px covers %.0f" % [
			needed, rise, _reach(rise)
		]
	)


func test_the_sword_makes_it_crossable() -> void:
	var world: WorldConfig = load("res://config/world.tres")
	var ledge := _ledge_centre()
	# The ledge top, which is what the player's feet land on.
	var ledge_top := (Bench.FLOOR_TOP - world.hero_height * 0.5) - Sword.LEDGE_THICKNESS * 0.5

	var first := ledge - _near_lip()
	var first_rise := Bench.FLOOR_TOP - ledge_top
	check(
		first <= _reach(first_rise),
		"floor to the ledge is %.0f px, rising %.0f, budget %.0f" % [
			first, first_rise, _reach(first_rise)
		]
	)

	var second := (RoomM2Gap.FAR_EDGE + world.hero_width * 0.5) - ledge
	var second_rise := ledge_top - RoomM2Gap.FAR_TOP
	check(
		second <= _reach(second_rise),
		"the ledge to the far side is %.0f px, rising %.0f, budget %.0f" % [
			second, second_rise, _reach(second_rise)
		]
	)


## Three ways to cheat the room, all of which have to stay shut.
func test_the_puzzle_cannot_be_skipped() -> void:
	var move: MovementConfig = load("res://config/movement.tres")

	check(
		Bench.FLOOR_TOP - RoomM2Gap.POST.position.y > move.jump_height,
		"the post's top is %.0f px up, out of reach of a %.0f px jump" % [
			Bench.FLOOR_TOP - RoomM2Gap.POST.position.y, move.jump_height
		]
	)
	check(
		RoomM2Gap.PIT_TOP - RoomM2Gap.FAR_TOP > move.jump_height,
		"the far side is %.0f px above the pit floor, so falling in is not a route" % [
			RoomM2Gap.PIT_TOP - RoomM2Gap.FAR_TOP
		]
	)
	check(
		RoomM2Gap.PIT_TOP - Bench.FLOOR_TOP < move.jump_height,
		"the near side is %.0f px above the pit floor, so falling in is a retry" % [
			RoomM2Gap.PIT_TOP - Bench.FLOOR_TOP
		]
	)


## The throw has to reach the post at all, or none of the above matters.
func test_the_post_is_inside_throwing_range() -> void:
	var sword: SwordConfig = load("res://config/sword.tres")
	var distance := RoomM2Gap.POST.position.x - _near_lip()
	check(
		distance < sword.max_range,
		"the post is %.0f px away against a %.0f px range" % [distance, sword.max_range]
	)


## The post has to be tall enough to catch a throw made from the floor, or the
## sword sails over or under it.
func test_a_floor_level_throw_meets_the_post() -> void:
	var world: WorldConfig = load("res://config/world.tres")
	var throw_height := Bench.FLOOR_TOP - world.hero_height * 0.5
	check(
		throw_height > RoomM2Gap.POST.position.y and throw_height < RoomM2Gap.POST.end.y,
		"a throw at y %.0f lands inside the post's %.0f to %.0f" % [
			throw_height, RoomM2Gap.POST.position.y, RoomM2Gap.POST.end.y
		]
	)
