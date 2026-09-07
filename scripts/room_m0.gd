## The M0 test bench: one room, wider than the screen, built to answer three
## questions by playing it.
##
##   1. Does the jump feel good enough that you stop noticing it?
##   2. Is 40 px the right hero height? ([ and ] to compare.)
##   3. Strong steerable jump, or a weak jump and ladders? (Tab to swap.)
##
## The geometry is generated from `WorldConfig` rather than authored, because
## every distance in here is a multiple of tier height or tile size and hand
## placement would let those drift the moment the config changes. Rooms in
## Phase 3 are authored scenes; this one is an instrument.
class_name RoomM0
extends Node2D

@export var world: WorldConfig

const ROOM_WIDTH: float = 1600.0
const ROOM_HEIGHT: float = 360.0
const FLOOR_TOP: float = 320.0
const SLAB: float = 24.0
const LADDER_WIDTH: float = 16.0
## A ladder overshoots the ledge it serves, so you climb above the surface and
## step onto it rather than stopping level with it and falling off.
const LADDER_OVERSHOOT: float = 28.0

## The ground floor, in runs, so the gaps between them are the interesting part.
## A full-speed jump covers about 130 px on the strong preset and about 90 on the
## ladder preset, which makes these three gaps easy, marginal and impossible.
const GROUND_RUNS: Array[Vector2] = [
	Vector2(0.0, 360.0),
	Vector2(440.0, 680.0),
	Vector2(810.0, 1030.0),
	Vector2(1200.0, ROOM_WIDTH),
]

## Tier one ledges. The 80 px gaps between them are crossable on either preset,
## because the question is whether you can climb a storey, not whether you can
## cross a room.
const TIER_ONE_LEDGES: Array[Vector2] = [
	Vector2(300.0, 420.0),
	Vector2(500.0, 720.0),
	Vector2(800.0, 1020.0),
]

## Tier two. It sits directly over the right end of the last tier one ledge, so
## the strong preset can jump to it and the ladder preset can climb to it.
const TIER_TWO_LEDGE := Vector2(1020.0, 1400.0)

## Isolated blocks for feeling short hops, at the far end where nothing above is
## in reach of them. They must not become a staircase to a tier or the ladder
## preset stops being a fair test.
const HOP_BLOCKS: Array[Vector3] = [
	Vector3(1230.0, 40.0, 24.0),
	Vector3(1300.0, 40.0, 48.0),
	Vector3(1450.0, 40.0, 72.0),
]

var _solids: Array[Rect2] = []
var _ladders: Array[Rect2] = []


func _ready() -> void:
	_build()


func _build() -> void:
	var tier_1 := FLOOR_TOP - world.tier_height
	var tier_2 := FLOOR_TOP - world.tier_height * 2.0

	for run in GROUND_RUNS:
		_add_solid(Rect2(run.x, FLOOR_TOP, run.y - run.x, ROOM_HEIGHT - FLOOR_TOP))

	for block in HOP_BLOCKS:
		_add_solid(Rect2(block.x, FLOOR_TOP - block.z, block.y, block.z))

	for ledge in TIER_ONE_LEDGES:
		_add_solid(Rect2(ledge.x, tier_1, ledge.y - ledge.x, SLAB))

	_add_solid(Rect2(TIER_TWO_LEDGE.x, tier_2, TIER_TWO_LEDGE.y - TIER_TWO_LEDGE.x, SLAB))

	# Walls and ceiling, so nothing leaves the instrument.
	_add_solid(Rect2(-SLAB, 0.0, SLAB, ROOM_HEIGHT))
	_add_solid(Rect2(ROOM_WIDTH, 0.0, SLAB, ROOM_HEIGHT))
	_add_solid(Rect2(-SLAB, -SLAB, ROOM_WIDTH + SLAB * 2.0, SLAB))

	# Three ladders, each flush against the ledge it serves. On the ladder preset
	# these are the only way between storeys, and the room is completable using
	# nothing else.
	_add_ladder(300.0 - LADDER_WIDTH, tier_1, FLOOR_TOP)
	_add_ladder(TIER_TWO_LEDGE.x - LADDER_WIDTH, tier_2, tier_1)
	_add_ladder(TIER_TWO_LEDGE.y + 2.0, tier_2, FLOOR_TOP)

	queue_redraw()


func _add_solid(rect: Rect2) -> void:
	_solids.append(rect)
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.position = rect.get_center()
	body.add_child(shape)
	add_child(body)


## `top` is the surface the ladder serves; it is drawn reaching above that.
func _add_ladder(x: float, top: float, bottom: float) -> void:
	var rect := Rect2(x, top - LADDER_OVERSHOOT, LADDER_WIDTH, bottom - top + LADDER_OVERSHOOT)
	_ladders.append(rect)
	var area := Area2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	area.position = rect.get_center()
	# Layer 2 is ladders and nothing else, so the player's probe can watch for
	# them without hearing about the world geometry.
	area.collision_layer = 2
	area.collision_mask = 0
	area.add_to_group("ladders")
	area.add_child(shape)
	add_child(area)


func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, ROOM_WIDTH, ROOM_HEIGHT), Palette.BACKDROP)
	for rect in _solids:
		draw_rect(rect, Palette.STONE_MID)
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 3.0)), Palette.STONE_LIT)
	for rect in _ladders:
		# Cold and matte, with gold rungs. ART_DIRECTION.md reserves warm and
		# saturated for things that kill you, and a ladder is the opposite of
		# that, so a warm ladder teaches the player to read the room backwards.
		draw_rect(rect, Palette.STONE_DEEP)
		var rungs := int(rect.size.y / 12.0)
		for i in rungs:
			var y := rect.position.y + 12.0 * float(i) + 6.0
			draw_line(
				Vector2(rect.position.x, y),
				Vector2(rect.end.x, y),
				Palette.GOLD_FACE,
				2.0
			)
	# The far end. Gold means interactive, and crossing to it is the done-when.
	draw_rect(Rect2(ROOM_WIDTH - 60.0, FLOOR_TOP - 48.0, 8.0, 48.0), Palette.GOLD_FACE)
	_draw_ruler()


## A height scale against the left wall, because "did that clear a tier" should
## be answered by looking rather than by arithmetic.
func _draw_ruler() -> void:
	var font := ThemeDB.fallback_font
	var y := FLOOR_TOP
	while y > 0.0:
		var height_above_floor := FLOOR_TOP - y
		var is_tier := is_zero_approx(fmod(height_above_floor, world.tier_height))
		var length := 26.0 if is_tier else 10.0
		var colour: Color = Palette.STONE_LIT if is_tier else Palette.STONE_MID
		draw_line(Vector2(0.0, y), Vector2(length, y), colour, 1.0)
		if is_tier and height_above_floor > 0.0:
			draw_string(
				font, Vector2(length + 4.0, y + 4.0), "%d" % int(height_above_floor),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Palette.STONE_LIT
			)
		y -= world.tile_size
