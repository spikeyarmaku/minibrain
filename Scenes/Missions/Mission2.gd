extends Node2D

# Emit this signal when the mission is over. The parameter tells if this mission
# was completed successfully or not.
signal completed(success)

# Tells the editor what inputs and outputs should it have
const title = "Two lamps"
const notes = "[fill]" +\
"To drag the camera, hold down the right mouse button.\n" +\
"[img=30]res://data/icons/button_reset.png[/img] The reset button restarts " +\
"the simulation.\n" +\
"[img=30]res://data/icons/button_step.png[/img] The step button advances " +\
"the simulation by one tick.\n" +\
"[/fill]"
#"Reset and step"
const inputs = ["button"]
const outputs = ["left\nlight", "right\nlight"]

var button_pressed = false
var elapsed_time = 0

const time_between_presses = 1
const press_amount = 30
const simulation_period = 10 # Run the simulation for 10 seconds total
const sample_rate = 0.1 # Take a sample every 100 ms
const target = 5 # The cumulative error should be no greater than this value

var diff = 0
var last_sample_time = 0

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
		last_sample_time += sample_rate
		var button_value = 0
		if button_pressed:
			button_value = 1
		diff += abs(button_value - $LightLeft.color.a)
		diff += abs(button_value - $LightRight.color.a)
	
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
	if button_pressed:
		return [100]
	else:
		return [0]

# The outputs that the output nodes got from the node network
func receive_outputs(outputs):
	$LightLeft.color.a = outputs[0] / 100
	$LightRight.color.a = outputs[1] / 100
