tool
extends Control

enum KNOB_TYPE {NODE_KNOB, EDGE_KNOB}

var type = KNOB_TYPE.NODE_KNOB

var _value = 100 setget set_value, get_value

var _color_node : Color = Color.from_hsv(0, 0, 0.2)
var _color_knob : Color = Color.from_hsv(0, 0, 0.4)
var _color_outline : Color = Color.from_hsv(0, 0, 0.15)
const _outline_width = 2

var is_knob_active = false
var knob_mouse_pos
var radius = 10
var center = Vector2(0,0)

func set_value(val):
	_value = min(max(-100, val), 100)
	update()

func get_value():
	return _value

func incr_value(by_val):
	set_value(_value + by_val)

func _ready():
	recalculate_size()
	
func recalculate_size():
	radius = min(rect_size.x / 2, rect_size.y / 2)
	center = rect_size / 2
	update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	_draw_body()
	_draw_knob()
	var color
	if floor(_value) == 0:
		color = Color.from_hsv(0, 0, 0.4)
	elif _value > 0:
		color = Color(0, 1, 0)
	else:
		color = Color(1, 0, 0)
	$Label.theme.default_font.size = 2 * radius / 5
	$Label.bbcode_text = \
		"[center][color=#" + color.to_html() + "]" + str(floor(_value)) + \
		"[/color][/center]"

func _draw_body():
	if type == KNOB_TYPE.NODE_KNOB:
		# outline
		draw_circle(center, radius + _outline_width, _color_outline)
		# base
		draw_circle(center, radius, _color_node)
	else:
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
	var r = radius  * _value / 100
	if type == KNOB_TYPE.NODE_KNOB:
		draw_circle_arc(center, r, PI / 2, -PI / 2, _color_knob)
	else:
		var points = [ Vector2(0, r) + center
					 , Vector2(r, 0) + center
					 , Vector2(0, -r) + center ]
		draw_colored_polygon(PoolVector2Array(points), _color_knob)

func draw_circle_arc(center, r, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to-angle_from) / nb_points
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * r)
	points_arc.push_back(center)
	draw_colored_polygon(points_arc, color)

func _gui_input(event):
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
