tool
extends Control

# Synapse logic
var _input_value = 0 setget set_input_value, get_input_value
var output_value = 0
var _prev_input_value = 0
var _prev_output_value = 0
var _weight = 100 setget set_weight, get_weight
var _decay = 0 setget set_decay, get_decay # amount of charge lost per second
var changed = false

var _color_node : Color = Color.from_hsv(0, 0, 0.2)
var _color_knob : Color = Color.from_hsv(0, 0, 0.4)
var _color_knob_input_positive : Color = Color(0, 0.4, 0)
var _color_knob_input_negative : Color = Color(0.4, 0, 0)
var _color_knob_output_positive : Color = Color(0, 0.4, 0)
var _color_knob_output_negative : Color = Color(0.4, 0, 0)
var _color_outline : Color = Color.from_hsv(0, 0, 0.15)
const _outline_width = 2

var is_disabled = false
var label_text
var label_weight
var label_decay
var is_weight_knob_active = false
var is_decay_knob_active = false
var knob_mouse_pos
var radius = 10
var center = Vector2(0,0)

# Hides user-set weight lables, and shows actual values
var simulation_mode = false setget set_simulation_mode, get_simulation_mode

func set_input_value(i):
	if _input_value != i:
		_input_value = i
		update()
	
func get_input_value():
	return _input_value

func set_simulation_mode(s):
	label_text.visible = s
	label_weight.visible = not s
	label_decay.visible = not s

func get_simulation_mode():
	return simulation_mode

func minimize():
	rect_scale = Vector2(0.5, 0.5)
	label_weight.visible = false
	label_decay.visible = false

func maximize():
	rect_scale = Vector2(1, 1)
	label_weight.visible = true
	label_decay.visible = true

func set_weight(val):
	var new_weight = min(max(-100, val), 100)
	if get_weight() != int(round(new_weight)):
		changed = true
	_weight = new_weight
	update()

func get_weight():
	return int(round(_weight))

func set_decay(val):
	var new_decay = min(max(0, val), 100)
	if get_decay() != int(round(new_decay)):
		changed = true
	_decay = new_decay
	update()
	
func get_decay():
	return int(round(_decay))

func incr_decay(by_val):
	set_decay(_decay + by_val)

func incr_weight(by_val):
	set_weight(_weight + by_val)

func _ready():
	label_weight = $LabelWeight
	label_decay = $LabelDecay
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
		var weight_color_text
		if get_weight() == 0:
			weight_color_text = Color.from_hsv(0, 0, 0.8)
		elif get_weight() > 0:
			weight_color_text = Color(0, 1, 0)
		else:
			weight_color_text = Color(1, 0, 0)
		label_weight.theme.default_font.size = 2 * radius / 5
		label_weight.bbcode_text = \
			"[center][color=#" + weight_color_text.to_html() + "]" + \
			str(get_weight()) + "[/color][/center]"
		var decay_color_text
		if get_decay() == 0:
			decay_color_text = Color.from_hsv(0, 0, 0.8)
		else:
			decay_color_text = Color(1, 0, 0)
		label_decay.theme.default_font.size = 2 * radius / 5
		label_decay.bbcode_text = \
			"[center][color=#" + decay_color_text.to_html() + "]" + \
			str(get_decay()) + "[/color][/center]"

func _draw_body():
	var topleft = center - Vector2(radius, radius)
	var rect = Rect2(topleft, Vector2(radius * 2, radius * 2))
	draw_rect(rect, _color_node, true)
	draw_rect(rect, _color_outline, false, _outline_width)

func _draw_knob():
	var input_first = abs(get_input_value()) > abs(get_weight())
	var output_first = get_decay() > 0
	if input_first:
		draw_input()
	if output_first:
		draw_output()
	draw_knob_indicator()
	if not input_first:
		draw_input()
	if not output_first:
		draw_output()
	draw_line(Vector2(0, -radius) + center, Vector2(0, radius) + center, \
			 _color_outline, 4)

func draw_knob_indicator():
	var left_y = radius * get_weight() / 100
	var right_x = radius * (1 - (get_decay() - 1.0) / 100)
	var points = [ Vector2(-radius, 0) + center
				 , Vector2(-radius, -left_y) + center
				 , Vector2(0, -left_y) + center ]
	if get_decay() == 0:
		points.append(center + Vector2(radius, -left_y))
		points.append(center + Vector2(radius, 0))
	else:
		points.append(center + Vector2(right_x, 0))
	draw_colored_polygon(PoolVector2Array(points), _color_knob)

func draw_input():
	var height = get_input_value() / 100
	var color = _color_knob_input_positive
	if height < 0:
		color = _color_knob_input_negative
	var points = [ Vector2(-radius, 0) + center
				 , center
				 , Vector2(0, -height * radius) + center
				 , Vector2(-radius, -height * radius) + center ]
	draw_colored_polygon(PoolVector2Array(points), color)
	
func draw_output():
	var height = output_value / 100
	var color = _color_knob_output_positive
	if output_value < 0:
		color = _color_knob_output_negative
	var points = [ center
				 , Vector2(radius, 0) + center
				 , Vector2(radius, -height * radius) + center
				 , Vector2(0, -height * radius) + center ]
	draw_colored_polygon(PoolVector2Array(points), color)

func _gui_input(event):
	if is_disabled:
		return
	# Reset weight by double right-clicking
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed and event.doubleclick and \
		event.position.x < rect_size.x / 2:
		set_weight(0)
		accept_event()
	# Reset decay by double right-clicking
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed and event.doubleclick and \
		event.position.x >= rect_size.x / 2:
		set_decay(0)
		accept_event()
	# Change weight knob
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed and not is_weight_knob_active and \
		event.position.x < rect_size.x / 2:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_weight_knob_active = true
		knob_mouse_pos = event.global_position
		accept_event()
	# Change decay knob
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed and not is_decay_knob_active and \
		event.position.x >= rect_size.x / 2:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_decay_knob_active = true
		knob_mouse_pos = event.global_position
		accept_event()
	# Release knob
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and not event.pressed and \
		(is_weight_knob_active or is_decay_knob_active):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_weight_knob_active = false
		is_decay_knob_active = false
		get_viewport().warp_mouse(knob_mouse_pos)
		accept_event()
	elif is_weight_knob_active and event is InputEventMouseMotion:
		var zoom = Global.get_camera_2d(get_viewport()).zoom.x
		incr_weight(event.relative.y * -0.05 / zoom)
		accept_event()
	elif is_decay_knob_active and event is InputEventMouseMotion:
		var zoom = Global.get_camera_2d(get_viewport()).zoom.x
		incr_decay(event.relative.y * 0.05 / zoom)
		accept_event()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		recalculate_size()

# Reads the input node's value, and updates its own accordingly
func update_value(delta):
	if _input_value != _prev_input_value:
		changed = true
		
	if changed:
		output_value = clamp(get_weight() * get_input_value() / 100, -100, 100)
		_prev_input_value = _input_value
	else:
		if output_value > 0:
			output_value = clamp(output_value - get_decay() * delta, 0, 100)
		else:
			output_value = clamp(output_value + get_decay() * delta, -100, 0)
	var output_changed = output_value != _prev_output_value
	_prev_output_value = output_value
	
	if changed or output_changed:
		update()
	
	changed = false

func reset():
	_input_value = 0
	_prev_input_value = 0
	output_value = 0
	_prev_output_value = 0
	changed = false
	update()
