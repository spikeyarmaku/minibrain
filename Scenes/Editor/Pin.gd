tool
extends Control

signal connect_request()
signal connect_request_end()

var pin_type
var is_hover = false setget set_hover, get_hover
var radius = 10
var center = Vector2(0,0)

func set_hover(h):
	is_hover = h
	recalculate_size()

func get_hover():
	return is_hover

func _ready():
	recalculate_size()
	
func recalculate_size():
	radius = min(rect_size.x / 2, rect_size.y / 2)
	center = rect_size / 2
	update()

func _draw():
	var c = Color.from_hsv(0, 0, 0.55)
	var r = radius
	if is_hover == false:
		r = r / 3
	draw_circle(center, r, c)

func init(type):
	pin_type = type

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and is_hover and \
		event.button_index == BUTTON_LEFT:
		emit_signal("connect_request")
		accept_event()
	elif event is InputEventMouseButton and is_hover and not event.pressed and \
		event.button_index == BUTTON_LEFT:
		emit_signal("connect_request_end")
		accept_event()

func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER:
		set_hover(true)
	elif what == NOTIFICATION_MOUSE_EXIT:
		set_hover(false)
	elif what == NOTIFICATION_RESIZED:
		recalculate_size()
