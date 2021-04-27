extends Control

var editor
var menu_title_node

var active_node = ""

var menu_points = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for m in Global.missions:
		menu_points.append(m[0])
	menu_points.append("Go\nback")
	editor = $Editor
	var camera = Global.get_camera_2d(get_viewport())
#	camera.zoom *= 0.7
	editor.set_inputs_outputs_as_menu([["Select\nMission"], menu_points])
	editor.set_menu_mode()
	menu_title_node = editor.input_nodes[0]
	for i in range(editor.output_nodes.size()):
		var n = editor.output_nodes[i]
		n.connect("gui_input", self, "_on_node_gui_input", [i])

func _on_node_gui_input(event, node_index):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
		and event.pressed:
		if node_index == menu_points.size() - 1: # Go back
			get_tree().change_scene("res://Scenes/Menu/MissionSelector.tscn")
		else:
			Global.current_mission = node_index
#			var game_instance = game.instance()
#			game_instance.set_level(Global.missions[node_name])
#			get_tree().get_root().add_child(game_instance)
#			queue_free()
			get_tree().change_scene("res://Scenes/Game.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if editor.connect_node == null:
		editor.connect_node = menu_title_node
		editor.connect_type = Global.CONNECT_TYPE.OUTPUT_INPUT

