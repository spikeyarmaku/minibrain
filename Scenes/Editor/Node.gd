tool
extends Control

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
