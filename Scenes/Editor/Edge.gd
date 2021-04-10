tool
extends Control

signal delete(edge)

const Global = preload("res://Global.gd")

var value = 0

var is_dragged = false
var drag_offset
var start_node : Control
var end_node : Control

func _ready():
	$Knob.type = Global.KNOB_TYPE.EDGE_KNOB
	$Knob.set_value(100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()

func _draw():
	var left_pos = rect_size / 2 - Vector2(rect_size.x / 2, 0)
	var right_pos = rect_size / 2 + Vector2(rect_size.x / 2, 0)
	var start_pos
	if start_node == null:
		start_pos = Vector2(0,0)
	else:
		var pin = start_node.get_output_pin()
		start_pos = pin.rect_global_position + pin.rect_size / 2
	var end_pos
	if end_node == null:
		end_pos = Vector2(0,0)
	else:
		var pin = end_node.get_input_pin()
		end_pos = pin.rect_global_position + pin.rect_size / 2
#		end_pos = end_node.rect_position + end_node.rect_size / 2
#	if start_point == null:
#		start_pos = get_global_mouse_position()
#	if end_point == null:
#		end_pos = get_global_mouse_position()
	var line1 : Line2D = Global.make_bezier_line(start_pos - rect_position, left_pos)
	var line2 : Line2D = Global.make_bezier_line(right_pos, end_pos - rect_position)
	draw_polyline(line1.points, Color.from_hsv(0, 0, 0.4), 8)
	draw_polyline(line2.points, Color.from_hsv(0, 0, 0.4), 8)
	line1.free()
	line2.free()

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and \
		event.doubleclick and event.button_index == BUTTON_LEFT:
		emit_signal("delete", self)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		is_dragged = event.pressed
		if is_dragged:
			drag_offset = get_local_mouse_position()
	elif is_dragged and event is InputEventMouseMotion:
		set_position(event.global_position - drag_offset)

func destroy():
	# Disconnect from nodes
	start_node.outgoing_edges.erase(self)
	end_node.incoming_edges.erase(self)
	queue_free()
