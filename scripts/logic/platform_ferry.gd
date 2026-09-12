## The life of a platform that never stops and was never asking. Pure, so the
## tests can reach it.
##
## `PlatformCycle` is the other clock in M3, and the difference between the two
## is the whole difference between the two hazards. A falling platform is a
## consequence: it does nothing until you stand on it, and then it does one thing
## once. A ferry has no trigger at all. It was crossing the moat before you got
## to the bank and it will still be crossing it after you die, which is why the
## question it asks is when to go and not whether to stop.
##
##   HOME      docked at the end it starts from, waiting
##   OUTBOUND  on its way to the far end
##   AWAY      docked at the far end, waiting
##   INBOUND   on its way back
##
## **It docks at each end rather than turning round on the spot.** The dock is
## the window you board in, and a platform that is only in reach for one frame
## can only be boarded by somebody who already knows the timing, which is the
## 1984 complaint `SPEC.md` exists to throw away.
##
## It travels at a constant speed, and whether it should ease into its two stops
## instead is a feel question that M14 owns. Constant is the version whose timing
## a player can read off the room: it is at the halfway point at the halfway
## time, and easing breaks that.
class_name PlatformFerry

enum Phase {
	## Docked at the end the room put it, waiting. Where a respawn leaves it.
	HOME,
	## Crossing, away from home.
	OUTBOUND,
	## Docked at the far end, waiting.
	AWAY,
	## Crossing, on its way back.
	INBOUND,
}


## How long one crossing takes. Derived from the span rather than authored,
## for the reason `PlatformCycle.fall_seconds` is: what a room cares about is
## how fast the thing moves, and how long it is gone for is a consequence of how
## wide the moat it was put over is. A travel time in the config would go stale
## the moment a room made a moat wider.
static func travel_seconds(span: float, speed: float) -> float:
	if span <= 0.0 or speed <= 0.0:
		return 0.0
	return span / speed


## Out, dock, back, dock. The longest a player who has just missed it can be
## made to wait is this less one dock.
static func period(travel: float, wait: float) -> float:
	return (maxf(travel, 0.0) + maxf(wait, 0.0)) * 2.0


## Where in the period `elapsed` lands. Anything before the start is the start:
## a ferry has no state that precedes its clock.
static func _cursor(elapsed: float, travel: float, wait: float) -> float:
	var whole := period(travel, wait)
	if whole <= 0.0:
		return 0.0
	return fposmod(maxf(elapsed, 0.0), whole)


static func phase_at(elapsed: float, travel: float, wait: float) -> Phase:
	var crossing := maxf(travel, 0.0)
	var dock := maxf(wait, 0.0)
	var at := _cursor(elapsed, crossing, dock)
	if at < dock:
		return Phase.HOME
	if at < dock + crossing:
		return Phase.OUTBOUND
	if at < dock + crossing + dock:
		return Phase.AWAY
	return Phase.INBOUND


## How far along its span it is, from 0 at home to 1 at the far end.
static func progress_at(elapsed: float, travel: float, wait: float) -> float:
	var crossing := maxf(travel, 0.0)
	var dock := maxf(wait, 0.0)
	var at := _cursor(elapsed, crossing, dock)
	if crossing <= 0.0 and dock <= 0.0:
		# No clock at all. It is where the room put it and it stays there, which
		# is a room's bug to fix and not a thing to divide by.
		return 0.0
	if crossing <= 0.0:
		# Nowhere to go, but a dock to wait at: it teleports between its two ends
		# rather than dividing by a crossing that takes no time.
		return 0.0 if at < dock else 1.0
	if at < dock:
		return 0.0
	if at < dock + crossing:
		return (at - dock) / crossing
	if at < dock + crossing + dock:
		return 1.0
	return 1.0 - (at - (dock + crossing + dock)) / crossing


## Where the slab is, relative to home. `span` is the whole trip as the room
## laid it out, so a lift is the same arithmetic with a vertical one.
static func offset_at(elapsed: float, travel: float, wait: float, span: Vector2) -> Vector2:
	return span * progress_at(elapsed, travel, wait)


## For the debug overlay and `tools/capture.gd`.
static func phase_name(phase: Phase) -> String:
	match phase:
		Phase.OUTBOUND:
			return "outbound"
		Phase.AWAY:
			return "away"
		Phase.INBOUND:
			return "inbound"
		_:
			return "home"
