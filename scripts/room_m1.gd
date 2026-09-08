## The M1 bench: one room built to show the sword's four base states and nothing
## else.
##
##   throw    J, along the way you are facing
##   fly      it goes out 200 px and turns
##   return   it comes back along the height you threw at, steering toward the x
##            you are at now
##   catch    stand in its path and it is back in your hand
##   consume  it hits the pillar and it is gone
##   miss     jump while it is coming back and it passes under you, sails on,
##            and lands on the floor for you to walk to
##
## Distances are picked against config/sword.tres: the pillar is inside max
## range from the spawn and the left run is longer than it, so throwing right
## destroys and throwing left returns.
class_name RoomM1
extends Bench

const ROOM_WIDTH: float = 1200.0
const SPAWN_X: float = 300.0
## Inside max_range of the spawn, so a throw to the right is a consumed sword.
const PILLAR := Rect2(460.0, 180.0, 20.0, FLOOR_TOP - 180.0)
## Somewhere to stand that is not floor height, which is the only way to miss.
const HIGH_LEDGE := Vector2(700.0, 850.0)
const LOW_STEP := Vector2(950.0, 1020.0)
const LOW_STEP_RISE: float = 48.0


func _ready() -> void:
	_add_solid(Rect2(0.0, FLOOR_TOP, ROOM_WIDTH, ROOM_HEIGHT - FLOOR_TOP))
	_add_solid(PILLAR)
	_add_solid(Rect2(
		HIGH_LEDGE.x, FLOOR_TOP - world.tier_height, HIGH_LEDGE.y - HIGH_LEDGE.x, SLAB
	))
	_add_solid(Rect2(
		LOW_STEP.x, FLOOR_TOP - LOW_STEP_RISE, LOW_STEP.y - LOW_STEP.x, LOW_STEP_RISE
	))
	_add_enclosure(ROOM_WIDTH)
	_frame_camera(ROOM_WIDTH)
	queue_redraw()


func _draw() -> void:
	_draw_bench(ROOM_WIDTH)
