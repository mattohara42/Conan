## The M3 bench: a floor with lava in it, built to be died in repeatedly.
##
## BUILD_PLAN.md M3's done-when has two halves and this room serves both. The
## measured half (death to moving again, under a second) is read off the overlay.
## The felt half (dying twenty times in a row is annoying but not tedious) needs
## you to actually do that, so the room is short, the run back is short, and both
## gaps are crossable: being stuck is a different complaint from being punished.
class_name RoomM3
extends Bench

const ROOM_WIDTH: float = 1000.0

## The two gaps, as x ranges, with lava at the bottom of each. Named constants
## rather than numbers inside `_ready`, because `test_room_m3.gd` asserts both
## against `Motion.jump_reach` and a test cannot reach a local.
##
## The first is comfortable and teaches what lava does. The second is about 93%
## of a full-speed jump, which is the width that kills you on the attempts where
## you did not quite commit.
const EASY_GAP := Vector2(340.0, 400.0)
const MARGINAL_GAP := Vector2(700.0, 785.0)

## How far below the floor surface the lava sits, so a pit reads as a pit and
## not as a coloured floor tile.
const LAVA_INSET: float = 10.0

## The two braziers, as x positions on the floor.
##
## The first sits where the room starts you, so the checkpoint is a brazier from
## the first frame rather than being wherever the scene happened to drop you.
## The second is the one the milestone is about: it sits just past the easy gap,
## so a death at the marginal gap costs you the jump you missed and not the jump
## you already made. Dying twenty times at the same gap is the test, and redoing
## an easy jump nineteen times is how that turns from annoying into tedious.
const START_BRAZIER_X: float = 60.0
const MID_BRAZIER_X: float = 470.0


func _ready() -> void:
	var runs: Array[Vector2] = [
		Vector2(0.0, EASY_GAP.x),
		Vector2(EASY_GAP.y, MARGINAL_GAP.x),
		Vector2(MARGINAL_GAP.y, ROOM_WIDTH),
	]
	for run in runs:
		_add_solid(Rect2(run.x, FLOOR_TOP, run.y - run.x, ROOM_HEIGHT - FLOOR_TOP))
	_add_lava(_pit(EASY_GAP))
	_add_lava(_pit(MARGINAL_GAP))
	_add_brazier(Vector2(START_BRAZIER_X, FLOOR_TOP))
	_add_brazier(Vector2(MID_BRAZIER_X, FLOOR_TOP))
	_add_enclosure(ROOM_WIDTH)
	_frame_camera(ROOM_WIDTH)
	queue_redraw()


## A gap's x range as the lava rectangle that fills it.
func _pit(gap: Vector2) -> Rect2:
	return Rect2(
		gap.x, FLOOR_TOP + LAVA_INSET,
		gap.y - gap.x, ROOM_HEIGHT - FLOOR_TOP - LAVA_INSET
	)


func _draw() -> void:
	_draw_bench(ROOM_WIDTH)
	# The far end. Gold means interactive, and reaching it without dying is the
	# thing you are trying to do twenty times.
	draw_rect(Rect2(ROOM_WIDTH - 60.0, FLOOR_TOP - 48.0, 8.0, 48.0), Palette.GOLD_FACE)
