## Anything that kills on contact.
##
## SPEC.md keeps the original's lethality and throws away its punishment, so this
## is deliberately the dumbest node in the repo: it has no damage number, no
## cooldown and no state. It touches you and you die. Everything interesting
## about dying lives in `DeathClock` and `config/death.tres`.
##
## Lava, spikes and the rest differ in how they are drawn and where they sit,
## not in what they do, so they share this rather than each having a script.
class_name Hazard
extends Area2D


## `size` is the whole killing box. The room owns where it goes and what it
## looks like: a hazard that drew itself would need to know it was lava.
func configure(size: Vector2) -> void:
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = size
	shape.shape = box
	add_child(shape)
	# The player is layer 3 (`collision_layer = 4` in player.tscn), and that is
	# the only thing this watches. Masking the world instead would fire on every
	# platform the lava is sitting in.
	collision_layer = 0
	collision_mask = 4
	monitorable = false
	add_to_group("hazards")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player != null:
		player.die()
