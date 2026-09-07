## The tuning files themselves. CLAUDE.md puts every feel-deciding number in
## config/, which only helps if something notices when one of them stops making
## sense.
extends TestCase

const STRONG := "res://config/movement.tres"
const LADDERS := "res://config/movement_ladders.tres"
const WORLD := "res://config/world.tres"

## The two presets are a controlled experiment, so everything except the jump
## and the time it takes has to be identical between them.
const SHARED_PROPERTIES: PackedStringArray = [
	"max_run_speed", "ground_accel", "ground_friction", "air_accel", "air_friction",
	"fall_gravity_multiplier", "jump_release_damping", "max_fall_speed",
	"coyote_time", "jump_buffer_time", "climb_speed",
]


func test_every_tuning_file_loads() -> void:
	check(load(STRONG) is MovementConfig, "config/movement.tres is a MovementConfig")
	check(load(LADDERS) is MovementConfig, "config/movement_ladders.tres is a MovementConfig")
	check(load(WORLD) is WorldConfig, "config/world.tres is a WorldConfig")


func test_no_tuning_number_is_nonsense() -> void:
	var presets: PackedStringArray = [STRONG, LADDERS]
	for path in presets:
		var config: MovementConfig = load(path)
		var name := path.get_file()
		check(config.max_run_speed > 0.0, "%s run speed is positive" % name)
		check(config.jump_height > 0.0, "%s jump height is positive" % name)
		check(config.time_to_apex > 0.0, "%s time to apex is positive" % name)
		check(config.ground_accel > 0.0, "%s ground accel is positive" % name)
		check(config.climb_speed > 0.0, "%s climb speed is positive" % name)
		check(config.max_fall_speed > 0.0, "%s max fall speed is positive" % name)
		check(config.coyote_time >= 0.0, "%s coyote time is not negative" % name)
		check(config.jump_buffer_time >= 0.0, "%s jump buffer is not negative" % name)
		check(
			config.fall_gravity_multiplier >= 1.0,
			"%s falls at least as fast as it rises, or the jump floats" % name
		)
		check(
			config.jump_release_damping >= 0.0 and config.jump_release_damping <= 1.0,
			"%s release damping is a fraction" % name
		)
		check(
			config.air_accel <= config.ground_accel,
			"%s air control does not exceed ground control" % name
		)


## The jump-versus-ladders question in SPEC.md, stated as an assertion. If either
## of these fails, the two presets have stopped being the two answers.
func test_the_two_presets_sit_on_opposite_sides_of_a_tier() -> void:
	var world: WorldConfig = load(WORLD)
	var strong: MovementConfig = load(STRONG)
	var ladders: MovementConfig = load(LADDERS)
	check(
		strong.jump_height > world.tier_height,
		"the strong preset clears a tier without a ladder"
	)
	check(
		ladders.jump_height < world.tier_height,
		"the ladder preset cannot clear a tier, which is the point of it"
	)


## Gravity is the same in both, so jump height is the only variable and the
## comparison means something. See the note in config/movement_ladders.tres.
func test_the_two_presets_share_a_gravity() -> void:
	var strong: MovementConfig = load(STRONG)
	var ladders: MovementConfig = load(LADDERS)
	var g_strong := Motion.gravity_for(strong.jump_height, strong.time_to_apex)
	var g_ladders := Motion.gravity_for(ladders.jump_height, ladders.time_to_apex)
	check_near(g_ladders, g_strong, g_strong * 0.01, "derived gravity matches within 1 percent")


func test_the_two_presets_differ_in_nothing_else() -> void:
	var strong: MovementConfig = load(STRONG)
	var ladders: MovementConfig = load(LADDERS)
	for property in SHARED_PROPERTIES:
		check_eq(
			ladders.get(property), strong.get(property),
			"%s is shared between the presets" % property
		)


func test_world_scale_holds_together() -> void:
	var world: WorldConfig = load(WORLD)
	check(world.hero_height > 0.0, "hero height is positive")
	check(world.hero_width > 0.0, "hero width is positive")
	check(
		world.hero_width < world.hero_height,
		"the hero is taller than it is wide, or the silhouette will not read"
	)
	check(
		world.tier_height > world.hero_height,
		"a tier is taller than the hero, or it is a step and not a storey"
	)
	check(
		is_zero_approx(fmod(world.tier_height, world.tile_size)),
		"tier height is a whole number of tiles"
	)
