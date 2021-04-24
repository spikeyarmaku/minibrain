# TODO
# - reset brain state

extends Control

var level_blueprint

var big_vpc : ViewportContainer
var small_vpc : ViewportContainer
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
	big_vpc = $MissionViewport
	small_vpc = $EditorViewport
	big_vpc.connect("gui_input", self, "_on_BigViewport_gui_input")
	small_vpc.connect("gui_input", self, "_on_SmallViewport_gui_input")
	editor = $EditorViewport/Viewport/Editor
	Global.get_camera_2d(editor.get_parent()).zoom *= 4
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

func load_level(blueprint):
	level = blueprint.instance()
	var camera = movable_camera.instance()
	level.add_child(camera)
	camera.current = true
	if not level.is_single_screen:
		camera.can_move = true
	level.connect("completed", self, "_on_level_completed")
	$MissionViewport/Viewport.add_child(level)
	if editor.get_parent().get_parent() == big_vpc:
		camera.zoom *= 4

func _on_level_completed(success):
	is_completed = true
	if success:
		Global.current_mission += 1
	else:
		$CenterContainer/PanelContainer/RichTextLabel.bbcode_text = \
			"[center]FAILED[/center]"
	$CenterContainer.visible = true
	var timer = get_tree().create_timer(2)
	timer.connect("timeout", self, "_on_timer_timeout")
	
func _on_timer_timeout():
	if Global.current_mission == Global.missions.size():
		get_tree().change_scene("res://Scenes/Menu/Main.tscn")
	else:
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
	big_vpc.disconnect("gui_input", self, "_on_BigViewport_gui_input")
	small_vpc.disconnect("gui_input", self, "_on_SmallViewport_gui_input")
	var temp = small_vpc
	small_vpc = big_vpc
	big_vpc = temp
	var temp_anchor_left = small_vpc.anchor_left
	var temp_anchor_top = small_vpc.anchor_top
	small_vpc.anchor_left = big_vpc.anchor_left
	small_vpc.anchor_top = big_vpc.anchor_top
	big_vpc.anchor_left = temp_anchor_left
	big_vpc.anchor_top = temp_anchor_top
	Global.get_camera_2d(big_vpc).zoom *= 0.25
	Global.get_camera_2d(small_vpc).zoom *= 4
	big_vpc.get_node("Viewport").gui_disable_input = false
	small_vpc.get_node("Viewport").gui_disable_input = true
	big_vpc.connect("gui_input", self, "_on_BigViewport_gui_input")
	small_vpc.connect("gui_input", self, "_on_SmallViewport_gui_input")
	move_child(big_vpc, 0)

func _on_exit_pressed():
	queue_free()
	get_tree().change_scene("res://Scenes/Menu/Main.tscn")

func _process(_delta):
	var mouse_pos = get_local_mouse_position()
	var is_mouse_in_small_vp = small_vpc.get_rect().has_point(mouse_pos)
	
	# Workaround for https://github.com/godotengine/godot/issues/43284
	var big_vp = big_vpc.get_node("Viewport")
	big_vp.set_process_input(not is_mouse_in_small_vp)
	
	if is_mouse_in_small_vp:
		small_vpc.modulate = Color(1, 1, 1, 1)
	else:
		small_vpc.modulate = Color(1, 1, 1, 0.4)

func _on_SmallViewport_gui_input(event):
	if event is InputEventMouseButton and event.pressed and \
		event.button_index == BUTTON_LEFT:
		swap_viewports()

# Workaround for https://github.com/godotengine/godot/issues/26181
# Also mentioned in https://github.com/godotengine/godot/issues/17326
func _on_BigViewport_gui_input(event):
	big_vpc.get_node("Viewport").unhandled_input(event)
