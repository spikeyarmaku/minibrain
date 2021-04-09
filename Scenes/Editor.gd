extends Control

const Node = preload("res://Scenes/Editor/Node.tscn")

var nodes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _add_node(position):
	var node = Node.instance()
	add_child(node)
	node.rect_size = Vector2(80, 80)
	node.set_position(position - node.rect_size / 2)
	node.connect("delete", self, "_on_node_delete")
	nodes.append(node)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.doubleclick \
		and event.button_index == BUTTON_LEFT:
		accept_event()
		_add_node(event.position)

# TODO
func _on_node_delete(node):
	nodes.erase(node)
	node.queue_free()
