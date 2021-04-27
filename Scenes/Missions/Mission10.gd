extends Node2D

# Emit this signal when the mission is over. The parameter tells if this mission
# was completed successfully or not.
signal completed(success)

var left_button_pressed = false
var right_button_pressed = false
var elapsed_time = 0

const time_between_presses = 1
const press_amount = 30
const simulation_period = 10 # Run the simulation for 10 seconds total
const sample_rate = 0.1 # Take a sample every 100 ms
const target = 15 # The cumulative error should be no greater than this value

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
		if (not left_button_pressed and right_button_pressed) or \
		   (left_button_pressed and not right_button_pressed):
			correct_value = 1
		else:
			correct_value = 0
	
	# Update button state
	var new_left_button_state = sin(PI + 0.8 * elapsed_time * PI) > 0
	var new_right_button_state = sin(PI + 1.2 * elapsed_time * PI) > 0
	if new_left_button_state != left_button_pressed:
		if new_left_button_state:
			$ButtonLeft.position.y += press_amount
		else:
			$ButtonLeft.position.y -= press_amount
	if new_right_button_state != right_button_pressed:
		if new_right_button_state:
			$ButtonRight.position.y += press_amount
		else:
			$ButtonRight.position.y -= press_amount
	left_button_pressed = new_left_button_state
	right_button_pressed = new_right_button_state
	if elapsed_time > simulation_period:
		emit_signal("completed", diff < target)

func _draw():
	pass

# Tells the editor what inputs and outputs should it have
func define_inputs_outputs():
	return [["left\nbutton", "right\nbutton"], ["light"]]

# Provides the input nodes with values
func provide_inputs():
	var left_value = 0
	if left_button_pressed:
		left_value = 100
	var right_value = 0
	if right_button_pressed:
		right_value = 100
	return [left_value, right_value]

# The outputs that the output nodes got from the node network
func receive_outputs(outputs):
	$Light.color.a = outputs[0] / 100
