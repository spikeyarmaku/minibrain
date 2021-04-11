extends Control

const Node = preload("res://Scenes/Editor/Node.tscn")
const Edge = preload("res://Scenes/Editor/Edge.tscn")

var nodes = []
var edges = []

var connect_node : Control = null
var connect_to : Control = null
var connect_type

var drag = false

const zoom_factor = 1.2

func _ready():
	$Viewport/Camera2D.position = rect_size / 2
	set_inputs_outputs(["input1", "input2"], ["output1", "output2", "output3"])

func set_inputs_outputs(input_strings, output_strings):
	for i in input_strings.size():
		add_input_node(input_strings[i], Vector2(100, (i + 1) * 100))
	for i in output_strings.size():
		add_output_node(output_strings[i],
			Vector2(rect_size.x - 100, (i + 1) * 100))

func add_input_node(label, position):
	var node = _add_node(position)
	node.set_input_only(label)
	
func add_output_node(label, position):
	var node = _add_node(position)
	node.set_output_only(label)

func _process(delta):
	if connect_node != null and connect_type != null:
		update()

func _draw():
	if connect_node == null:
		return
	elif connect_to == null:
		draw_line( Global.vp_to_scr(get_pin_position(connect_node, connect_type), $Viewport)
				 , get_local_mouse_position(), Color.from_hsv(0, 0, 0.4), 8 )
	else:
		var start_pin_pos = get_pin_position(connect_node, connect_type)
		var end_pin_pos = get_pin_position(connect_to,
			Global.invert_connect_type(connect_type))
		if start_pin_pos == null or end_pin_pos == null:
			return
		
		if connect_node == connect_to:
			var start = Global.vp_to_scr(start_pin_pos, $Viewport)
			var end = Global.vp_to_scr(end_pin_pos, $Viewport)
			var mid = (start + end) / 2 + Vector2(0, 150)
			var line1 = Global.make_bezier_line(mid, start)
			var line2 = Global.make_bezier_line(end, mid)
			draw_polyline(line1.points, Color.from_hsv(0, 0, 0.4), 8)
			draw_polyline(line2.points, Color.from_hsv(0, 0, 0.4), 8)
			line1.free()
			line2.free()
		else:
			draw_line( Global.vp_to_scr(start_pin_pos, $Viewport)
					 , Global.vp_to_scr(end_pin_pos, $Viewport)
					 , Color.from_hsv(0, 0, 0.4), 8 )

func get_pin_position(node, connect_type):
	var pin
	if connect_type == Global.CONNECT_TYPE.INPUT_OUTPUT:
		pin = node.get_input_pin()
	else:
		pin = node.get_output_pin()
	if pin == null:
		return null
	else:
		return pin.rect_global_position + pin.rect_size / 2

func _add_node(position):
	var node = Node.instance()
	print("Add node")
	$Viewport.add_child(node)
	node.rect_size = Vector2(80, 80)
	node.set_position(position - node.rect_size / 2)
	node.connect("delete", self, "_on_node_delete")
	node.connect("connect_request", self, "_on_connect_request")
	node.connect("connect_request_end", self, "_on_connect_request_end")
	node.connect("hover", self, "_on_node_hover")
	node.connect("hover_end", self, "_on_node_hover_end")
	nodes.append(node)
	return node

# Checks if node1's output is connected to node2's input
func _can_nodes_connect(node1, node2):
	# Are they already connected?
	for e in node1.outgoing_edges:
		if e.end_node == node2:
			return false
	# Do they have the right pins? (E.g. 2 input-only nodes can't be connected)
	if node1.get_output_pin() == null or node2.get_input_pin() == null:
		return false
	return true

func _connect_nodes(start_node, end_node):
	if not _can_nodes_connect(start_node, end_node):
		return
	var edge = Edge.instance()
	$Viewport.add_child(edge)
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
	edge.connect("delete", self, "_on_edge_delete")
	edges.append(edge)
	
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.doubleclick \
		and event.button_index == BUTTON_LEFT:
		accept_event()
		_add_node(Global.scr_to_vp(event.position, $Viewport))
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed:
		drag = true
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and not event.pressed:
		drag = false
	elif drag and event is InputEventMouseMotion:
		$Viewport/Camera2D.position -= event.relative * $Viewport/Camera2D.zoom
		
func _input(event):
	if event is InputEventMouseButton and \
		event.button_index == BUTTON_WHEEL_UP:
		# TODO use a tween
		$Viewport/Camera2D.zoom /= zoom_factor
	elif event is InputEventMouseButton and \
		event.button_index == BUTTON_WHEEL_DOWN:
		# TODO use a tween
		$Viewport/Camera2D.zoom *= zoom_factor

# TODO
func _on_node_delete(node):
	if node.is_deletable:
		nodes.erase(node)
		node.destroy()

# TODO
func _on_edge_delete(edge):
	edges.erase(edge)
	edge.destroy()

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
