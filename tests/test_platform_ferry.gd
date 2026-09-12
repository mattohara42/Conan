## The moving platform's clock.
##
## Everything a ferry is made of is a duration, so this is where the hazard
## actually lives. The node around it moves a body, carries a rider and draws a
## rail, and none of those three can be asserted headlessly.
extends TestCase

const HAZARDS := "res://config/hazards.tres"

# A ferry over one of the moats in the M3 bench. The numbers are only here to
# give the phases something real to be measured against.
const SPAN: float = 96.0
const SPEED: float = 110.0
const WAIT: float = 0.7


func _travel() -> float:
	return PlatformFerry.travel_seconds(SPAN, SPEED)


func _phase(elapsed: float) -> PlatformFerry.Phase:
	return PlatformFerry.phase_at(elapsed, _travel(), WAIT)


func _progress(elapsed: float) -> float:
	return PlatformFerry.progress_at(elapsed, _travel(), WAIT)


## The order of the cycle, which is the whole of the design: it waits where you
## can board it, it goes, it waits at the other end, it comes back.
func test_the_cycle_runs_in_order() -> void:
	var travel := _travel()
	check_eq(_phase(0.0), PlatformFerry.Phase.HOME, "it starts at the dock it is given")
	check_eq(_phase(WAIT * 0.5), PlatformFerry.Phase.HOME, "and waits there")
	check_eq(_phase(WAIT + travel * 0.5), PlatformFerry.Phase.OUTBOUND, "then it crosses")
	check_eq(
		_phase(WAIT + travel + WAIT * 0.5), PlatformFerry.Phase.AWAY,
		"then it waits at the far end, which is the window you get off in"
	)
	check_eq(
		_phase(WAIT * 2.0 + travel + travel * 0.5), PlatformFerry.Phase.INBOUND,
		"and then it comes back"
	)


## Unlike a falling platform, it has no trigger and no end. A ferry that stopped
## after one trip would be a bridge that closed, and the room behind it would be
## unfinishable rather than hard.
func test_it_never_stops() -> void:
	var travel := _travel()
	var whole := PlatformFerry.period(travel, WAIT)
	check_eq(_phase(whole), PlatformFerry.Phase.HOME, "a whole period later it is home again")
	check_eq(
		_phase(whole * 40.0 + WAIT + travel * 0.5), PlatformFerry.Phase.OUTBOUND,
		"and forty periods later it is still running"
	)
	check_eq(_phase(-1.0), PlatformFerry.Phase.HOME, "nothing precedes its clock")


## The crossing is derived from how far it has to go, so a room that makes a
## moat wider does not need a second number in the config.
func test_a_crossing_is_as_long_as_the_span_makes_it() -> void:
	check_near(_travel(), SPAN / SPEED, 0.0001, "a crossing is its span over its speed")
	check(
		PlatformFerry.travel_seconds(SPAN * 2.0, SPEED) > _travel(),
		"a wider moat takes longer to cross"
	)
	check_eq(PlatformFerry.travel_seconds(0.0, SPEED), 0.0, "no span, no crossing")
	check_eq(PlatformFerry.travel_seconds(SPAN, 0.0), 0.0, "and a ferry with no speed never goes")


## Constant speed, which is what lets a player read the timing off the room:
## halfway along at the halfway time, and the same again coming back.
func test_it_crosses_at_a_constant_speed() -> void:
	var travel := _travel()
	check_near(_progress(WAIT), 0.0, 0.0001, "it leaves from home")
	check_near(_progress(WAIT + travel * 0.25), 0.25, 0.0001, "a quarter of the way across")
	check_near(_progress(WAIT + travel * 0.75), 0.75, 0.0001, "three quarters")
	check_near(_progress(WAIT + travel), 1.0, 0.0001, "and all the way")
	check_near(
		_progress(WAIT * 2.0 + travel * 1.5), 0.5, 0.0001,
		"and it is halfway back at the halfway point of the return"
	)


## The dock is the window you board in. A ferry that turned round on the spot
## could only be caught by somebody who already knew the timing, which is the
## 1984 complaint SPEC.md exists to throw away.
func test_it_holds_still_at_both_ends() -> void:
	var travel := _travel()
	for i in 20:
		var t := WAIT * float(i) / 20.0
		check_near(_progress(t), 0.0, 0.0001, "it does not creep away from the near dock")
		check_near(
			_progress(WAIT + travel + t), 1.0, 0.0001,
			"nor away from the far one"
		)


## Where the slab is, for a room that laid its trip out as an offset.
func test_the_offset_follows_the_trip_the_room_gave_it() -> void:
	var travel := _travel()
	var span := Vector2(SPAN, 0.0)
	check_eq(
		PlatformFerry.offset_at(0.0, travel, WAIT, span), Vector2.ZERO,
		"docked at home it is where the room put it"
	)
	check_near(
		PlatformFerry.offset_at(WAIT + travel, travel, WAIT, span).x, SPAN, 0.01,
		"and a whole crossing later it is a span away"
	)
	var lift := PlatformFerry.offset_at(WAIT + travel, travel, WAIT, Vector2(0.0, -SPAN))
	check_near(lift.y, -SPAN, 0.01, "the same arithmetic carries a vertical trip")


## A ferry with nowhere to go is a bug in a room, and the clock's job is to not
## divide by it.
func test_a_ferry_with_no_span_is_still_answerable() -> void:
	check_eq(PlatformFerry.phase_at(0.3, 0.0, WAIT), PlatformFerry.Phase.HOME, "it sits at home")
	check_near(
		PlatformFerry.progress_at(0.3, 0.0, WAIT), 0.0, 0.0001, "and has got nowhere"
	)
	check_eq(PlatformFerry.period(0.0, 0.0), 0.0, "a ferry with no clock has no period")
	check_near(
		PlatformFerry.progress_at(5.0, 0.0, 0.0), 0.0, 0.0001,
		"and asking where it is does not divide by that"
	)


## The config's own numbers, against the room they have to serve.
func test_the_real_numbers_keep_a_missed_ferry_cheap() -> void:
	var hazards: HazardConfig = load(HAZARDS)
	var travel := PlatformFerry.travel_seconds(SPAN, hazards.platform_travel_speed)
	# What missing the dock costs: it goes out, it waits at the other end, it
	# comes back. A death does not cost this, because a respawn puts every ferry
	# back at the dock beside you. Being alive and late does.
	var missed := travel * 2.0 + hazards.platform_wait_time
	check(
		missed < 2.5,
		"missing a ferry costs %.2f s, which is a wait and not a queue" % missed
	)
	var move: MovementConfig = load("res://config/movement.tres")
	check(
		hazards.platform_travel_speed < move.max_run_speed,
		"a ferry moves at %.0f px/s against a %.0f px/s run, so catching one is never a chase" % [
			hazards.platform_travel_speed, move.max_run_speed
		]
	)
	check(
		hazards.platform_wait_time > 0.0,
		"and it stops at each end, or there is no window to board it in"
	)
