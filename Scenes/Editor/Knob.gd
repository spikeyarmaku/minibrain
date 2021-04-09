extends Node2D

signal drag(to_pos)
signal drag_start()
signal drag_end()

enum KNOB_TYPE {NODE_KNOB, EDGE_KNOB}

var type

var _radius setget set_radius, get_radius
var _value setget set_value, get_value

var _color_node : Color = Color.from_hsv(0, 0, 0.2)
var _color_knob : Color = Color.from_hsv(0, 0, 0.4)
var _color_outline : Color = Color.from_hsv(0, 0, 0.15)
const _outline_width = 2

var is_knob_active = false
var knob_mouse_pos
var is_dragged = false
var drag_offset

func set_value(val):
	_value = min(max(-100, val), 100)
	update()

func get_value():
	return _value

func set_radius(r):
	_radius = r
	$DragArea/DragAreaShape.shape.radius = _radius
	$LabelContainer.rect_position = Vector2(-_radius / 2 - 3, 0)
	$LabelContainer.rect_size = Vector2(_radius, _radius)
	$LabelContainer/Label.rect_min_size = Vector2(_radius + 6, _radius)
	
func get_radius():
	return _radius

func incr_value(by_val):
	set_value(_value + by_val)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	_draw_node()
	_draw_knob()
	var color
	if floor(_value) == 0:
		color = Color.from_hsv(0, 0, 0.4)
	elif _value > 0:
		color = Color(0, 1, 0)
	else:
		color = Color(1, 0, 0)
	$LabelContainer/Label.bbcode_text = \
		"[center][color=#" + color.to_html() + "]" + str(floor(_value)) + "[/color][/center]"
	
func _draw_node():
	if type == KNOB_TYPE.NODE_KNOB:
		# outline
		draw_circle(Vector2(0, 0), _radius + _outline_width, _color_outline)
		# base
		draw_circle(Vector2(0, 0), _radius, _color_node)
	else:
		var points_outline = [ Vector2(0, _radius + _outline_width)
							 , Vector2(_radius + _outline_width, 0)
							 , Vector2(0, -_radius - _outline_width)
							 , Vector2(-_radius - _outline_width, 0) ]
		var points = [ Vector2(0,  _radius), Vector2( _radius, 0)
					 , Vector2(0, -_radius), Vector2(-_radius, 0) ]
		# outline
		draw_colored_polygon(PoolVector2Array(points_outline), _color_outline)
		# base
		draw_colored_polygon(PoolVector2Array(points), _color_node)

func _draw_knob():
	var r = _radius  * _value / 100
	if type == KNOB_TYPE.NODE_KNOB:
		draw_circle_arc(Vector2(0, 0), r, PI / 2, -PI / 2, _color_knob)
#		draw_circle(Vector2(0, 0), r, _color_knob)
	else:
		var points = [Vector2(0, r), Vector2(r, 0), Vector2(0, -r)]
		draw_colored_polygon(PoolVector2Array(points), _color_knob)

func draw_circle_arc(center, r, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to-angle_from) / nb_points
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * r)
	points_arc.push_back(center)
	draw_colored_polygon(points_arc, color)

# If RMB is pressed, capture the mouse, until RMB is released
func _on_DragArea_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed == true and is_knob_active == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_knob_active = true
		knob_mouse_pos = event.position
		# We can only use InputEventMouseMotion.relative
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT \
		and event.pressed == true:
		is_dragged = true
		emit_signal("drag_start")
		drag_offset = get_local_mouse_position()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed == false and is_knob_active == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_knob_active = false
		get_viewport().warp_mouse(knob_mouse_pos)
		get_tree().set_input_as_handled()
	elif is_knob_active and event is InputEventMouseMotion:
		incr_value(event.relative.x * 0.05)
		get_tree().set_input_as_handled()
	elif is_dragged and event is InputEventMouseButton and \
		event.button_index == BUTTON_LEFT and event.pressed == false:
		is_dragged = false
		emit_signal("drag_end")
		get_tree().set_input_as_handled()
	elif is_dragged and event is InputEventMouseMotion:
		emit_signal("drag", get_viewport().get_mouse_position() - drag_offset)
		get_tree().set_input_as_handled()
