## The M3 spike bench: a floor that is never broken and twice lethal.
##
## Spikes and lava kill identically, and SPEC.md wants both, so the only thing
## this bench can honestly show is the placement. Lava needs a hole in the
## floor. A bed of spikes bolts onto a surface and the floor line runs straight
## through it, so the hazard is something you read rather than something you can
## see a gap in. That is the difference, and both beds here are that difference.
##
## The placements that would be worth more, teeth on top of the ledge you have
## to land on, are in `BACKLOG.md` with the arithmetic that says the 56 px jump
## cannot make them without a pixel-perfect takeoff. They need the moving
## platforms from later in M3, not a wider bed.
##
## Short, with both beds clearable, for the same reason the lava bench is: being
## stuck is a different complaint from being punished and only the second one is
## what M3 measures.
class_name RoomM3Spikes
extends Bench

const ROOM_WIDTH: float = 860.0

## The first bed. Six teeth, comfortably inside a running jump, and it is here
## to teach what a row of points means before anything is riding on it.
const EASY_BED_X: float = 280.0
const EASY_BED_TEETH: int = 6

## The second. Eight teeth, and `test_room_m3_spikes.gd` holds it to being the
## jump you nearly make: a bed costs more than a gap of the same width, because
## you can take off with half your feet over a gap's lip and you cannot take off
## from the teeth at all.
const MARGINAL_BED_X: float = 620.0
const MARGINAL_BED_TEETH: int = 8

## The braziers. The first is where the room starts you, so there is a
## checkpoint in the first frame. The second is past the easy bed and before the
## marginal one, so a death at the bed you die at costs you that jump and not
## the one you already made. Same rule as the lava bench, same reason.
const START_BRAZIER_X: float = 60.0
const MID_BRAZIER_X: float = 420.0


func _ready() -> void:
	# One run of floor, start to finish. There is no gap anywhere in this room
	# and that is the point of it.
	_add_solid(Rect2(0.0, FLOOR_TOP, ROOM_WIDTH, ROOM_HEIGHT - FLOOR_TOP))
	_add_spikes(FLOOR_TOP, EASY_BED_X, EASY_BED_TEETH)
	_add_spikes(FLOOR_TOP, MARGINAL_BED_X, MARGINAL_BED_TEETH)
	_add_brazier(Vector2(START_BRAZIER_X, FLOOR_TOP))
	_add_brazier(Vector2(MID_BRAZIER_X, FLOOR_TOP))
	_add_enclosure(ROOM_WIDTH)
	_frame_camera(ROOM_WIDTH)
	queue_redraw()


func _draw() -> void:
	_draw_bench(ROOM_WIDTH)
	# The far end. Gold means interactive, and reaching it without landing on
	# anything is the thing you are trying to do twenty times.
	draw_rect(Rect2(ROOM_WIDTH - 60.0, FLOOR_TOP - 48.0, 8.0, 48.0), Palette.GOLD_FACE)
