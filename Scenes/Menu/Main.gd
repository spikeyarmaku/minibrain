extends Control

var editor
var main_menu_node
var new_game_node
var settings_node
var quit_node

var active_node = ""

var menu_points = ["New\nGame", "Quit"]

# Called when the node enters the scene tree for the first time.
func _ready():
	editor = $Editor
	var camera = Global.get_camera_2d(get_viewport())
	camera.zoom *= 0.7
	editor.set_inputs_outputs([["Main\nMenu"], menu_points])
	main_menu_node = editor.input_nodes[0]
	for i in range(editor.output_nodes.size()):
		var n = editor.output_nodes[i]
		n.connect("gui_input", self, "_on_node_gui_input", [menu_points[i]])

func _on_node_gui_input(event, node_name):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
		and event.pressed:
		if node_name == menu_points[0]: # New game
			get_tree().change_scene("res://Scenes/Game.tscn")
		elif node_name == menu_points[1]: # Quit
			get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if editor.connect_node == null:
		editor.connect_node = main_menu_node
		editor.connect_type = Global.CONNECT_TYPE.OUTPUT_INPUT

