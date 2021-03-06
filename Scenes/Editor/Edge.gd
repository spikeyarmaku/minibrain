tool
extends Control

signal delete()

const Global = preload("res://Global.gd")

var is_hover = false setget set_hover, get_hover
var is_dragged = false
var start_node : Control
var end_node : Control

var knob

func set_hover(h):
	is_hover = h
	if is_hover:
		knob.maximize()
	else:
		knob.minimize()
	
func get_hover():
	return is_hover

func _ready():
	knob = $EdgeKnob
	knob.set_weight(100)
	knob.set_decay(0)
	knob.rect_pivot_offset = knob.rect_size / 2
	set_hover(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	update()

func _draw():
	var left_pos = rect_size / 2 - Vector2(rect_size.x / 2, 0) * knob.rect_scale
	var right_pos = rect_size / 2 + Vector2(rect_size.x / 2, 0) * knob.rect_scale
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
		emit_signal("delete")
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		is_dragged = event.pressed
	elif is_dragged and event is InputEventMouseMotion:
		rect_position += event.relative
		update()

func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER:
		set_hover(true)
		update()
	elif what == NOTIFICATION_MOUSE_EXIT:
		set_hover(false)
		update()

func destroy():
	# Disconnect from nodes
	start_node.outgoing_edges.erase(self)
	end_node.incoming_edges.erase(self)
	queue_free()

func collect_input():
	var input_value = 0
	if start_node != null:
		input_value = start_node.get_output()
	knob.set_input_value(clamp(input_value, -100.0, 100.0))

# Reads the input node's value, and updates its own accordingly
func update_value(delta):
	knob.update_value(delta)

func get_output():
	return knob.output_value
