tool
extends Control

signal delete()
signal connect_request(CONNECT_TYPE)
signal connect_request_end()
signal hover()
signal hover_end()

var node_type = Global.NODE_TYPE.INPUT_OUTPUT_NODE

var incoming_edges = []
var outgoing_edges = []

var is_hover = false setget set_hover, get_hover

var is_dragged = false

var is_deletable = true

var knob

func set_input_only(label):
	knob.label_and_disable(label)
	$LeftPinContainer.visible = false
	is_deletable = false
	node_type = Global.NODE_TYPE.INPUT_NODE
	knob._func_type = knob.ACTIVATION_FUNCTION.LINEAR
	knob.set_bias(0)
	knob.node_type = node_type
	
func set_output_only(label):
	knob.label_and_disable(label)
	$RightPinContainer.visible = false
	is_deletable = false
	node_type = Global.NODE_TYPE.OUTPUT_NODE
	knob._func_type = knob.ACTIVATION_FUNCTION.LINEAR
	knob.set_bias(0)
	knob.node_type = node_type

func get_output_pin():
	if $RightPinContainer.visible:
		return $RightPinContainer/Pin
	else:
		return null
	
func get_input_pin():
	if $LeftPinContainer.visible:
		return $LeftPinContainer/Pin
	else:
		return null

func set_hover(h):
	is_hover = h
	
func get_hover():
	return is_hover

func _ready():
	knob = $KnobContainer/NodeKnob
	var lpin = $LeftPinContainer/Pin
	var rpin = $RightPinContainer/Pin
	knob.set_bias(50)
	knob.node_type = node_type
	lpin.init(Global.PIN_TYPE.INPUT)
	rpin.init(Global.PIN_TYPE.OUTPUT)
	lpin.connect("connect_request", self, "_on_input_connect_request")
	lpin.connect("connect_request_end", self, "_on_connect_request_end")
	rpin.connect("connect_request", self, "_on_output_connect_request")
	rpin.connect("connect_request_end", self, "_on_connect_request_end")

var mouse_in = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# workaround for https://github.com/godotengine/godot/issues/20881
	var prev_mouse_in = mouse_in
	mouse_in = get_rect().has_point(get_global_mouse_position())
	if not prev_mouse_in and mouse_in:
		emit_signal("hover")
	elif prev_mouse_in and not mouse_in:
		emit_signal("hover_end")

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and \
		event.doubleclick and event.button_index == BUTTON_LEFT:
		emit_signal("delete")
		accept_event()
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		is_dragged = event.pressed
		accept_event()
	elif is_dragged and event is InputEventMouseMotion:
		rect_position += event.relative
		accept_event()

# This should work, but due to issue #20881 in godot it doesn't.
# See _process for workaround
#func _notification(what):
#	if what == NOTIFICATION_MOUSE_ENTER:
#		set_hover(true)
#		emit_signal("hover")
#	elif what == NOTIFICATION_MOUSE_EXIT:
#		set_hover(false)
#		emit_signal("hover_end")

func _on_output_connect_request():
	emit_signal("connect_request", Global.CONNECT_TYPE.OUTPUT_INPUT)

func _on_input_connect_request():
	emit_signal("connect_request", Global.CONNECT_TYPE.INPUT_OUTPUT)

func _on_connect_request_end():
	emit_signal("connect_request_end")

func destroy():
	# Destroy edges
	var incoming_edge_list = incoming_edges.duplicate()
	for e in incoming_edge_list:
		e.emit_signal("delete")
	var outgoing_edge_list = outgoing_edges.duplicate()
	for e in outgoing_edge_list:
		e.emit_signal("delete")
	queue_free()

func collect_input():
	if node_type == Global.NODE_TYPE.INPUT_NODE:
		return
	var input_value = 0
	for i in incoming_edges:
		input_value += i.get_output()
	knob.set_input_value(clamp(input_value, -100.0, 100.0))

func update_value():
	knob.update_value()

func get_output():
	return knob.output_value

func set_input(i):
	knob.set_input_value(i)
