tool
extends Control

signal delete(edge)

var value = 0

var is_dragged = false
var drag_offset
var start_pin : Control
var end_pin : Control

func _ready():
	$Knob.type = $Knob.KNOB_TYPE.EDGE_KNOB

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()

func _draw():
	var pos = rect_size / 2
	var start_pos
	if start_pin == null:
		start_pos = Vector2(0,0)
	else:
		start_pos = start_pin.rect_position + start_pin.rect_size / 2
	var end_pos
	if end_pin == null:
		end_pos = Vector2(0,0)
	else:
		end_pos = end_pin.rect_position + end_pin.rect_size / 2
#	if start_point == null:
#		start_pos = get_global_mouse_position()
#	if end_point == null:
#		end_pos = get_global_mouse_position()
	var line1 : Line2D = make_bezier_line(start_pos - rect_position, pos)
	var line2 : Line2D = make_bezier_line(pos, end_pos - rect_position)
	draw_line2D(line1)
	draw_line2D(line2)

func draw_line2D(line2D):
	for i in range(0, line2D.points.size() - 1):
		draw_line( line2D.points[i], line2D.points[i+1]
				 , Color.from_hsv(0, 0, 0.4), 8 )

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

func make_bezier_line(start_pos, end_pos):
	var line = Line2D.new()
	var curve = Curve2D.new()
	var ctr_vector = Vector2(abs(end_pos.x - start_pos.x), 0)
	curve.add_point(start_pos, Vector2(0,0), ctr_vector)
	curve.add_point(end_pos, -ctr_vector, Vector2(0,0))
	var points = curve.tessellate()
	for p in points:
		line.add_point(p)
	return line
