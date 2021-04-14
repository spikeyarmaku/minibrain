tool
extends Control

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

func minimize():
	rect_scale = Vector2(0.5, 0.5)
	$LabelValue.visible = false

func maximize():
	rect_scale = Vector2(1, 1)
	$LabelValue.visible = true

func set_value(val):
	_value = min(max(-100, val), 100)
	update()

func get_value():
	return int(round(_value))

func incr_value(by_val):
	set_value(_value + by_val)

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
	var points_outline = [ Vector2(0, radius + _outline_width) + center
						 , Vector2(radius + _outline_width, 0) + center
						 , Vector2(0, -radius - _outline_width) + center
						 , Vector2(-radius - _outline_width, 0) + center ]
	var points = [ Vector2(0,  radius) + center
				 , Vector2( radius, 0) + center
				 , Vector2(0, -radius) + center
				 , Vector2(-radius, 0) + center ]
	# outline
	draw_colored_polygon(PoolVector2Array(points_outline), _color_outline)
	# base
	draw_colored_polygon(PoolVector2Array(points), _color_node)

func _draw_knob():
	var r = radius  * get_value() / 100
	var points = [ Vector2(0, r) + center
				 , Vector2(r, 0) + center
				 , Vector2(0, -r) + center ]
	draw_colored_polygon(PoolVector2Array(points), _color_knob)

func _gui_input(event):
	if is_disabled:
		return
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed and not is_knob_active:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_knob_active = true
		knob_mouse_pos = event.global_position
		accept_event()
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed and event.doubleclick:
		set_value(0)
		accept_event()
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
