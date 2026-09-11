## Where a brazier puts you back.
##
## One function, and it is here because the bug it prevents is a geometry bug,
## which is the class of bug this project keeps shipping past green assertions.
## A brazier is placed by its foot and a hero is positioned by its centre, and
## handing one straight to the other buries the respawn in the floor.
extends TestCase


func _hero_height() -> float:
	var world: WorldConfig = load("res://config/world.tres")
	return world.hero_height


func test_the_respawn_stands_on_the_floor_the_brazier_stands_on() -> void:
	var height := _hero_height()
	var point := Checkpoints.stand_point(Vector2(470.0, 320.0), height)
	check_near(point.y + height * 0.5, 320.0, 0.001, "the hero's feet are on the floor")
	check_near(point.x, 470.0, 0.001, "the hero stands at the brazier, not beside it")


## Every size the debug keys can put the hero at, because the respawn is
## computed from `world.hero_height` and that number is cycled at runtime.
func test_every_hero_size_lands_feet_on_the_floor() -> void:
	for height in Player.HERO_HEIGHT_STEPS:
		var point := Checkpoints.stand_point(Vector2(0.0, 100.0), height)
		check_near(
			point.y + height * 0.5, 100.0, 0.001,
			"a %.0f px hero stands on the floor" % height
		)
