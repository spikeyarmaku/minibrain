tool
extends Control

signal changed()

var _weight = 100 setget set_weight, get_weight
var _decay = 0 setget set_decay, get_decay # amount of charge lost per second

var _color_node : Color = Color.from_hsv(0, 0, 0.2)
var _color_knob : Color = Color.from_hsv(0, 0, 0.4)
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
	if _weight != new_weight:
		emit_signal("changed")
	_weight = new_weight
	update()

func get_weight():
	return int(round(_weight))

func set_decay(val):
	var new_decay = min(max(0, val), 100)
	if _decay != new_decay:
		emit_signal("changed")
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
	draw_line(Vector2(0, -radius) + center, Vector2(0, radius) + center, \
			 _color_outline, 4)

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
		incr_weight(event.relative.y * -0.05)
		accept_event()
	elif is_decay_knob_active and event is InputEventMouseMotion:
		incr_decay(event.relative.y * 0.05)
		accept_event()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		recalculate_size()
