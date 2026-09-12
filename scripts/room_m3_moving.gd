## The M3 moving-platform bench: two lava moats, neither of them jumpable, and
## the only way across each is a slab that is already going somewhere.
##
## The three M3 benches ask three different questions. Lava and spikes ask where
## your feet are, and you can answer either one standing still. A falling
## platform asks a question about time and the wrong answer is hesitating. A
## ferry asks the same question from the other end: it is the only hazard here
## whose clock was running before you arrived and keeps running after you die,
## so the wrong answer is walking at a gap as though the room owed you a floor
## when you got there.
##
## **The first moat teaches and the second one asks.** The first ferry docks
## flush against the bank, so boarding is a walk and only getting off is timed.
## The second reaches neither bank, so both ends are a jump onto or off a moving
## target. One new thing at a time, which is the same shape as the spike bench's
## easy bed and marginal bed.
##
## Short, with both moats crossable, for the same reason the other benches are:
## being stuck is a different complaint from being punished and only the second
## one is what M3 measures.
class_name RoomM3Moving
extends Bench

## One ferry. Wider than a falling slab, because you land on this one while it
## is moving and the falling one only ever asks you to land on something that is
## standing still.
const SLAB_SIZE := Vector2(64.0, 12.0)
## How far a ferry travels. The same for both, so the room asks its question
## twice at the same tempo rather than asking two different ones.
const SPAN: float = 96.0
## Clear air between a bank and the ferry at the near end of its trip. Every
## jump in this room is this far, and it is deliberately an easy one: the
## question is when to take off and not how far you can reach.
const GAP: float = 48.0

## The banks. Every x here is derived from the three numbers above, so a moat
## cannot quietly stop matching the ferry that has to cross it.
##
## The first bank is short, and that is the death loop talking rather than the
## crossing: a respawn at the start brazier has to reach the flush dock while the
## first ferry is still sitting in it.
const FIRST_BANK_END: float = 180.0
const ISLAND_START: float = FIRST_BANK_END + SLAB_SIZE.x + SPAN + GAP
const ISLAND_WIDTH: float = 160.0
const ISLAND_END: float = ISLAND_START + ISLAND_WIDTH
const LAST_BANK_START: float = ISLAND_END + GAP + SLAB_SIZE.x + SPAN + GAP
const LAST_BANK_WIDTH: float = 116.0
const ROOM_WIDTH: float = LAST_BANK_START + LAST_BANK_WIDTH

## How far below the floor surface the lava sits. Same reason as the falling
## bench: lava drawn up against the underside of a slab reads as a slab sinking.
const LAVA_INSET: float = 20.0

## The braziers. The first is where the room starts you, so there is a
## checkpoint in the first frame.
const START_BRAZIER_X: float = 60.0
## Floor between the mid brazier and the lip of the second moat.
##
## The one number in the room that is about the death loop rather than about the
## crossing. A respawn puts every ferry back at its near dock and starts its wait
## again, so this is how much running has to happen inside that wait: long enough
## to reach a full run, short enough to be at the lip while the ferry is still
## there. Get it wrong and every death costs a crossing plus a wait, which is
## exactly what turns twenty deaths tedious.
const BOARDING_RUN: float = 48.0
const MID_BRAZIER_X: float = ISLAND_END - BOARDING_RUN


## The ferry over the first moat, where it sits at the near end of its trip. It
## docks flush against the bank, so you walk on rather than jumping on.
static func first_ferry() -> Rect2:
	return Rect2(Vector2(FIRST_BANK_END, FLOOR_TOP), SLAB_SIZE)


## And the second, which docks a jump out from the island and turns round a jump
## short of the far bank.
static func second_ferry() -> Rect2:
	return Rect2(Vector2(ISLAND_END + GAP, FLOOR_TOP), SLAB_SIZE)


## The trip both of them make, as an offset from where they dock.
static func travel() -> Vector2:
	return Vector2(SPAN, 0.0)


## How far a ferry's far dock leaves it from the bank it is aiming at. The jump
## off, which is the half of a crossing the first moat teaches on its own.
static func gap_to_bank(ferry: Rect2, bank: float) -> float:
	return bank - (ferry.end.x + SPAN)


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
	_add_moving_platform(first_ferry(), travel())
	_add_moving_platform(second_ferry(), travel())
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
	# The far end. Gold means interactive, and reaching it is the thing you are
	# trying to do twenty times.
	draw_rect(Rect2(ROOM_WIDTH - 60.0, FLOOR_TOP - 48.0, 8.0, 48.0), Palette.GOLD_FACE)
