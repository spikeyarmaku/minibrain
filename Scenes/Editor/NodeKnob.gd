tool
extends Control

enum ACTIVATION_FUNCTION {STEP, LINEAR}

var _func_type = ACTIVATION_FUNCTION.STEP

var _value = 0 setget set_value, get_value

var _color_node : Color = Color.from_hsv(0, 0, 0.2)
var _color_knob : Color = Color.from_hsv(0, 0, 0.4)
var _color_outline : Color = Color.from_hsv(0, 0, 0.15)
const _outline_width = 2

var is_disabled = false
var label_text
var label_value
var is_knob_active = false
var knob_mouse_pos
var radius = 10
var center = Vector2(0,0)

# For input and output nodes
func label_and_disable(label):
	var color = Color.from_hsv(0, 0, 0.8)
	label_text.bbcode_text = \
			"[center][color=#" + color.to_html() + "]" + label + \
			"[/color][/center]"
	label_text.theme.default_font.size = 2 * radius / 5
	is_disabled = true
	label_text.visible = true
	label_value.visible = false

func set_value(val):
	_value = min(max(-100, val), 100)
	update()

func get_value():
	return int(round(_value))

func incr_value(by_val):
	set_value(_value + by_val)

func _switch_func_type():
	if _func_type == ACTIVATION_FUNCTION.LINEAR:
		_func_type = ACTIVATION_FUNCTION.STEP
	else:
		_func_type = ACTIVATION_FUNCTION.LINEAR
	update()

func _ready():
	label_value = $LabelValue
	label_text = $LabelText
	label_text.visible = false
	recalculate_size()
	
func recalculate_size():
	radius = min(rect_size.x / 2, rect_size.y / 2)
	center = rect_size / 2
	update()

func _draw():
	_draw_body()
	if not is_disabled:
		_draw_knob()
		_draw_func_type()
		var color
		if get_value() == 0:
			color = Color.from_hsv(0, 0, 0.8)
		elif get_value() > 0:
			color = Color(0, 1, 0)
		else:
			color = Color(1, 0, 0)
		label_value.theme.default_font.size = 2 * radius / 5
		label_value.bbcode_text = \
			"[center][color=#" + color.to_html() + "]" + str(get_value()) + \
			"[/color][/center]"

func _draw_body():
	# outline
	draw_circle(center, radius + _outline_width, _color_outline)
	# base
	draw_circle(center, radius, _color_node)

func _draw_knob():
	var angle = get_value() / 100.0
	draw_circle_arc(center, radius, -PI, -(1 - angle) * PI / 2, _color_knob)

func _draw_func_type():
	var color = Color.from_hsv(0, 0, 0.4)
	var points = PoolVector2Array()
	if _func_type == ACTIVATION_FUNCTION.STEP:
		points.append(center + Vector2(-radius / 2, 6 * radius / 8))
		points.append(center + Vector2(0, 6 * radius / 8))
		points.append(center + Vector2(0, 2 * radius / 8))
		points.append(center + Vector2(radius / 2, 2 * radius / 8))
	else:
		points.append(center + Vector2(-radius / 2, 6 * radius / 8))
		points.append(center + Vector2(radius / 2, 2 * radius / 8))
	draw_polyline(points, color, 5)

func draw_circle_arc(center, r, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to-angle_from) / nb_points
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * r)
	points_arc.push_back(center)
	draw_colored_polygon(points_arc, color)

func _gui_input(event):
	if is_disabled:
		return
	# Reset the knob by double right-clicking
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed and event.doubleclick and \
		event.position.y < rect_size.y / 2:
		set_value(0)
		accept_event()
	# Move the knob by right-dragging
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed and not is_knob_active and \
		event.position.y < rect_size.y / 2:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_knob_active = true
		knob_mouse_pos = event.global_position
		accept_event()
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed and event.position.y >= rect_size.y / 2:
		_switch_func_type()
	# Release the knob
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and not event.pressed and is_knob_active == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_knob_active = false
		get_viewport().warp_mouse(knob_mouse_pos)
		accept_event()
	elif is_knob_active and event is InputEventMouseMotion:
		incr_value(event.relative.x * 0.05)
		accept_event()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		recalculate_size()
