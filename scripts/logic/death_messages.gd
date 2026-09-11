## What the game says when it kills you.
##
## The 1984 original put a bordered box on the level carrying one of fifteen
## short, mock-heroic lines. `assets/reference/c64/` holds four of them and
## CLAUDE.md forbids shipping anything out of that directory, so these are
## originals written to the same register: brief, archaic, and absurdly formal
## about a stupid death.
##
## **The box does not come with them.** SPEC.md's central modernisation is that
## dying costs under a second, and a box you have to read costs two. The line
## therefore lingers while you are already running again, which keeps the
## tradition and the done-when at the same time.
class_name DeathMessages

## Fifteen, as the original had. Kept short because they are drawn over a room
## at 640x360 and `test_death_messages.gd` holds them to a width the HUD fits.
const POOL: PackedStringArray = [
	"A MOLTEN WELCOME",
	"THE MOUNTAIN DRINKS DEEP",
	"SPITTED LIKE A HOG",
	"THE FLOOR OBJECTED",
	"THE MOAT KEEPS ITS OWN",
	"GRAVITY, UNDEFEATED",
	"YOU SUCCUMB TO MOMENTUM",
	"THE GEYSER HAD OTHER PLANS",
	"VOLTA SENDS HIS REGARDS",
	"A BRIEF AND BRILLIANT CAREER",
	"LOTHARS BANE",
	"BESTED BY VERMIN",
	"AN IGNOBLE PAUSE",
	"THE HILL PEOPLE MUST NOT HEAR",
	"A LESSON IN HUMILITY",
]

## The widest line the HUD will take, in characters.
const MAX_LENGTH := 32


static func count() -> int:
	return POOL.size()


static func message_at(index: int) -> String:
	if index < 0 or index >= POOL.size():
		return ""
	return POOL[index]


## A bag of every unused index, refilled once it empties. This is what makes the
## rotation **unique** rather than merely random: you see all fifteen before you
## see any of them twice, which matters in a game built to be died in often.
static func refill_if_empty(bag: PackedInt32Array, pool_size: int) -> PackedInt32Array:
	if not bag.is_empty():
		return bag
	var filled: PackedInt32Array = []
	for i in maxi(pool_size, 0):
		filled.append(i)
	return filled


## Which slot of the bag to take, for a roll in [0, 1). Its own function because
## clamping the top of the range is the bug that would otherwise show up once
## every few thousand deaths and never in a test.
static func slot_for(roll: float, bag_size: int) -> int:
	if bag_size <= 0:
		return -1
	return clampi(int(roll * float(bag_size)), 0, bag_size - 1)
