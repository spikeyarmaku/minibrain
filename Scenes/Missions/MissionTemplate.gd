extends Node2D

# Emit this signal when the mission is over. The parameter tells if this mission
# was completed successfully or not.
signal completed(success)

# Tells the editor what inputs and outputs should it have
const title = "Template Mission"
const notes = "This is a mission template. " +\
			  "Copy and modify it according to your needs."
const inputs = ["input"]
const outputs = ["output"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Advances the simulation by a frame. `delta` gives you the time by which the
# current frame should advance.
func step(delta):
	pass

func _draw():
	pass

# Provides the input nodes with values
func provide_inputs():
	return [0]

# The outputs that the output nodes got from the node network
func receive_outputs(outputs):
	pass
