## Shared plumbing for the Phase 1 grey benches.
##
## **These are instruments, not rooms.** Their geometry is generated from
## `WorldConfig` so that distances stay multiples of tier height and tile size
## when those numbers change. The real rooms in Phase 3 are authored scenes
## built on a tileset (`BUILD_PLAN.md` → M10), and they do not extend this.
class_name Bench
extends Node2D

@export var world: WorldConfig

const ROOM_HEIGHT: float = 360.0
const FLOOR_TOP: float = 320.0
const SLAB: float = 24.0
const LADDER_WIDTH: float = 16.0
## A ladder overshoots the ledge it serves, so you climb above the surface and
## step onto it rather than stopping level with it and falling off.
const LADDER_OVERSHOOT: float = 28.0

var _solids: Array[Rect2] = []
var _ladders: Array[Rect2] = []


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


## Walls and a ceiling, so nothing leaves the instrument.
func _add_enclosure(width: float) -> void:
	_add_solid(Rect2(-SLAB, 0.0, SLAB, ROOM_HEIGHT))
	_add_solid(Rect2(width, 0.0, SLAB, ROOM_HEIGHT))
	_add_solid(Rect2(-SLAB, -SLAB, width + SLAB * 2.0, SLAB))


## The room owns the camera bounds, not the player. A player scene carrying one
## room's width cannot be dropped into a room of another size, which is exactly
## what happened when the M1 bench inherited the M0 bench's 1600.
func _frame_camera(width: float) -> void:
	for node in get_tree().get_nodes_in_group("player"):
		for child in node.get_children():
			var camera := child as Camera2D
			if camera == null:
				continue
			camera.limit_left = 0
			camera.limit_top = 0
			camera.limit_right = int(width)
			camera.limit_bottom = int(ROOM_HEIGHT)


func _draw_bench(width: float) -> void:
	draw_rect(Rect2(0.0, 0.0, width, ROOM_HEIGHT), Palette.BACKDROP)
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
			draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), Palette.GOLD_FACE, 2.0)
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
