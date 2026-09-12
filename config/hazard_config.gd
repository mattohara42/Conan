## Every number a hazard's shape is made of.
##
## CLAUDE.md puts hazard tuning in `config/`, and a spike bed has one number
## that decides how the game feels: `spike_grace`, the depth you can sink into
## the points and live. Getting that wrong is the difference between a hazard
## that is hard and one that is unfair, and it is not something a script gets
## to hold.
##
## Lava is not here. Lava is a rectangle a room hands to `Hazard` and it has no
## shape of its own to tune. Geysers and platforms will want rows of their own
## and they can be added when they exist.
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
