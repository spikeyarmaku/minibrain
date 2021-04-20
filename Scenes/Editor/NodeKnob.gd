tool
extends Control

# Perceptron logic
enum ACTIVATION_FUNCTION {STEP, LINEAR}
var is_disabled = false
var _input_value = 0 setget set_input_value, get_input_value
var _func_type = ACTIVATION_FUNCTION.STEP
var _bias = 0 setget set_bias, get_bias
var output_value = 0 # The current output value of the node
var _prev_output_value = 0

# Hides user-set bias lables, and shows actual values
var simulation_mode = false setget set_simulation_mode, get_simulation_mode

# Display
var node_type
var _color_node : Color = Color.from_hsv(0, 0, 0.2)
var _color_knob : Color = Color.from_hsv(0, 0, 0.4)
var _color_knob_input_positive : Color = Color(0, 0.4, 0)
var _color_knob_input_negative : Color = Color(0.4, 0, 0)
var _color_knob_output_positive : Color = Color(0, 0.4, 0)
var _color_knob_output_negative : Color = Color(0.4, 0, 0)
var _color_outline : Color = Color.from_hsv(0, 0, 0.15)
const _outline_width = 2

var label_text
var label_bias
var is_knob_active = false
var knob_mouse_pos
var radius = 10
var center = Vector2(0,0)

func set_simulation_mode(s):
	label_text.visible = s
	label_bias.visible = not s

func get_simulation_mode():
	return simulation_mode

# For input and output nodes
func label_and_disable(label):
	var color = Color.from_hsv(0, 0, 0.8)
	label_text.bbcode_text = \
			"[center][color=#" + color.to_html() + "]" + label + \
			"[/color][/center]"
	label_text.theme.default_font.size = 2 * radius / 5
	is_disabled = true
	label_text.visible = true
	label_bias.visible = false

func set_bias(b):
	_bias = min(max(-100, b), 100)
	update()

func get_bias():
	return int(round(_bias))

func set_input_value(i):
	_input_value = i
	update()

func get_input_value():
	return _input_value

func incr_bias(by_val):
	set_bias(_bias + by_val)

func _switch_func_type():
	if _func_type == ACTIVATION_FUNCTION.LINEAR:
		_func_type = ACTIVATION_FUNCTION.STEP
	else:
		_func_type = ACTIVATION_FUNCTION.LINEAR
	update()

func _ready():
	label_bias = $LabelBias
	label_text = $LabelText
	label_text.visible = false
	recalculate_size()

#func _process(_delta):
#	update_value()

func recalculate_size():
	radius = min(rect_size.x / 2, rect_size.y / 2)
	center = rect_size / 2
	update()

func _draw():
	_draw_body()
	if node_type == Global.NODE_TYPE.INPUT_OUTPUT_NODE:
		_draw_knob()
		_draw_func_type()
		var color
		if get_bias() == 0:
			color = Color.from_hsv(0, 0, 0.8)
		elif get_bias() > 0:
			color = Color(0, 1, 0)
		else:
			color = Color(1, 0, 0)
		label_bias.theme.default_font.size = 2 * radius / 5
		label_bias.bbcode_text = \
			"[center][color=#" + color.to_html() + "]" + str(get_bias()) + \
			"[/color][/center]"
	elif node_type == Global.NODE_TYPE.INPUT_NODE:
		_draw_output()
	else:
		_draw_input()

func _draw_body():
	# outline
	draw_circle(center, radius + _outline_width, _color_outline)
	# base
	draw_circle(center, radius, _color_node)

func _draw_knob():
	var input_first = get_input_value() >= get_bias()
	if input_first:
		_draw_input()
	draw_bias()
	if not input_first:
		_draw_input()
	_draw_output()
	draw_line(Vector2(0, -radius) + center, Vector2(0, radius) + center, \
			 _color_outline, 4)

func draw_bias():
	var angle = get_bias() / 100.0
	draw_circle_sector(center, radius, -3 * PI / 2, -(2 - angle) * PI / 2, _color_knob)

func _draw_input():
	var angle = get_input_value() / 100
	var color = _color_knob_input_positive
	if get_input_value() < 0:
		color = _color_knob_input_negative
	draw_circle_sector(center, radius, PI, (2 + angle) * PI / 2, color)

func _draw_output():
	var angle = output_value / 100
	var color = _color_knob_output_positive
	if output_value < 0:
		color = _color_knob_output_negative
	draw_circle_sector(center, radius, 0, -angle * PI / 2, color)

func _draw_func_type():
	var color = Color.from_hsv(0, 0, 0.4)
	var points = PoolVector2Array()
	points.append(center + Vector2(radius / 8, radius / 4))
	if _func_type == ACTIVATION_FUNCTION.STEP:
		points.append(center + Vector2(3 * radius / 8, radius / 4))
		points.append(center + Vector2(3 * radius / 8, -radius / 4))
	points.append(center + Vector2(5 * radius / 8, -radius / 4))
	draw_polyline(points, color, 5)

func draw_circle_sector(circle_center, r, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to-angle_from) / nb_points
		points_arc.push_back(circle_center + Vector2(cos(angle_point), sin(angle_point)) * r)
	points_arc.push_back(circle_center)
	draw_colored_polygon(points_arc, color)

func _gui_input(event):
	if is_disabled:
		return
	# Reset the knob by double right-clicking
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed and event.doubleclick and \
		event.position.x < rect_size.x / 2:
		set_bias(0)
		accept_event()
	# Move the knob by right-dragging
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed and not is_knob_active and \
		event.position.x < rect_size.x / 2:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_knob_active = true
		knob_mouse_pos = event.global_position
		accept_event()
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed and event.position.x >= rect_size.x / 2:
		_switch_func_type()
	# Release the knob
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and not event.pressed and is_knob_active == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_knob_active = false
		get_viewport().warp_mouse(knob_mouse_pos)
		accept_event()
	elif is_knob_active and event is InputEventMouseMotion:
		incr_bias(event.relative.y * -0.05)
		accept_event()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		recalculate_size()

func update_value():
	_prev_output_value = output_value
	if _func_type == ACTIVATION_FUNCTION.STEP:
		if get_input_value() >= get_bias():
			output_value = 100.0
		else:
			output_value = 0.0
	else:
		output_value = clamp(get_input_value() - get_bias(), -100.0, 100.0)
	if output_value != _prev_output_value:
		update()
