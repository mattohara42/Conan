## The hex side of ART_DIRECTION.md, for everything the code colours: shaders,
## particles, UI, and the placeholder geometry of the grey-box milestones.
##
## The prose in ART_DIRECTION.md is the source of truth. These are transcriptions
## of it, and `test_palette.gd` holds every one of them to the coloured-dark rule.
class_name Palette

# Cold stone. Everything not on fire.
const STONE_DEEP := Color("3a3550")
const STONE_MID := Color("565073")
const STONE_LIT := Color("7d7a99")

# Firelight. Braziers, torches, the hero's rim light.
const FIRE_CORE := Color("f0a63c")
const FIRE_HOT := Color("ffd98a")
const FIRE_FALLOFF := Color("a35a22")

# Lava. The one saturated thing in the game.
const LAVA_CRUST := Color("6b1f14")
const LAVA_FLOW := Color("d94f1e")
const LAVA_FISSURE := Color("ffb64a")
const LAVA_CORE := Color("fff0c2")

# Electricity. Act 3 and Volta, and the only cool bright.
const ARC := Color("5fe0e8")
const ARC_CORE := Color("eafcff")
const ARC_RESIDUE := Color("2a6f8a")

# Gold means interactive and nothing else gets to use it.
const GOLD_FACE := Color("e8c25a")
const GOLD_SHADE := Color("a37c26")

# The backdrop a room sits against before there is a painted background.
const BACKDROP := Color("211c33")


## Every named colour, so the rule check has something to iterate.
static func all() -> Dictionary:
	return {
		"STONE_DEEP": STONE_DEEP,
		"STONE_MID": STONE_MID,
		"STONE_LIT": STONE_LIT,
		"FIRE_CORE": FIRE_CORE,
		"FIRE_HOT": FIRE_HOT,
		"FIRE_FALLOFF": FIRE_FALLOFF,
		"LAVA_CRUST": LAVA_CRUST,
		"LAVA_FLOW": LAVA_FLOW,
		"LAVA_FISSURE": LAVA_FISSURE,
		"LAVA_CORE": LAVA_CORE,
		"ARC": ARC,
		"ARC_CORE": ARC_CORE,
		"ARC_RESIDUE": ARC_RESIDUE,
		"GOLD_FACE": GOLD_FACE,
		"GOLD_SHADE": GOLD_SHADE,
		"BACKDROP": BACKDROP,
	}
