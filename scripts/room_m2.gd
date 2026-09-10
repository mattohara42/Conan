## The M2 bench: one room built to show what the sword does to wood.
##
##   throw    J, along the way you are facing
##   destroy  the stone block eats it, exactly as in M1
##   embed    wood bites it, and it stops at the height you threw from
##   stand    an embedded sword is a one-tile ledge
##   recall   hold J and every embedded sword comes home
##
## **Nothing here is gated, on purpose.** The jump-versus-ladders question in
## SPEC.md is still open, and a room that *cannot* be finished without standing
## on your own sword has to be sized against a jump height nobody has picked
## yet. M2's two real rooms (BUILD_PLAN.md's done-when) wait for that answer.
## This instrument does not, because it asks nothing of the jump: every rise in
## it is 48 px or less, which both presets clear, and there is nowhere to get
## stuck. It is a place to press J at wood, not a route.
##
## Every distance below is measured against `config/sword.tres`: `max_range` is
## 200, so a throw only reaches wood you are standing within 200 px of, and the
## two wood faces are placed to be inside that from the spawn and from the step.
class_name RoomM2
extends Bench

const ROOM_WIDTH: float = 760.0

## Wood, to the left of where you start, close enough that the first thing you
## can do in this room is embed a sword at the height you are standing.
const LOW_WOOD := Rect2(60.0, 160.0, 28.0, FLOOR_TOP - 160.0)

## Stone, the same throw at a similar distance with the other outcome. This is
## the contrast the bench exists to show, so it is deliberately the nearest
## thing to the right of the spawn.
const STONE_BLOCK := Rect2(340.0, FLOOR_TOP - 48.0, 24.0, 48.0)

## Somewhere to throw from that is not floor height, because a ledge at floor
## height teaches nothing. A 32 px rise, which is under both presets' jumps.
const STEP := Rect2(450.0, FLOOR_TOP - 32.0, 100.0, 32.0)

## Wood again, in range of the step rather than of the floor, so the second
## thing you can do is put a ledge up where you could not otherwise stand.
const HIGH_WOOD := Rect2(640.0, 200.0, 28.0, FLOOR_TOP - 200.0)


func _ready() -> void:
	_add_solid(Rect2(0.0, FLOOR_TOP, ROOM_WIDTH, ROOM_HEIGHT - FLOOR_TOP))
	_add_solid(STONE_BLOCK)
	_add_solid(STEP)
	_add_wood(LOW_WOOD)
	_add_wood(HIGH_WOOD)
	_add_enclosure(ROOM_WIDTH)
	_frame_camera(ROOM_WIDTH)
	queue_redraw()


func _draw() -> void:
	_draw_bench(ROOM_WIDTH)
