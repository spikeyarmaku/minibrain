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
		if connect_node == connect_to:
			var start = get_pin_position(connect_node, connect_type)
			var end = get_pin_position(connect_to,
				Global.invert_connect_type(connect_type))
			var mid = (start + end) / 2 + Vector2(0, 150)
			var line1 = Global.make_bezier_line(mid, start)
			var line2 = Global.make_bezier_line(end, mid)
			draw_polyline(line1.points, Color.from_hsv(0, 0, 0.4), 8)
			draw_polyline(line2.points, Color.from_hsv(0, 0, 0.4), 8)
		else:
			draw_line( get_pin_position(connect_node, connect_type)
					 , get_pin_position(
							connect_to,
							Global.invert_connect_type(connect_type))
					 , Color.from_hsv(0, 0, 0.4), 8 )

func get_pin_position(node, connect_type):
	var pin
	if connect_type == Global.CONNECT_TYPE.INPUT_OUTPUT:
		pin = node.get_output_pin()
	else:
		pin = node.get_input_pin()
	return pin.rect_global_position + pin.rect_size / 2

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

func _connect_nodes(start_node, end_node):
	var edge = Edge.instance()
	add_child(edge)
	edge.rect_size = Vector2(80, 80)
	edge.rect_position = (start_node.rect_global_position + \
						  end_node.rect_global_position) / 2
	edge.start_node = start_node
	edge.end_node = end_node
	start_node.outgoing_edges.append(edge)
	end_node.incoming_edges.append(edge)
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
	if connect_node != null and connect_to != null and connect_type != null:
		if connect_type == Global.CONNECT_TYPE.OUTPUT_INPUT:
			_connect_nodes(connect_node, connect_to)
		else:
			_connect_nodes(connect_to, connect_node)
	connect_node = null
	connect_type = null
	update()

func _on_node_hover(node):
	connect_to = node

func _on_node_hover_end(node):
	if connect_to == node:
		connect_to = null
