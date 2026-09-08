## The instrument panel for M0. Every number on it is one you are about to make
## a decision with, and it exists because "that felt like it cleared the tier"
## and "that cleared the tier" are different claims.
extends CanvasLayer

const LEGEND: PackedStringArray = [
	"A/D move   Space jump   J throw   W/S ladders",
	"Tab preset   [ ] hero size   R respawn   F1 hide   F2 bench",
]

## The Phase 1 instruments, in order. These are benches and not game rooms: the
## real ones in Phase 3 are sequenced by act state in an autoload, and no room
## ever names another (CLAUDE.md).
const BENCHES: PackedStringArray = [
	"res://scenes/rooms/room_m0.tscn",
	"res://scenes/rooms/room_m1.tscn",
]

@onready var _panel: PanelContainer = $Panel
@onready var _label: Label = $Panel/Margin/Label

var _player: Player
var _world: WorldConfig


func _ready() -> void:
	var found := get_tree().get_first_node_in_group("player")
	_player = found as Player
	if _player != null:
		_world = _player.world
	var style := StyleBoxFlat.new()
	# STONE_DEEP over BACKDROP, because a panel the colour of the room it sits on
	# is not a panel. Found by looking at a screenshot, not by a test.
	style.bg_color = Color(Palette.STONE_DEEP, 0.92)
	style.border_color = Color(Palette.STONE_MID, 0.9)
	style.set_border_width_all(1)
	style.set_content_margin_all(4.0)
	_panel.add_theme_stylebox_override("panel", style)
	_label.add_theme_color_override("font_color", Palette.FIRE_HOT)
	_label.add_theme_font_size_override("font_size", 7)


func _cycle_bench() -> void:
	var here := get_tree().current_scene.scene_file_path
	var index := BENCHES.find(here)
	get_tree().change_scene_to_file(BENCHES[(index + 1) % BENCHES.size()])


## What every sword on screen is doing, which is the whole instrument for M1.
func _swords_in_play() -> String:
	var states: PackedStringArray = []
	for node in get_tree().get_nodes_in_group("swords"):
		var sword := node as Sword
		if sword != null:
			states.append(SwordFlight.state_name(sword.state))
	if states.is_empty():
		return "none in play"
	return ", ".join(states)


func _state_of(player: Player) -> String:
	if player.climbing:
		return "climbing"
	return "on floor" if player.is_on_floor() else "airborne"


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_next_bench"):
		_cycle_bench()
		return
	if Input.is_action_just_pressed("debug_toggle_overlay"):
		_panel.visible = not _panel.visible
	if _player == null or not _panel.visible:
		return

	var config := _player.config
	var gravity := Motion.gravity_for(config.jump_height, config.time_to_apex)
	var takeoff := Motion.jump_speed_for(
		config.jump_height, config.time_to_apex, get_physics_process_delta_time()
	)
	var cleared := "clears a tier" if _player.peak_height >= _world.tier_height else "short of a tier"

	_label.text = "\n".join([
		"preset      %s   (jump %.0f px in %.2f s)" % [
			config.preset_name, config.jump_height, config.time_to_apex
		],
		"derived     gravity %.0f px/s^2   takeoff %.0f px/s" % [gravity, takeoff],
		"hero        %.0f x %.0f px   tier %.0f px" % [
			_world.hero_width, _world.hero_height, _world.tier_height
		],
		"velocity    %6.0f, %6.0f   %s" % [
			_player.velocity.x, _player.velocity.y,
			_state_of(_player)
		],
		"last jump   %.0f px apex   %s" % [_player.peak_height, cleared],
		"swords      %d held   %s" % [_player.swords_held, _swords_in_play()],
		"fps         %d" % Engine.get_frames_per_second(),
		"",
	] + Array(LEGEND))
