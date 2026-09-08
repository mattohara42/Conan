## The M0 bench: one room, wider than the screen, built to answer three
## questions by playing it.
##
##   1. Does the jump feel good enough that you stop noticing it?
##   2. Is 40 px the right hero height? ([ and ] to compare.)
##   3. Strong steerable jump, or a weak jump and ladders? (Tab to swap.)
class_name RoomM0
extends Bench

const ROOM_WIDTH: float = 1600.0

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


func _ready() -> void:
	var tier_1 := FLOOR_TOP - world.tier_height
	var tier_2 := FLOOR_TOP - world.tier_height * 2.0

	for run in GROUND_RUNS:
		_add_solid(Rect2(run.x, FLOOR_TOP, run.y - run.x, ROOM_HEIGHT - FLOOR_TOP))
	for block in HOP_BLOCKS:
		_add_solid(Rect2(block.x, FLOOR_TOP - block.z, block.y, block.z))
	for ledge in TIER_ONE_LEDGES:
		_add_solid(Rect2(ledge.x, tier_1, ledge.y - ledge.x, SLAB))
	_add_solid(Rect2(TIER_TWO_LEDGE.x, tier_2, TIER_TWO_LEDGE.y - TIER_TWO_LEDGE.x, SLAB))
	_add_enclosure(ROOM_WIDTH)
	_frame_camera(ROOM_WIDTH)

	# Three ladders, each flush against the ledge it serves. On the ladder preset
	# these are the only way between storeys, and the room is completable using
	# nothing else.
	_add_ladder(300.0 - LADDER_WIDTH, tier_1, FLOOR_TOP)
	_add_ladder(TIER_TWO_LEDGE.x - LADDER_WIDTH, tier_2, tier_1)
	_add_ladder(TIER_TWO_LEDGE.y + 2.0, tier_2, FLOOR_TOP)
	queue_redraw()


func _draw() -> void:
	_draw_bench(ROOM_WIDTH)
	# The far end. Gold means interactive, and crossing to it is the done-when.
	draw_rect(Rect2(ROOM_WIDTH - 60.0, FLOOR_TOP - 48.0, 8.0, 48.0), Palette.GOLD_FACE)
