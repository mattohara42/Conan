## The death loop's arithmetic, and the milestone's own done-when.
##
## BUILD_PLAN.md M3: death to respawn to moving again is under one second,
## measured. The last test here is that sentence asserted against
## `config/death.tres`, so retuning the loop in M14 past a second fails rather
## than quietly shipping.
extends TestCase

const DEATH := "res://config/death.tres"

## BUILD_PLAN.md's number. A budget rather than a target: 0.9 would pass and
## would also be a bad game, which is why the feel half of the done-when is
## answered by playing and not by this file.
const BUDGET_SECONDS := 1.0

const HOLD := 0.25
const FREEZE := 0.15


func test_the_tuning_file_loads() -> void:
	check(load(DEATH) is DeathConfig, "config/death.tres is a DeathConfig")


func test_no_number_in_it_is_nonsense() -> void:
	var config: DeathConfig = load(DEATH)
	check(config.death_hold >= 0.0, "death hold is not negative")
	check(config.respawn_freeze >= 0.0, "respawn freeze is not negative")
	check(config.death_hold > 0.0, "death hold is not zero, or a death does not read as one")


func test_the_phases_run_in_order() -> void:
	check_eq(DeathClock.phase_at(0.0, HOLD, FREEZE), DeathClock.Phase.DYING, "death starts dying")
	check_eq(
		DeathClock.phase_at(HOLD - 0.01, HOLD, FREEZE), DeathClock.Phase.DYING,
		"still dying just before the hold ends"
	)
	check_eq(
		DeathClock.phase_at(HOLD, HOLD, FREEZE), DeathClock.Phase.RECOVERING,
		"placed at the checkpoint the moment the hold ends"
	)
	check_eq(
		DeathClock.phase_at(HOLD + FREEZE - 0.01, HOLD, FREEZE), DeathClock.Phase.RECOVERING,
		"still recovering just before the freeze ends"
	)
	check_eq(
		DeathClock.phase_at(HOLD + FREEZE, HOLD, FREEZE), DeathClock.Phase.ALIVE,
		"alive the moment the freeze ends"
	)


func test_the_controls_answer_only_when_alive() -> void:
	check(not DeathClock.has_control(0.0, HOLD, FREEZE), "no control while dying")
	check(not DeathClock.has_control(HOLD, HOLD, FREEZE), "no control while recovering")
	check(DeathClock.has_control(HOLD + FREEZE, HOLD, FREEZE), "control once alive")


## The body is placed on the step that crosses the edge, not on the step that
## happens to land on it. A frame longer than the whole hold still has to move
## you, or a hitch on a slow machine leaves the corpse where it fell.
func test_placement_fires_once_however_long_the_frame_is() -> void:
	check(DeathClock.crosses_placement(0.24, 0.26, HOLD), "a normal step across the edge places")
	check(not DeathClock.crosses_placement(0.26, 0.28, HOLD), "the step after it does not")
	check(not DeathClock.crosses_placement(0.10, 0.20, HOLD), "a step before it does not")
	check(
		DeathClock.crosses_placement(0.0, 4.0, HOLD),
		"a frame longer than the whole hold still places"
	)


func test_a_zero_hold_still_places_on_the_first_step() -> void:
	check(DeathClock.crosses_placement(0.0, 0.016, 0.0), "a zero hold places immediately")
	check(
		DeathClock.has_control(0.0, 0.0, 0.0),
		"with both durations zero there is never a frame without control"
	)


## BUILD_PLAN.md M3's done-when, as an assertion against the file that decides
## it. If M14 retunes the loop past a second this is the test that says so, and
## it names the two numbers rather than the total so the report is actionable.
func test_the_loop_fits_inside_one_second() -> void:
	var config: DeathConfig = load(DEATH)
	var total := DeathClock.downtime(config.death_hold, config.respawn_freeze)
	check(
		total < BUDGET_SECONDS,
		"death to moving again is %.3fs, and BUILD_PLAN.md M3 budgets %.3fs (hold %.3f + freeze %.3f)" % [
			total, BUDGET_SECONDS, config.death_hold, config.respawn_freeze
		]
	)
