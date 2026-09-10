## A gate a switch opens.
##
## Solid while shut and not there at all while open. It owns no logic about
## *why* it is open: a room wires a switch to it, which is what keeps a room's
## puzzle inside that room (CLAUDE.md: a room never reaches into another room).
class_name Gate
extends StaticBody2D

var is_open := false

@onready var _shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("gates")


func set_open(open: bool) -> void:
	if open == is_open:
		return
	is_open = open
	# Deferred because a switch reports during physics, and a body cannot change
	# its own collision mid-step.
	_shape.set_deferred("disabled", is_open)
	queue_redraw()


## Drawn as the bars it is, so an open gate reads as an opening rather than as
## something that vanished.
func _draw() -> void:
	var shape := _shape.shape as RectangleShape2D
	var rect := Rect2(-shape.size * 0.5, shape.size)
	if is_open:
		# The frame stays. Only the bars go.
		draw_rect(rect, Color(Palette.STONE_DEEP, 0.35))
		draw_rect(rect, Color(Palette.STONE_MID, 0.5), false, 1.0)
		return
	draw_rect(rect, Palette.STONE_DEEP)
	var bars := maxi(int(rect.size.x / 7.0), 2)
	for i in range(1, bars):
		var x := rect.position.x + rect.size.x * float(i) / float(bars)
		draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), Palette.STONE_LIT, 2.0)
	draw_rect(rect, Palette.STONE_LIT, false, 1.0)
