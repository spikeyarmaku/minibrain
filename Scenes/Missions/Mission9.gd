extends Node2D

# Emit this signal when the mission is over. The parameter tells if this mission
# was completed successfully or not.
signal completed(success)

# Tells the editor what inputs and outputs should it have
const title = "Inverter"
const notes = ""
const inputs = ["signal"]
const outputs = ["light"]

var button_pressed = false
var elapsed_time = 0

const time_between_presses = 1
const press_amount = 30
const simulation_period = 10 # Run the simulation for 10 seconds total
const sample_rate = 0.1 # Take a sample every 100 ms
const target = 10 # The cumulative error should be no greater than this value

var diff = 0
var last_sample_time = 0
var correct_value = 0

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass

# Advances the simulation by a frame. `delta` gives you the time by which the
# current frame should advance.
func step(delta):
	# Keep track of elapsed time
	elapsed_time += delta
	
	# Sample light and button states
	if elapsed_time - last_sample_time > sample_rate:
		diff += abs(correct_value - $Light.color.a)
		last_sample_time += sample_rate
		if not button_pressed:
			correct_value = 1
		else:
			correct_value = 0
	
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

# Provides the input nodes with values
func provide_inputs():
	var value = 0
	if button_pressed:
		value = 100
	return [value]

# The outputs that the output nodes got from the node network
func receive_outputs(outputs):
	$Light.color.a = outputs[0] / 100
