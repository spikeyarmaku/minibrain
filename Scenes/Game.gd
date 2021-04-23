# TODO
# - reset brain state

extends Control

var level_blueprint

var big_vp : Viewport
var small_vp : Viewport
var level
var editor
var control_panel
var btn_exit : TextureButton

var simulation_delta = 0

var is_running = false
var is_completed = false

var movable_camera = preload("res://Scenes/MovableCamera.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	big_vp = $BigViewport/Viewport
	small_vp = $SmallViewport/Viewport
	editor = $BigViewport/Viewport/Editor
	# --
	level_blueprint = Global.missions[Global.current_mission][1]
	load_level(level_blueprint)
	editor.set_inputs_outputs(level.define_inputs_outputs())
	# --
	btn_exit = $ButtonExit
	btn_exit.material.set_shader_param("btn_color", Color(1, 0.25, 0.25, 1))
	btn_exit.connect("pressed", self, "_on_exit_pressed")
	control_panel = $ControlPanel
	control_panel.connect("reset", self, "_on_reset")
	control_panel.connect("play", self, "_on_play")
	control_panel.connect("pause", self, "_on_pause")
	control_panel.connect("step", self, "_on_step")
	# --
	_on_pause()

func load_level(level_blueprint):
	level = level_blueprint.instance()
	var camera = movable_camera.instance()
	level.add_child(camera)
	camera.current = true
	if not level.is_single_screen:
		camera.can_move = true
	level.connect("completed", self, "_on_level_completed")
	if editor.get_parent() == big_vp:
		small_vp.add_child(level)
		camera.zoom *= 4
	else:
		big_vp.add_child(level)

func _on_level_completed(success):
	is_completed = true
	if success:
		Global.current_mission += 1
	else:
		$CenterContainer/PanelContainer/RichTextLabel.bbcode_text = \
			"[center]FAILED[/center]"
	$CenterContainer.visible = true
	var timer = get_tree().create_timer(3)
	timer.connect("timeout", self, "_on_timer_timeout")
	
func _on_timer_timeout():
	get_tree().change_scene("res://Scenes/Game.tscn")

func _on_reset():
	if level.has_method("reset"):
		level.reset()
	else:
		level.get_parent().remove_child(level)
		level.queue_free()
		load_level(level_blueprint)

func _on_play():
	is_running = true
	control_panel.set_running()

func _on_pause():
	is_running = false
	control_panel.set_paused()

func _on_step():
	step()

func _physics_process(delta):
	simulation_delta = delta
	if is_running and not is_completed:
		step()
		level.step(simulation_delta)

func step():
	var inputs = level.provide_inputs()
	var outputs = editor.calculate_outputs(inputs, simulation_delta)
	level.receive_outputs(outputs)
	level.step(simulation_delta)

func swap_viewports():
	var big_vp_viewport = big_vp.get_child(0)
	var small_vp_viewport = small_vp.get_child(0)
	big_vp.remove_child(big_vp_viewport)
	small_vp.add_child(big_vp_viewport)
	big_vp_viewport.set_owner(small_vp)
	small_vp.remove_child(small_vp_viewport)
	big_vp.add_child(small_vp_viewport)
	small_vp_viewport.set_owner(big_vp)
	Global.get_camera_2d(big_vp).zoom *= 0.25
	Global.get_camera_2d(small_vp).zoom *= 4

func _on_exit_pressed():
	queue_free()
	get_tree().change_scene("res://Scenes/Menu/Main.tscn")

func _on_SmallViewport_gui_input(event):
	if event is InputEventMouseButton and event.pressed and \
		event.button_index == BUTTON_LEFT:
		swap_viewports()

# Workaround for https://github.com/godotengine/godot/issues/26181
# Also mentioned in https://github.com/godotengine/godot/issues/17326
func _on_BigViewport_gui_input(event):
	$BigViewport/Viewport.unhandled_input(event)
