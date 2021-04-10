extends Control

const Node = preload("res://Scenes/Editor/Node.tscn")
const Edge = preload("res://Scenes/Editor/Edge.tscn")

var nodes = []
var edges = []

var connect_node : Control = null
var connect_to : Control = null
var connect_type

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if connect_node != null and connect_type != null:
		update()

func _draw():
	if connect_node == null:
		return
	elif connect_to == null:
		draw_line( get_pin_position(connect_node, connect_type)
				 , get_local_mouse_position(), Color.from_hsv(0, 0, 0.4), 8 )
	else:
		draw_line( get_pin_position(connect_node, connect_type)
				 , get_pin_position( connect_to
								   , Global.invert_connect_type(connect_type) )
				 , Color.from_hsv(0, 0, 0.4), 8 )

func get_pin_position(node, connect_type):
	var pin
	if connect_type == Global.CONNECT_TYPE.INPUT_OUTPUT:
		pin = node.get_node("RightPinContainer")
	else:
		pin = node.get_node("LeftPinContainer")
	return node.rect_position + pin.rect_position + pin.rect_size / 2

func _add_node(position):
	var node = Node.instance()
	add_child(node)
	node.rect_size = Vector2(80, 80)
	node.set_position(position - node.rect_size / 2)
	node.connect("delete", self, "_on_node_delete")
	node.connect("connect_request", self, "_on_connect_request")
	node.connect("connect_request_end", self, "_on_connect_request_end")
	node.connect("hover", self, "_on_node_hover")
	node.connect("hover_end", self, "_on_node_hover_end")
	nodes.append(node)

func _connect_nodes(node1, node2):
	var edge = Edge.instance()
	add_child(edge)
	edge.start_pin = node1.get_node("RightPinContainer/Pin")
	edge.end_point = node2.get_node("LeftPinContainer/Pin")
	edge.rect_size = Vector2(80, 80)
	edge.rect_position = (edge.start_pin.rect_position + \
						 edge.start_pin.rect_size / 2 + \
						 edge.end_pin.rect_position + \
						 edge.start_pin.rect_size / 2) / 2 + \
	edge.connect("delete", self, "_on_edge_delete")
	edges.append(edge)
	
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.doubleclick \
		and event.button_index == BUTTON_LEFT:
		accept_event()
		_add_node(event.position)

# TODO
func _on_node_delete(node):
	nodes.erase(node)
	node.queue_free()

# TODO
func _on_edge_delete(edge):
	edges.erase(edge)
	edge.queue_free()

func _on_connect_request(conn_node, conn_type):
	connect_node = conn_node
	connect_type = conn_type

func _on_connect_request_end():
	connect_node = null
	connect_type = null
	update()

func _on_node_hover(node):
	connect_to = node
	
func _on_node_hover_end(node):
	if connect_to == node:
		connect_to = null
