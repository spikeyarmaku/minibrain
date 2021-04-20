extends Node2D

#enum PERM {CREATE_NODE, DELETE_NODE, DELETE_EDGE, CONNECT_NODES}

const Node = preload("res://Scenes/Editor/Node.tscn")
const Edge = preload("res://Scenes/Editor/Edge.tscn")

var input_nodes = []
var output_nodes = []

var nodes = []
var edges = []
#var perms = [PERM.CREATE_NODE, PERM.CONNECT_NODES, PERM.DELETE_EDGE,
#			 PERM.DELETE_NODE]

var connect_node : Control = null
var connect_to : Control = null
var connect_type

var drag = false

var viewport

func _ready():
	viewport = get_viewport()
	Global.get_camera_2d(viewport).position = Vector2(0, 0)

func set_inputs_outputs(strings):
	var input_strings = strings[0]
	var output_strings = strings[1]
	var in_v_step = viewport.size.y / (input_strings.size() + 1)
	var out_v_step = viewport.size.y / (output_strings.size() + 1)
	for i in input_strings.size():
		var pos_x = -viewport.size.x / 4
		var pos_y = -viewport.size.y / 2 + (i + 1) * in_v_step
		add_input_node(input_strings[i], Vector2(pos_x, pos_y))
	for i in output_strings.size():
		var pos_x = viewport.size.x / 8
		var pos_y = -viewport.size.y / 2 + (i + 1) * out_v_step
		add_output_node(output_strings[i], Vector2(pos_x, pos_y))

func add_input_node(label, position):
	var node = _add_node(position)
	node.set_input_only(label)
	input_nodes.append(node)
	return node
	
func add_output_node(label, position):
	var node = _add_node(position)
	node.set_output_only(label)
	output_nodes.append(node)
	return node

func _process(_delta):
	if connect_node != null and connect_type != null:
		update()

func _draw():
	if connect_node == null:
		return
	elif connect_to == null:
		draw_line( get_pin_position(connect_node, connect_type)
				 , get_local_mouse_position(), Color.from_hsv(0, 0, 0.4), 8 )
	else:
		var start_pin_pos = get_pin_position(connect_node, connect_type)
		var end_pin_pos = get_pin_position(connect_to,
			Global.invert_connect_type(connect_type))
		if start_pin_pos == null or end_pin_pos == null:
			return
		
		if connect_node == connect_to:
			var start = start_pin_pos
			var end = end_pin_pos
			var mid = (start + end) / 2 + Vector2(0, 150)
			var line1 = Global.make_bezier_line(mid, start)
			var line2 = Global.make_bezier_line(end, mid)
			draw_polyline(line1.points, Color.from_hsv(0, 0, 0.4), 8)
			draw_polyline(line2.points, Color.from_hsv(0, 0, 0.4), 8)
			line1.free()
			line2.free()
		else:
			draw_line(start_pin_pos, end_pin_pos, Color.from_hsv(0, 0, 0.4), 8)

func get_pin_position(node, conn_type):
	var pin
	if conn_type == Global.CONNECT_TYPE.INPUT_OUTPUT:
		pin = node.get_input_pin()
	else:
		pin = node.get_output_pin()
	if pin == null:
		return null
	else:
		return pin.rect_global_position + pin.rect_size / 2

func _add_node(position):
	var node = Node.instance()
	add_child(node)
	node.rect_size = Vector2(80, 80)
	node.set_position(position - node.rect_size / 2)
	node.connect("delete", self, "_on_node_delete", [node])
	node.connect("connect_request", self, "_on_connect_request", [node])
	node.connect("connect_request_end", self, "_on_connect_request_end")
	node.connect("hover", self, "_on_node_hover", [node])
	node.connect("hover_end", self, "_on_node_hover_end", [node])
	nodes.append(node)
	return node

# Checks if node1's output is connected to node2's input
func _can_nodes_connect(node1, node2):
	# Are they already connected? # NOTE - Bug Brain allows nodes to be
	# connected multiple times
#	for e in node1.outgoing_edges:
#		if e.end_node == node2:
#			return false
	# Do they have the right pins? (E.g. 2 input-only nodes can't be connected)
	if node1.get_output_pin() == null or node2.get_input_pin() == null:
		return false
	return true

func _connect_nodes(start_node, end_node):
	if not _can_nodes_connect(start_node, end_node):
		return
	var edge = Edge.instance()
	add_child(edge)
	edge.rect_size = Vector2(80, 80)
	if start_node == end_node:
		edge.rect_position = (start_node.rect_global_position + \
							  end_node.rect_global_position) / 2 + \
							 Vector2(0, 150)
	else:
		edge.rect_position = (start_node.rect_global_position + \
							  end_node.rect_global_position) / 2
	edge.start_node = start_node
	edge.end_node = end_node
	start_node.outgoing_edges.append(edge)
	end_node.incoming_edges.append(edge)
	edge.connect("delete", self, "_on_edge_delete", [edge])
	edges.append(edge)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.doubleclick \
		and event.button_index == BUTTON_LEFT:
		get_tree().set_input_as_handled()
		_add_node(Global.scr_to_vp(event.position, get_viewport()))

func _on_node_delete(node):
	if node.is_deletable:
		nodes.erase(node)
		node.destroy()

func _on_edge_delete(edge):
	edges.erase(edge)
	edge.destroy()

func _on_connect_request(conn_type, conn_node):
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

func calculate_outputs(inputs):
	var outputs = []
	for i in range(0, input_nodes.size()):
		input_nodes[i].set_input(inputs[i])
	for n in nodes:
		n.collect_input()
	for e in edges:
		e.collect_input()
	for n in nodes:
		n.update_value()
	for e in edges:
		e.update_value()
	for n in output_nodes:
		outputs.append(n.get_output())
	return outputs
