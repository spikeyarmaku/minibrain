extends Node2D

# Emit this signal when the mission is over. The parameter tells if this mission
# was completed successfully or not.
signal completed(success)

var slider_position = 0
var target_position = 0
var slider_origin
var elapsed_time = 0

const sliding_speed = 2
const slide_amount = 150
const simulation_period = 15 # Run the simulation for 15 seconds total
const sample_rate = 0.1 # Take a sample every 100 ms
const target = 50 # The cumulative error should be no greater than this value

var diff = 0
var last_sample_time = 0

var rng

func _ready():
	slider_origin = $Slider.position.x
	rng = RandomNumberGenerator.new()
	rng.set_seed(45377)

# Advances the simulation by a frame. `delta` gives you the time by which the
# current frame should advance.
func step(delta):
	# Keep track of elapsed time
	elapsed_time += delta
	
	# Sample light and button states
	if elapsed_time - last_sample_time > sample_rate:
		var correct_value = 0
		if slider_position >= 80:
			correct_value = 1
		diff += abs(correct_value - $Light.color.a)
		if abs(target_position - slider_position) < 5:
			# Make points closer to the edges more likely
			target_position = randf() * 100
		last_sample_time += sample_rate
	
	# Update button state
	var new_slider_position = slider_position + sign(target_position - slider_position) * 1
	$Slider.position.x = slider_origin + (new_slider_position / 100 * slide_amount)
	slider_position = new_slider_position
	if elapsed_time > simulation_period:
		emit_signal("completed", diff < target)

func _draw():
	pass

# Tells the editor what inputs and outputs should it have
func define_inputs_outputs():
	return [["slider"], ["light"]]

# Provides the input nodes with values
func provide_inputs():
	return [int(round(slider_position))]

# The outputs that the output nodes got from the node network
func receive_outputs(outputs):
	$Light.color.a = outputs[0] / 100
