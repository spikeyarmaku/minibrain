extends Node2D

# Emit this signal when the mission is over. The parameter tells if this mission
# was completed successfully or not.
signal completed(success)

# Controls whether or not to have a camera that's movable and zoomable by the
# player
var is_single_screen = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Advances the simulation by a frame. `delta` gives you the time by which the
# current frame should advance.
func step(delta):
	pass

func _draw():
	pass

# Tells the editor what inputs and outputs should it have
func define_inputs_outputs():
	return [["input"], ["output"]]

# Provides the input nodes with values
func provide_inputs():
	return [0]

# The outputs that the output nodes got from the node network
func receive_outputs(outputs):
	pass
