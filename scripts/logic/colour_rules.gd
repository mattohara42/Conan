## The one rule from ART_DIRECTION.md that can be checked by a machine:
## every dark is a coloured dark, and there is no neutral black or grey anywhere.
##
## It lives here rather than in a script tool because it applies to colours the
## code chooses (shaders, particles, UI, placeholder geometry) as much as to
## colours a generator paints.
class_name ColourRules

## Below this luminance a colour counts as a dark and has to justify itself.
const DARK_LUMINANCE_CEILING: float = 0.15
## A dark under this saturation is a neutral, which the direction forbids.
const MIN_DARK_SATURATION: float = 0.12


## Rec. 709 relative luminance.
static func luminance(colour: Color) -> float:
	return 0.2126 * colour.r + 0.7152 * colour.g + 0.0722 * colour.b


## True when the colour is a legal choice under ART_DIRECTION.md. Colours above
## the dark ceiling are unconstrained by this rule; darks must carry hue.
static func is_legal(colour: Color) -> bool:
	if luminance(colour) >= DARK_LUMINANCE_CEILING:
		return true
	return colour.s >= MIN_DARK_SATURATION


## Why a colour failed, for a test that should say more than "false".
static func explain(colour: Color) -> String:
	if is_legal(colour):
		return ""
	return "%s is a neutral dark: luminance %.3f, saturation %.3f" % [
		colour.to_html(false), luminance(colour), colour.s
	]
