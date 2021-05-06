extends Camera2D

var can_move = false
var can_zoom = true
var drag = false
var zoom_factor = 1.2

# This is for touchscreen
var touch_events = {}
var last_drag_distance = 0
var zoom_sensitivity = 10
var zoom_speed = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if can_move:
		if Global.input_mode == Global.INPUT_MODE.MOUSE_INPUT:
			if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
				and event.pressed:
				drag = true
			elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
				and not event.pressed:
				drag = false
			elif drag and event is InputEventMouseMotion:
				position -= event.relative * zoom
		else:
			if event is InputEventScreenTouch:
				if event.pressed:
					touch_events[event.index] = event
				else:
					touch_events.erase(event.index)
			if event is InputEventScreenDrag:
				touch_events[event.index] = event
				if touch_events.size() == 1:
					position -= event.relative * zoom
				elif touch_events.size() == 2:
					var drag_distance = touch_events[0].position.distance_to(touch_events[1].position)
					if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
						if drag_distance < last_drag_distance:
							zoom *= Vector2.ONE * (1 + zoom_speed)
						else:
							zoom *= Vector2.ONE * (1 - zoom_speed)
					update()
					last_drag_distance = drag_distance

func _input(event):
	if can_zoom and Global.input_mode == Global.INPUT_MODE.MOUSE_INPUT:
		if event is InputEventMouseButton and \
			event.button_index == BUTTON_WHEEL_UP:
			# TODO use a tween
			zoom /= zoom_factor
		elif event is InputEventMouseButton and \
			event.button_index == BUTTON_WHEEL_DOWN:
			# TODO use a tween
			zoom *= zoom_factor
