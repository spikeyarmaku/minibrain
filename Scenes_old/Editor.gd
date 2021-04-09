extends Node2D

const Node = preload("res://Scenes/Editor/Node.tscn")
const _node_radius = 40

var next_node_id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
#	pass # Replace with function body.
	_add_node(Vector2(100, 100))
	_add_node(Vector2(300, 100))
	_add_node(Vector2(100, 200))
	_add_node(Vector2(300, 200))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _add_node(pos):
	var node = Node.instance()
	node.init(next_node_id, _node_radius)
	node.position = pos
	next_node_id += 1
	add_child(node)

func _serialize_brain():
	pass
	# serialize nodes:
	# - position, value, connected edge ids
	# serialize edges
	# - knob_position, knob_value, start_node, end_node

func _run_brain(_inputs):
	pass
