extends Control

var editor
var menu_title_node

var active_node = ""

var menu_points = ["Campaign", "Custom", "Go\nback"]

# Called when the node enters the scene tree for the first time.
func _ready():
	editor = $Editor
	var camera = Global.get_camera_2d(get_viewport())
	camera.zoom *= 0.7
	editor.set_inputs_outputs_as_menu([["Select\nMission"], menu_points])
	editor.set_menu_mode()
	menu_title_node = editor.input_nodes[0]
	for i in range(editor.output_nodes.size()):
		var n = editor.output_nodes[i]
		n.connect("gui_input", self, "_on_node_gui_input", [menu_points[i]])

func _on_node_gui_input(event, node_name):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
		and event.pressed:
		if node_name == menu_points[0]: # Campaign
			get_tree().change_scene("res://Scenes/Menu/CampaignMissionSelector.tscn")
		elif node_name == menu_points[1]: # Custom
			get_tree().change_scene("res://Scenes/Menu/CustomMissionSelector.tscn")
		else: # Go back
			get_tree().change_scene("res://Scenes/Menu/Main.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if editor.connect_node == null:
		editor.connect_node = menu_title_node
		editor.connect_type = Global.CONNECT_TYPE.OUTPUT_INPUT

func _input(event):
	if event is InputEventKey and event.scancode == KEY_ESCAPE and \
	event.pressed:
		get_tree().set_input_as_handled()
		get_tree().change_scene("res://Scenes/Menu/Main.tscn")
