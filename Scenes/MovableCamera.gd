extends Camera2D

var drag = false
var zoom_factor = 1.2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and event.pressed:
		drag = true
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT \
		and not event.pressed:
		drag = false
	elif drag and event is InputEventMouseMotion:
		position -= event.relative * zoom
		
func _input(event):
	if event is InputEventMouseButton and \
		event.button_index == BUTTON_WHEEL_UP:
		# TODO use a tween
		zoom /= zoom_factor
	elif event is InputEventMouseButton and \
		event.button_index == BUTTON_WHEEL_DOWN:
		# TODO use a tween
		zoom *= zoom_factor
