## M2's first room: **it cannot be finished without standing on your own thrown
## sword.** That is BUILD_PLAN.md's done-when, stated as geometry.
##
## A gap of 120 px with the far side 32 px higher. A full-speed jump landing
## that high covers 77 px, so the crossing is not close to possible. A wooden
## post stands in the gap, too tall to land on and too high to walk under. Throw
## a sword into it and the post grows a one-tile ledge halfway across.
##
## Every number here is measured against `config/movement.tres` (56 px jump,
## 0.2546 s to apex, 1.6x fall gravity, 200 px/s run) and `config/sword.tres`
## (200 px range, 16 px blade). The margins, in px of spare horizontal reach:
##
## | jump | needs | budget | spare |
## |---|---|---|---|
## | floor to the sword ledge, rising 22 | 66 | 82 | 16 |
## | the ledge to the far side, rising 10 | 68 | 87 | 19 |
## | the bare gap, rising 32 | 120 | 77 | impossible |
##
## Three ways the puzzle could have been skipped, all closed:
## the post's top is 120 px above the floor against a 56 px jump; the pit floor
## is 68 px below the far side, so falling in and climbing out the far end does
## not work; and the pit floor is only 36 px below the near side, so falling in
## is a retry rather than a soft lock.
class_name RoomM2Gap
extends Bench

const ROOM_WIDTH: float = 820.0

## Where the near side stops. The player's centre can reach 391, being 9 px of
## half-width short of it, and that is where the throw is measured from.
const NEAR_EDGE: float = 400.0
## The far side, higher than the near one so that the gap cannot be flown.
const FAR_EDGE: float = 520.0
const FAR_TOP: float = FLOOR_TOP - 32.0

## Wood, standing in the gap. Its left face is what the sword bites, and it runs
## from above jump height down through the pit floor, so there is no way past it
## except the ledge you make.
const POST := Rect2(465.0, 200.0, 10.0, ROOM_HEIGHT - 200.0)

## The bottom of the gap. Shallow on the near side and deep on the far side,
## which is what makes falling in a retry and not a shortcut.
const PIT_TOP: float = 356.0


func _ready() -> void:
	_add_solid(Rect2(0.0, FLOOR_TOP, NEAR_EDGE, ROOM_HEIGHT - FLOOR_TOP))
	_add_solid(Rect2(FAR_EDGE, FAR_TOP, ROOM_WIDTH - FAR_EDGE, ROOM_HEIGHT - FAR_TOP))
	_add_solid(Rect2(NEAR_EDGE, PIT_TOP, FAR_EDGE - NEAR_EDGE, ROOM_HEIGHT - PIT_TOP))
	_add_wood(POST)
	# The way back out of the pit, and the first ladder in a room built after the
	# jump question was settled. A 36 px step would also do it; this is what
	# SPEC.md now says vertical movement is.
	_add_ladder(NEAR_EDGE + 4.0, FLOOR_TOP, PIT_TOP)
	_add_enclosure(ROOM_WIDTH)
	_frame_camera(ROOM_WIDTH)
	queue_redraw()


func _draw() -> void:
	_draw_bench(ROOM_WIDTH)
	# The far side, which is the done-when. Gold means interactive.
	draw_rect(Rect2(ROOM_WIDTH - 70.0, FAR_TOP - 48.0, 8.0, 48.0), Palette.GOLD_FACE)
