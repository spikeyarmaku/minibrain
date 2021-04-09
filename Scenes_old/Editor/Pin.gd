extends Node2D

signal hover_start()
signal hover_end()

enum PIN_TYPE {INPUT, OUTPUT}

var pin_type

var is_hover = false setget set_hover, get_hover
var is_connect = false setget set_connect, get_connect

func set_hover(h):
	if not is_hover and h:
		emit_signal("hover_start")
	elif not is_connect and not h:
		emit_signal("hover_end")
	is_hover = h
	update()
	
func get_hover():
	return is_hover
	
func set_connect(c):
	if is_connect and not c:
		emit_signal("hover_end")
	is_connect = c
	update()
	
func get_connect():
	return is_connect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	var c = Color.from_hsv(0, 0, 0.55)
	var r = $ConnectionArea/CollisionShape2D.shape.radius
	if is_hover == false:
		r = r / 3
	draw_circle(Vector2(0,0), r, c)

func init(radius, pos, type):
	$ConnectionArea/CollisionShape2D.shape.radius = radius
	position = pos
	pin_type = type
	update()

func _unhandled_input(event):
	if is_hover and Input.is_mouse_button_pressed(BUTTON_LEFT):
		set_connect(true)
		get_tree().set_input_as_handled()
	elif not Input.is_mouse_button_pressed(BUTTON_LEFT):
		set_connect(false)

func _on_ConnectionArea_mouse_entered():
	set_hover(true)

func _on_ConnectionArea_mouse_exited():
	set_hover(false)

