## Where a death puts you back.
##
## SPEC.md: a death returns you to the last lit brazier. A brazier knows the
## floor point it stands on and the player knows how tall it is, and the sum of
## those two is a position neither of them should be doing in its head. The
## first version of this handed the brazier's own origin straight to
## `spawn_point` and respawned the hero buried to the waist in the floor.
class_name Checkpoints


## The body centre that stands a hero of `hero_height` on the floor point
## `base`. Braziers are placed by the foot, so `base.y` is the floor surface.
static func stand_point(base: Vector2, hero_height: float) -> Vector2:
	return Vector2(base.x, base.y - hero_height * 0.5)
