## The M2 bench: one room built to show what the sword does to wood.
##
##   throw    J, along the way you are facing
##   destroy  the stone pillar eats it, exactly as in M1
##   embed    the wood wall bites it, and it stops where it hit
##   stand    an embedded sword is a one-tile ledge
##   recall   hold J and every embedded sword comes home
##
## **Nothing here is gated, on purpose.** The jump-versus-ladders question in
## SPEC.md is still open, and a room that *cannot* be finished without standing
## on your own sword has to be sized against a jump height nobody has picked
## yet. M2's two real rooms (BUILD_PLAN.md's done-when) wait for that answer.
## This instrument does not, because it asks nothing of the jump.
##
## Measured against both presets, with the wall top 176 px above the floor:
##
## | from | strong (112 px) | ladders (56 px) |
## |---|---|---|
## | the floor | short | short |
## | the tallest step, 112 px | **over** | short |
## | a sword thrown from that step | over | **over** |
##
## So the strong preset can cross without a sword and the ladder preset cannot.
## That asymmetry is the reason the real rooms are waiting rather than a flaw in
## this one: pick the jump and the gap becomes a number instead of a guess.
class_name RoomM2
extends Bench

const ROOM_WIDTH: float = 1100.0

## Stone, and inside max_range of the steps, so a throw at it is a spent sword.
## It is here as the contrast: the same throw at the same distance, one surface
## keeps the sword and the other does not.
const STONE_PILLAR := Rect2(380.0, 150.0, 20.0, FLOOR_TOP - 150.0)

## Wood. It stops short of the ceiling so the room is crossable, and it runs to
## the floor so any height you can throw from is a height you can put a ledge at.
const WOOD_WALL_TOP: float = 144.0
const WOOD_WALL := Rect2(760.0, WOOD_WALL_TOP, 28.0, FLOOR_TOP - WOOD_WALL_TOP)

## Somewhere to throw from that is not floor height, because a ledge at floor
## height teaches nothing. Heights are tile multiples, not round numbers.
const STEPS: Array[Vector3] = [
	Vector3(180.0, 90.0, 32.0),
	Vector3(520.0, 90.0, 64.0),
	Vector3(640.0, 70.0, 112.0),
]

## A landing on the far side, level with the top of the wall, so that getting
## over it ends somewhere rather than in a fall.
const PERCH := Rect2(800.0, WOOD_WALL_TOP, 140.0, SLAB)


func _ready() -> void:
	_add_solid(Rect2(0.0, FLOOR_TOP, ROOM_WIDTH, ROOM_HEIGHT - FLOOR_TOP))
	_add_solid(STONE_PILLAR)
	for step in STEPS:
		_add_solid(Rect2(step.x, FLOOR_TOP - step.z, step.y, step.z))
	_add_solid(PERCH)
	_add_wood(WOOD_WALL)
	_add_enclosure(ROOM_WIDTH)
	_frame_camera(ROOM_WIDTH)
	queue_redraw()


func _draw() -> void:
	_draw_bench(ROOM_WIDTH)
	# The far side of the wall, which you can only get to over the top of it.
	draw_rect(Rect2(ROOM_WIDTH - 60.0, FLOOR_TOP - 48.0, 8.0, 48.0), Palette.GOLD_FACE)
