extends Control

var big_vp
var small_vp
var level
var editor

# Called when the node enters the scene tree for the first time.
func _ready():
	big_vp = $BigViewport/Viewport
	small_vp = $SmallViewport/Viewport
	Global.get_camera_2d(small_vp).zoom *= 4
	# --
	level = $SmallViewport/Viewport/Agar
	editor = $BigViewport/Viewport/Editor
	editor.set_inputs_outputs(level.define_inputs_outputs())

func _process(_delta):
	var inputs = level.provide_inputs()
	var outputs = editor.calculate_outputs(inputs)
	level.receive_outputs(outputs)

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

func _on_SmallViewport_gui_input(event):
	if event is InputEventMouseButton and event.pressed and \
		event.button_index == BUTTON_LEFT:
		swap_viewports()

# Workaround for https://github.com/godotengine/godot/issues/26181
# Also mentioned in https://github.com/godotengine/godot/issues/17326
func _on_BigViewport_gui_input(event):
	$BigViewport/Viewport.unhandled_input(event)

