## The death loop as arithmetic. No nodes, no state, so a headless test reaches
## every line.
##
## SPEC.md keeps insta-death and throws away the punishment for it: under one
## second from dying to moving again, swords restored, at the last brazier. That
## sentence is two durations and one edge, and this file is all three.
##
## The shape is deliberately not one timer. A death that cuts instantly to the
## spawn point reads as a glitch rather than a death, so there is a beat where
## you see that you died, and a second beat where you see where you have landed
## before the controls answer. Both are tuned in `config/death.tres` and both
## count against the one second.
class_name DeathClock

enum Phase {
	## You have been killed and the body has not moved yet.
	DYING,
	## Placed at the checkpoint with swords restored, controls still dead.
	RECOVERING,
	## Yours again.
	ALIVE,
}


## What the whole loop costs, death to moving again. This is the number M3's
## done-when is about, and `test_death_clock.gd` holds `config/death.tres` to it.
static func downtime(death_hold: float, respawn_freeze: float) -> float:
	return maxf(death_hold, 0.0) + maxf(respawn_freeze, 0.0)


static func phase_at(elapsed: float, death_hold: float, respawn_freeze: float) -> Phase:
	if elapsed < maxf(death_hold, 0.0):
		return Phase.DYING
	if elapsed < downtime(death_hold, respawn_freeze):
		return Phase.RECOVERING
	return Phase.ALIVE


## The controls answer only in ALIVE. Kept as its own function because it is the
## question the character script actually asks, and routing that through an enum
## comparison at the call site is how one branch ends up disagreeing.
static func has_control(elapsed: float, death_hold: float, respawn_freeze: float) -> bool:
	return phase_at(elapsed, death_hold, respawn_freeze) == Phase.ALIVE


## True on the one step that crosses the placement edge, so the body is moved to
## the checkpoint exactly once however long a frame runs.
##
## A step covers `[before, after)`: it has crossed the edge when it started at or
## before it and ended past it. Two cases decide that convention rather than
## taste. A frame longer than `death_hold` still has to fire, which a `==`
## comparison silently drops. And a `death_hold` of zero has to fire on the first
## step, which the other half-open convention (`before < edge`) cannot express at
## all, because no step ever begins before zero. That one is not academic: with
## the hold at zero the body would never be placed, and the player would get the
## controls back standing in whatever killed them, dying forever.
static func crosses_placement(before: float, after: float, death_hold: float) -> bool:
	var edge := maxf(death_hold, 0.0)
	return before <= edge and after > edge


static func phase_name(phase: Phase) -> String:
	match phase:
		Phase.DYING:
			return "dying"
		Phase.RECOVERING:
			return "recovering"
		_:
			return "alive"
