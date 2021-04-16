extends Control

var editor
var main_menu_node

# Called when the node enters the scene tree for the first time.
func _ready():
	editor = $Editor
	editor.center_camera()
	editor.set_zoom_level(0.7)
	main_menu_node = editor.add_input_node("Main\nMenu", Vector2(2 * rect_size.x / 8, rect_size.y / 2))
	editor.add_output_node("Tutorial",  Vector2(3 * rect_size.x / 5, 2 * rect_size.y / 6))
	editor.add_output_node("New\nGame", Vector2(3 * rect_size.x / 5, 3 * rect_size.y / 6))
	editor.add_output_node("Quit",      Vector2(3 * rect_size.x / 5, 4 * rect_size.y / 6))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if editor.connect_node == null:
		editor.connect_node = main_menu_node
		editor.connect_type = Global.CONNECT_TYPE.OUTPUT_INPUT
