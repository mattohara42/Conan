## Takes a screenshot of a scene from a real running build.
##
## CLAUDE.md: an assertion proves the code ran, not that the picture is right,
## so draw the thing you measured. This is how that gets done in Godot without
## a human at a keyboard, and it is what CI and a headless session use to look
## at the game.
##
## Needs a display. Headless gives you a dummy renderer and a blank image, so
## run it under Xvfb:
##
##   xvfb-run -a godot --path . --script res://tools/capture.gd -- \
##       --scene=res://scenes/rooms/room_m0.tscn --out=shot.png \
##       --input="move_right:70;climb_up:80"
##
## `--input` is a sequence of phases, each naming every action held during it
## and how many frames it lasts. An action listed in one phase and not the next
## is released, so "move_right:70;climb_up:80" runs right and then climbs. What
## is still held after the last phase stays held, which is what `--until-apex`
## needs to measure a running jump.
##
## A phase named `-` holds nothing, which is how you wait for something the game
## is doing on its own: "move_left:10;throw:6;-:45" faces left, throws, and then
## lets go while the sword flies. Letting go matters, because an action held too
## long is a different action: a held throw is a recall.
##
## Writing over an existing file is the flag, not the default.
extends SceneTree

const SETTLE_FRAMES := 12
## The phase name that means "hold nothing".
const NOTHING_HELD := "-"

var _scene_path := ""
var _out_path := ""
var _phases: Array[Dictionary] = []
var _until_apex := false
var _overwrite := false
var _zoom := 0.0
var _centre := Vector2.INF


func _initialize() -> void:
	_parse_arguments()
	if _scene_path.is_empty() or _out_path.is_empty():
		printerr("capture: --scene and --out are both required")
		quit(2)
		return
	if FileAccess.file_exists(_out_path) and not _overwrite:
		printerr("capture: %s exists. Pass --overwrite to replace it." % _out_path)
		quit(2)
		return

	var packed := load(_scene_path) as PackedScene
	if packed == null:
		printerr("capture: cannot load %s" % _scene_path)
		quit(2)
		return

	root.add_child(packed.instantiate())
	var agent := CaptureAgent.new()
	agent.configure(_out_path, _phases, _until_apex, _zoom, _centre)
	root.add_child(agent)


func _parse_arguments() -> void:
	for argument in OS.get_cmdline_user_args():
		var value := argument.get_slice("=", 1)
		if argument.begins_with("--scene="):
			_scene_path = value
		elif argument.begins_with("--out="):
			_out_path = value
		elif argument.begins_with("--input="):
			_phases = _parse_phases(value)
		elif argument.begins_with("--zoom="):
			_zoom = value.to_float()
		elif argument.begins_with("--centre="):
			var parts := value.split(",", false)
			if parts.size() == 2:
				_centre = Vector2(parts[0].to_float(), parts[1].to_float())
		elif argument == "--until-apex":
			_until_apex = true
		elif argument == "--overwrite":
			_overwrite = true


## "move_right:70;climb_up:80" becomes two phases of held actions and durations.
func _parse_phases(text: String) -> Array[Dictionary]:
	var phases: Array[Dictionary] = []
	for chunk in text.split(";", false):
		var parts := chunk.split(":", false)
		if parts.size() != 2:
			printerr("capture: cannot read input phase \"%s\"" % chunk)
			continue
		# `-` is the empty controller, not an action called "-".
		var actions := PackedStringArray()
		if parts[0] != NOTHING_HELD:
			actions = parts[0].split(",", false)
		phases.append({
			"actions": actions,
			"frames": parts[1].to_int(),
		})
	return phases


## Runs inside the tree, because waiting for a drawn frame needs a node.
class CaptureAgent:
	extends Node

	var _out_path := ""
	var _phases: Array[Dictionary] = []
	var _held: PackedStringArray = []
	var _until_apex := false
	var _zoom := 0.0
	var _centre := Vector2.INF

	func configure(
		out_path: String, phases: Array[Dictionary], until_apex: bool, zoom: float,
		centre: Vector2
	) -> void:
		_out_path = out_path
		_phases = phases
		_until_apex = until_apex
		_zoom = zoom
		_centre = centre

	func _ready() -> void:
		if _zoom > 0.0 or _centre.is_finite():
			_pull_the_camera_back()
		await _wait(SETTLE_FRAMES)
		for phase in _phases:
			_hold_exactly(phase["actions"])
			await _wait(phase["frames"])

		var player := get_tree().get_first_node_in_group("player")
		if _until_apex and player != null:
			# Held, not tapped. Releasing early is what variable jump height
			# means, and it produces a hop rather than the jump being measured.
			Input.action_press("jump")
			var guard := 0
			while player.velocity.y >= 0.0 and guard < 30:
				guard += 1
				await get_tree().physics_frame
			# The apex is the frame the sign of vertical velocity flips back.
			while player.velocity.y < 0.0 and guard < 240:
				guard += 1
				await get_tree().physics_frame
			Input.action_release("jump")

		if player != null:
			print("capture: player at %s, peak %.1f px" % [player.global_position, player.peak_height])

		await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image()
		var error := image.save_png(_out_path)
		_hold_exactly(PackedStringArray())
		if error != OK:
			printerr("capture: could not write %s (%d)" % [_out_path, error])
			get_tree().quit(1)
			return
		print("capture: wrote %s at %dx%d" % [_out_path, image.get_width(), image.get_height()])
		get_tree().quit(0)

	## Presses what this phase wants and releases what it does not, so a phase
	## describes a state of the controller rather than a set of key presses.
	func _hold_exactly(actions: PackedStringArray) -> void:
		for action in _held:
			if not actions.has(action):
				Input.action_release(action)
		for action in actions:
			if not _held.has(action):
				Input.action_press(action)
		_held = actions

	## Frames the whole room in one picture, for checking a layout rather than a
	## moment. Limits go with the zoom, or the camera clamps to the play area.
	func _pull_the_camera_back() -> void:
		for node in get_tree().get_nodes_in_group("player"):
			for child in node.get_children():
				var camera := child as Camera2D
				if camera == null:
					continue
				if _zoom > 0.0:
					camera.zoom = Vector2(_zoom, _zoom)
				camera.position_smoothing_enabled = false
				camera.limit_left = -100000
				camera.limit_top = -100000
				camera.limit_right = 100000
				camera.limit_bottom = 100000
				if _centre.is_finite():
					# Off the player, so an overview frames the room and not
					# wherever the player happens to be standing.
					camera.top_level = true
					camera.global_position = _centre

	## Physics frames, not render frames. Rendering runs uncapped and faster than
	## 60 Hz here, so counting drawn frames makes a scripted run travel a
	## different distance every time the machine changes speed.
	func _wait(frames: int) -> void:
		for i in frames:
			await get_tree().physics_frame
