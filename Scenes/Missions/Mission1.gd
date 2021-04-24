extends Node2D

# Emit this signal when the mission is over. The parameter tells if this mission
# was completed successfully or not.
signal completed(success)

# Controls whether or not to have a camera that's movable and zoomable by the
# player
var is_single_screen = false

var button_pressed = false
var elapsed_time = 0

const time_between_presses = 1
const press_amount = 30
const simulation_period = 10 # Run the simulation for 10 seconds total
const sample_rate = 0.1 # Take a sample every 100 ms
const target = 500 # The cumulative error should be no greater than 500

var button_states = []
var light_states = []
var diff = 0
var last_sample_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = Tween.new()
	var timeout = 10
	add_child(tween)
	tween.interpolate_property($PlayLabel, "self_modulate:a", 1, 0, timeout)
	tween.interpolate_property($EditorLabel, "self_modulate:a", 1, 0, timeout)
	tween.interpolate_property($PlayArrow, "self_modulate:a", 1, 0, timeout)
	tween.interpolate_property($EditorArrow, "self_modulate:a", 1, 0, timeout)
	tween.start()

# Advances the simulation by a frame. `delta` gives you the time by which the
# current frame should advance.
func step(delta):
	# Keep track of elapsed time
	elapsed_time += delta
	
	# Sample light and button states
	if elapsed_time - last_sample_time > sample_rate:
		last_sample_time += sample_rate
		button_states.append(button_pressed)
		light_states.append($Light.color.a)
		var button_value = 0
		if button_pressed:
			button_value = 100
		diff += abs(button_value - $Light.color.a * 100)
	
	# Update button state
	var new_button_state = sin(PI + elapsed_time * PI) > 0
	if new_button_state != button_pressed:
		if new_button_state:
			$Button.position.y += press_amount
		else:
			$Button.position.y -= press_amount
	button_pressed = new_button_state
	if elapsed_time > simulation_period:
		emit_signal("completed", diff < target)

func _draw():
	pass

# Tells the editor what inputs and outputs should it have
func define_inputs_outputs():
	return [["button"], ["light"]]

# Provides the input nodes with values
func provide_inputs():
	if button_pressed:
		return [100]
	else:
		return [0]

# The outputs that the output nodes got from the node network
func receive_outputs(outputs):
	$Light.color.a = outputs[0] / 100
