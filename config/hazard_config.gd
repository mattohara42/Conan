## Every number a hazard's shape is made of.
##
## CLAUDE.md puts hazard tuning in `config/`, and a spike bed has one number
## that decides how the game feels: `spike_grace`, the depth you can sink into
## the points and live. Getting that wrong is the difference between a hazard
## that is hard and one that is unfair, and it is not something a script gets
## to hold.
##
## Lava is not here. Lava is a rectangle a room hands to `Hazard` and it has no
## shape of its own to tune. Geysers will want a row of their own and they can
## be added when they exist.
##
## A falling platform is not a hazard either, in the sense that it has no
## killing box and never touches `Hazard`: it is the thing that drops you into
## one. Its numbers are here because they are what a room full of hazards is
## tuned against, and splitting them into a file of their own would put two
## halves of the same decision in two places.
class_name HazardConfig
extends Resource

@export_group("Spikes")
## How far a tooth stands off the surface it is bolted to, in design px. Read
## against WorldConfig.tile_size: three quarters of a tile, so a bed reads as
## spikes rather than as a rough floor.
@export var spike_tooth_height: float = 12.0
## Base width of one tooth, and therefore the spacing of the points. Half a
## tile, which puts two points under a standing hero.
@export var spike_tooth_pitch: float = 8.0
## How far below the points the killing box starts, in design px. Brushing the
## tips lives, sinking past this dies.
##
## It only ever applies to a jump arc crossing a bed near its apex, where the
## vertical speed is close to zero, because nothing else approaches a bed
## downwards slowly. Measured in a running build at this value it does not
## change the takeoff window on the M3 spike bench at all, so whether it is
## worth having is a feel question and M14 owns it. A quarter of a tooth.
@export var spike_grace: float = 3.0

@export_group("Falling platforms")
## Seconds from something standing on a platform to the platform letting go.
## The number the whole hazard is made of: it is how long you are allowed to
## stand still, and the room around it is built against it.
##
## Long enough to land, read the shake and jump, and short enough that crossing
## a moat is one continuous decision rather than a queue. Against a 200 px/s run
## and a 48 px slab, it is a little under twice what crossing one slab costs.
@export var platform_warn_time: float = 0.45
## How hard a let-go platform falls, px/s^2. Deliberately gentler than the
## hero's own falling gravity, so a slab that drops out from under you sinks
## rather than snapping away, and you can watch it go while you jump.
@export var platform_fall_gravity: float = 1400.0
## Seconds a platform stays out of the room before it is back at home. A death
## puts every platform back at once, so this is only ever felt by somebody still
## alive: it is what turning round and going back costs.
@export var platform_return_time: float = 0.8
## How far the warning shake throws the slab sideways, in design px. Small: it
## is a tremor and not a wobble, and it has to read at 40 px without the slab
## appearing to leave its own socket.
@export var platform_shake: float = 1.5
## How fast that shake oscillates, in Hz. Fast enough to read as unstable rather
## than as something being moved on purpose.
@export var platform_shake_hz: float = 16.0
