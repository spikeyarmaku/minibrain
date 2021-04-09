tool
extends Control

signal delete(node)

var is_dragged = false
var drag_offset

func _ready():
	var knob = $KnobContainer/Knob
	var lpin = $LeftPinContainer/Pin
	var rpin = $RightPinContainer/Pin
	knob.type = knob.KNOB_TYPE.NODE_KNOB
	lpin.init(lpin.PIN_TYPE.INPUT)
	rpin.init(rpin.PIN_TYPE.OUTPUT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
	
