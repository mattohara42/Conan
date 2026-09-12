## The M3 falling-platform bench: two lava moats, neither of them jumpable, and
## the only way across is a line of slabs that will not wait for you.
##
## This is the first hazard in M3 that is not about where you put your feet. The
## lava bench asks whether you can read a gap and the spike bench asks whether
## you can read a surface. Both are questions about space, and you can answer
## either one standing still. A falling platform asks a question about time, and
## the only wrong answer to it is hesitating.
##
## SPEC.md's Act 2 is built out of this: "a throw you have to catch before the
## platform you are standing on drops". The throw is not here yet, and it does
## not need to be. What has to be true first is that standing still on a slab is
## a decision with a cost, and that is what this room measures.
##
## Short, with both moats crossable, for the same reason the other two benches
## are: being stuck is a different complaint from being punished and only the
## second one is what M3 measures.
class_name RoomM3Falling
extends Bench

const ROOM_WIDTH: float = 1060.0

## One slab. A tidy three tiles across, which is wide enough to land on without
## precision and narrow enough that you cannot stop and think on it.
const SLAB_SIZE := Vector2(48.0, 12.0)
## Clear floor between one slab and the next, and between a slab and the bank.
## Every hop in the room is this far, so the room asks its question once and
## then asks it again faster, rather than asking a different question each time.
const HOP: float = 40.0

## The banks. The first moat is two slabs wide and the second is three, which is
## the only difficulty curve in the room: the same jump, one more time, before
## you are allowed to stand on something that stays.
const FIRST_BANK_END: float = 280.0
const ISLAND_START: float = 496.0
const ISLAND_END: float = 640.0
const LAST_BANK_START: float = 944.0

## How far below the floor surface the lava sits. Deeper than the lava bench's
## inset, because a slab hangs below the surface it presents and lava drawn up
## against the underside of one reads as a slab already sinking.
const LAVA_INSET: float = 20.0

## The braziers. The first is where the room starts you, so there is a
## checkpoint in the first frame. The second is on the island between the moats,
## so a death in the second moat costs you that crossing and not the one you
## already made. Same rule as the other two benches, same reason.
const START_BRAZIER_X: float = 60.0
const MID_BRAZIER_X: float = 560.0


## The slabs of the first moat, left to right, as the rectangles they occupy.
static func first_crossing() -> Array[Rect2]:
	return _crossing(FIRST_BANK_END, 2)


## And the second. Three slabs, and no more floor until the far bank.
static func second_crossing() -> Array[Rect2]:
	return _crossing(ISLAND_END, 3)


## A line of `count` slabs marching away from the bank at `bank_end`, one hop
## apart, with a hop of clear air left at the far end to land the last jump.
static func _crossing(bank_end: float, count: int) -> Array[Rect2]:
	var slabs: Array[Rect2] = []
	for i in count:
		var x := bank_end + HOP + (HOP + SLAB_SIZE.x) * float(i)
		slabs.append(Rect2(Vector2(x, FLOOR_TOP), SLAB_SIZE))
	return slabs


## Where a crossing ends: the near edge of the bank you are aiming at.
static func far_bank_of(slabs: Array[Rect2]) -> float:
	return slabs[slabs.size() - 1].end.x + HOP


func _ready() -> void:
	var banks: Array[Vector2] = [
		Vector2(0.0, FIRST_BANK_END),
		Vector2(ISLAND_START, ISLAND_END),
		Vector2(LAST_BANK_START, ROOM_WIDTH),
	]
	for bank in banks:
		_add_solid(Rect2(bank.x, FLOOR_TOP, bank.y - bank.x, ROOM_HEIGHT - FLOOR_TOP))
	_add_lava(_moat(FIRST_BANK_END, ISLAND_START))
	_add_lava(_moat(ISLAND_END, LAST_BANK_START))
	for slab in first_crossing() + second_crossing():
		_add_falling_platform(slab)
	_add_brazier(Vector2(START_BRAZIER_X, FLOOR_TOP))
	_add_brazier(Vector2(MID_BRAZIER_X, FLOOR_TOP))
	_add_enclosure(ROOM_WIDTH)
	_frame_camera(ROOM_WIDTH)
	queue_redraw()


## A moat's x range as the lava rectangle that fills it.
func _moat(from: float, to: float) -> Rect2:
	return Rect2(
		from, FLOOR_TOP + LAVA_INSET, to - from, ROOM_HEIGHT - FLOOR_TOP - LAVA_INSET
	)


func _draw() -> void:
	_draw_bench(ROOM_WIDTH)
	# The far end. Gold means interactive, and reaching it without stopping is
	# the thing you are trying to do twenty times.
	draw_rect(Rect2(ROOM_WIDTH - 60.0, FLOOR_TOP - 48.0, 8.0, 48.0), Palette.GOLD_FACE)
