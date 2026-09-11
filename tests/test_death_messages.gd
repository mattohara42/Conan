## The death messages, and the rule that makes them rotate.
##
## The 1984 original had fifteen. Four survive in `assets/reference/c64/` and
## CLAUDE.md forbids shipping anything out of that directory, so every line here
## is an original written to the same register. These assertions are about the
## set and the rotation, not about whether any one line is funny.
extends TestCase

const DEATH := "res://config/death.tres"


func test_there_are_fifteen_as_the_original_had() -> void:
	check_eq(DeathMessages.count(), 15, "fifteen death messages")


func test_no_message_is_repeated() -> void:
	var seen: Dictionary = {}
	for i in DeathMessages.count():
		var text := DeathMessages.message_at(i)
		check(not seen.has(text), "\"%s\" appears only once in the pool" % text)
		seen[text] = true


func test_every_message_fits_the_hud() -> void:
	for i in DeathMessages.count():
		var text := DeathMessages.message_at(i)
		check(not text.is_empty(), "message %d is not blank" % i)
		check(
			text.length() <= DeathMessages.MAX_LENGTH,
			"\"%s\" is %d characters, and the HUD takes %d" % [
				text, text.length(), DeathMessages.MAX_LENGTH
			]
		)


func test_an_index_outside_the_pool_is_blank_rather_than_a_crash() -> void:
	check_eq(DeathMessages.message_at(-1), "", "a negative index is blank")
	check_eq(DeathMessages.message_at(DeathMessages.count()), "", "one past the end is blank")


## The whole point of a bag rather than a random pick. "Unique, rotating" means
## you see all fifteen before you see any of them twice, which matters in a game
## built to be died in often: a plain random pick repeats within a few deaths
## and the tradition stops reading as a set.
func test_every_message_is_seen_before_any_repeats() -> void:
	var bag: PackedInt32Array = []
	var seen: Dictionary = {}
	# A spread of rolls rather than one, so the test does not only ever take
	# slot zero and miss a bag that shrinks wrongly.
	var rolls: PackedFloat32Array = [0.0, 0.5, 0.99, 0.25, 0.75]
	for i in DeathMessages.count():
		bag = DeathMessages.refill_if_empty(bag, DeathMessages.count())
		var slot := DeathMessages.slot_for(rolls[i % rolls.size()], bag.size())
		seen[bag[slot]] = true
		bag.remove_at(slot)
	check_eq(
		seen.size(), DeathMessages.count(),
		"all %d messages appear in the first %d deaths" % [
			DeathMessages.count(), DeathMessages.count()
		]
	)


func test_the_bag_refills_only_when_empty() -> void:
	var empty: PackedInt32Array = []
	check_eq(
		DeathMessages.refill_if_empty(empty, 15).size(), 15,
		"an empty bag refills to the whole pool"
	)
	var partial: PackedInt32Array = [3, 7]
	check_eq(
		DeathMessages.refill_if_empty(partial, 15).size(), 2,
		"a bag with anything left in it is untouched"
	)


## A roll of exactly 1.0 is the bug that would show up once in a few thousand
## deaths and never in a test that only ever passes 0.5.
func test_the_top_of_the_roll_range_stays_inside_the_bag() -> void:
	check_eq(DeathMessages.slot_for(0.0, 15), 0, "a roll of zero takes the first slot")
	check_eq(DeathMessages.slot_for(0.999, 15), 14, "a roll just under one takes the last")
	check_eq(DeathMessages.slot_for(1.0, 15), 14, "a roll of exactly one does not fall off the end")
	check_eq(DeathMessages.slot_for(0.5, 0), -1, "an empty bag has no slot to take")


## Centred on a 640x360 viewport, so a size that fits the longest line matters.
## At roughly half the point size in pixels per character, 32 characters at 24 pt
## is about 384 px, which clears 640 with room either side.
func test_the_message_is_large_enough_to_read_and_narrow_enough_to_fit() -> void:
	var config: DeathConfig = load(DEATH)
	check(
		config.message_font_size >= 16,
		"the message is %d pt, and smaller than 16 is not a glance" % config.message_font_size
	)
	var widest := float(DeathMessages.MAX_LENGTH) * float(config.message_font_size) * 0.5
	check(
		widest < 640.0,
		"the longest line at %d pt is about %.0f px wide against a 640 px viewport" % [
			config.message_font_size, widest
		]
	)


func test_the_message_outlasts_the_loop() -> void:
	var config: DeathConfig = load(DEATH)
	var loop := DeathClock.downtime(config.death_hold, config.respawn_freeze)
	check(
		config.message_seconds > loop,
		"the message lasts %.2f s and the loop is %.2f s, so it is still readable once you can move" % [
			config.message_seconds, loop
		]
	)
