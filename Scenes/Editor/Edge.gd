tool
extends Control

signal delete(edge)

const Global = preload("res://Global.gd")

var value = 0

var is_dragged = false
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
		if pin == null:
			start_pos = Vector2(0, 0)
		else:
			start_pos = pin.rect_global_position + pin.rect_size / 2
	var end_pos
	if end_node == null:
		end_pos = Vector2(0,0)
	else:
		var pin = end_node.get_input_pin()
		if pin == null:
			end_pos = Vector2(0,0)
		else:
			end_pos = pin.rect_global_position + pin.rect_size / 2
	Global.curve_line($LeftLine, start_pos - rect_position, left_pos)
	$LeftLine.default_color = Color.from_hsv(0, 0, 0.4)
	Global.curve_line($RightLine, right_pos, end_pos - rect_position)
	$RightLine.default_color = Color.from_hsv(0, 0, 0.4)
	Global.curve_line($LeftOutline, start_pos - rect_position, left_pos)
	$LeftOutline.default_color = Color.from_hsv(0, 0, 0.2)
	Global.curve_line($RightOutline, right_pos, end_pos - rect_position)
	$RightOutline.default_color = Color.from_hsv(0, 0, 0.2)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and \
		event.doubleclick and event.button_index == BUTTON_LEFT:
		emit_signal("delete", self)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		is_dragged = event.pressed
	elif is_dragged and event is InputEventMouseMotion:
		rect_position += event.relative

func destroy():
	# Disconnect from nodes
	start_node.outgoing_edges.erase(self)
	end_node.incoming_edges.erase(self)
	queue_free()
