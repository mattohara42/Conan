## The geometry of a spike bed. Pure, so the tests can reach it.
##
## Spikes are lava's rule (touch it, die) on a surface instead of in a pit, and
## that is the whole of the difference. What they buy is placement: lava has to
## sit in a hole in the floor, and a spike bed can sit on top of the block you
## were going to land on. So this file is about shape and nothing else, and
## `Hazard` stays the one script that kills.
##
## A bed is the rectangle the drawn teeth occupy, tips at the top and bases on
## the surface. Give it a whole number of teeth: a partial one at the right-hand
## end is not drawn, and then the picture and the killing box stop agreeing.
class_name Spikes


## How wide a bed of `count` teeth is, so a room asks for teeth rather than
## carrying a pixel width that silently stops being a whole number of them.
static func bed_width(count: int, pitch: float) -> float:
	return maxf(float(count), 0.0) * pitch


static func tooth_count(width: float, pitch: float) -> int:
	if pitch <= 0.0:
		return 0
	return int(floorf(width / pitch))


## The teeth, as triangles: base left, apex, base right.
static func teeth(bed: Rect2, pitch: float) -> Array[PackedVector2Array]:
	var shapes: Array[PackedVector2Array] = []
	for i in tooth_count(bed.size.x, pitch):
		var left := bed.position.x + pitch * float(i)
		shapes.append(PackedVector2Array([
			Vector2(left, bed.end.y),
			Vector2(left + pitch * 0.5, bed.position.y),
			Vector2(left + pitch, bed.end.y),
		]))
	return shapes


## The box that actually kills, which is smaller than the bed in both axes.
##
## Sideways it runs apex to apex, half a tooth in from each end, because the
## first tooth has no height at the bed's left edge and dying over a gap between
## the points is the unfair death this inset exists to prevent.
##
## Vertically it starts `grace` below the tips, so a jump that just brushes the
## points lives. That is the forgiving direction and it is the only forgiveness
## in the hazard: SPEC.md keeps the lethality and throws away the punishment.
static func lethal_box(bed: Rect2, pitch: float, grace: float) -> Rect2:
	var side := minf(pitch * 0.5, bed.size.x * 0.5)
	var top := clampf(grace, 0.0, bed.size.y)
	return Rect2(
		Vector2(bed.position.x + side, bed.position.y + top),
		Vector2(maxf(bed.size.x - side * 2.0, 0.0), bed.size.y - top)
	)


## A bed standing on the surface at `surface_y`, which is what a room knows: the
## top of a floor or the top of the block the bed is bolted to.
static func bed_on(surface_y: float, x: float, count: int, pitch: float, height: float) -> Rect2:
	return Rect2(x, surface_y - height, bed_width(count, pitch), height)
