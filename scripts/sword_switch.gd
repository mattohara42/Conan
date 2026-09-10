## A switch a sword holds down.
##
## Wood, so a throw bites it, plus a detection area a little larger than the
## block so that a sword sitting against its face counts as being in it.
##
## It polls rather than listening. A sword goes from FLYING to EMBEDDED without
## moving, so no area signal fires at the moment that matters, and a switch that
## only listened would never notice the one event it exists for.
class_name SwordSwitch
extends Area2D

## True while at least one embedded sword is in it.
signal held_changed(is_held: bool)

## How far past the block's edges a sword still counts as in the switch. A sword
## stops with its blade against the face, so without this the overlap is a hair
## wide and whether it registers is down to rounding.
const REACH: float = 12.0

var is_held := false

## The block itself, which is smaller than the area that senses it.
var _block := Vector2.ZERO


## Builds its own collision rather than being handed one, so nothing depends on
## what a node added in code ends up being named. A `$CollisionShape2D` lookup
## here found nothing, because Godot names an unnamed child `@ClassName@N`.
func configure(block: Vector2) -> void:
	_block = block
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = block + Vector2.ONE * REACH * 2.0
	shape.shape = box
	add_child(shape)


func _ready() -> void:
	add_to_group("switches")
	# Layer 4 is swords. The switch watches for them and nothing else.
	collision_layer = 0
	collision_mask = 8


func _physics_process(_delta: float) -> void:
	var held := _a_sword_is_in_it()
	if held == is_held:
		return
	is_held = held
	held_changed.emit(is_held)
	queue_redraw()


func _a_sword_is_in_it() -> bool:
	for area in get_overlapping_areas():
		var sword := area as Sword
		if sword != null and SwordFlight.holds_a_switch(sword.state):
			return true
	return false


## Gold when held, because gold means interactive and a switch you have spent a
## sword on should say so from across the room.
func _draw() -> void:
	if _block == Vector2.ZERO:
		return
	var block := Rect2(-_block * 0.5, _block)
	draw_rect(block, Palette.WOOD_DEEP)
	draw_rect(Rect2(block.position, Vector2(block.size.x, 3.0)), Palette.WOOD_FACE)
	var lamp: Color = Palette.GOLD_FACE if is_held else Palette.WOOD_FACE
	draw_rect(block.grow(-4.0), Color(lamp, 0.55 if is_held else 0.2))
	draw_rect(block, lamp, false, 1.0)
