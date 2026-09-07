## Base for every test file. Collects failures rather than aborting, so one bad
## number does not hide the other nineteen.
class_name TestCase
extends RefCounted

var failures: PackedStringArray = []
var checks: int = 0


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func check_eq(actual: Variant, expected: Variant, message: String) -> void:
	checks += 1
	if actual != expected:
		failures.append("%s (got %s, wanted %s)" % [message, actual, expected])


func check_near(actual: float, expected: float, tolerance: float, message: String) -> void:
	checks += 1
	if absf(actual - expected) > tolerance:
		failures.append("%s (got %.4f, wanted %.4f +/- %.4f)" % [
			message, actual, expected, tolerance
		])
