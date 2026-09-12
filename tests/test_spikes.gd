## The spike geometry, which is the one hazard where what is drawn and what
## kills are different rectangles. If those two drift apart, the player dies to
## something that is not on the screen, and no screenshot can catch it.
extends TestCase

const PITCH: float = 8.0
const HEIGHT: float = 12.0
const GRACE: float = 3.0

## Six teeth standing on a floor at y = 320.
func _bed() -> Rect2:
	return Spikes.bed_on(320.0, 100.0, 6, PITCH, HEIGHT)


func test_a_bed_stands_on_the_surface_it_was_given() -> void:
	var bed := _bed()
	check_eq(bed.end.y, 320.0, "the bases sit on the surface")
	check_eq(bed.position.y, 308.0, "the points reach a tooth height above it")
	check_eq(bed.size.x, 48.0, "six teeth at a pitch of 8 is 48 px wide")


func test_a_bed_is_drawn_as_the_teeth_it_was_asked_for() -> void:
	var teeth := Spikes.teeth(_bed(), PITCH)
	check_eq(teeth.size(), 6, "six teeth were asked for and six are drawn")
	for tooth in teeth:
		check_eq(tooth.size(), 3, "a tooth is a triangle")
		check_eq(tooth[1].y, 308.0, "its apex is at the tip line")
		check_eq(tooth[0].y, 320.0, "its bases are on the surface")
		check_near(
			tooth[1].x, (tooth[0].x + tooth[2].x) * 0.5, 0.001,
			"the point is over the middle of the base"
		)


## The inset that stops an unfair death. At the bed's left edge the first tooth
## has no height at all, so a killing box that reached there would kill a
## landing that touched nothing.
func test_the_killing_box_runs_point_to_point_and_not_edge_to_edge() -> void:
	var bed := _bed()
	var box := Spikes.lethal_box(bed, PITCH, GRACE)
	var teeth := Spikes.teeth(bed, PITCH)
	check_near(box.position.x, teeth[0][1].x, 0.001, "it starts at the first point")
	check_near(box.end.x, teeth[teeth.size() - 1][1].x, 0.001, "it ends at the last point")
	check(box.size.x < bed.size.x, "and so it is narrower than what is drawn")


func test_the_killing_box_starts_below_the_points() -> void:
	var bed := _bed()
	var box := Spikes.lethal_box(bed, PITCH, GRACE)
	check_eq(box.position.y, 311.0, "the top %.0f px of the teeth do not kill" % GRACE)
	check_eq(box.end.y, bed.end.y, "and it reaches down to the surface")


## The grace is forgiveness, so it can only ever shrink the box. A grace bigger
## than the teeth would otherwise turn it inside out and kill above them.
func test_the_grace_cannot_invert_the_box() -> void:
	var bed := _bed()
	var box := Spikes.lethal_box(bed, PITCH, HEIGHT * 4.0)
	check(box.size.y >= 0.0, "an absurd grace leaves no box rather than a negative one")
	check(box.end.y <= bed.end.y, "and never reaches below the surface")
	var negative := Spikes.lethal_box(bed, PITCH, -5.0)
	check_eq(negative.position.y, bed.position.y, "a negative grace is no grace, not extra reach")


## A bed narrower than one tooth has nothing to inset, and the inset must not
## wrap around into a box with negative width.
func test_a_bed_too_small_for_a_tooth_kills_nobody() -> void:
	var stub := Spikes.bed_on(320.0, 100.0, 0, PITCH, HEIGHT)
	check_eq(Spikes.teeth(stub, PITCH).size(), 0, "no teeth are drawn")
	check_eq(Spikes.lethal_box(stub, PITCH, GRACE).size.x, 0.0, "and nothing kills")


func test_a_pitch_of_zero_does_not_divide_by_it() -> void:
	check_eq(Spikes.tooth_count(48.0, 0.0), 0, "a pitch of zero is no teeth, not a crash")
	check_eq(Spikes.bed_width(6, 0.0), 0.0, "and no width")
