extends Node2D

var _id setget , get_id

var radius

# Called when the node enters the scene tree for the first time.
func _ready():
	$Knob.set_radius(radius)
	$Knob.type = $Knob.KNOB_TYPE.NODE_KNOB
	$Knob.set_value(100)
	$Knob.connect("drag", self, "_on_drag")
	$Knob.connect("drag_start", self, "_on_drag_start")
	$Knob.connect("drag_end", self, "_on_drag_end")
	$Plug/LeftPin.init(radius / 2, Vector2(radius, 0))
	$Plug/RightPin.init(radius / 2, Vector2(-radius, 0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func init(id, r):
	_id = id
	radius = r

func get_id():
	return _id

func _on_drag(to_pos):
	position = to_pos

func _on_drag_start():
	$Plug/LeftPin/ConnectionArea.disconnect("mouse_entered", $Plug/LeftPin, "_on_ConnectionArea_mouse_entered")
	$Plug/RightPin/ConnectionArea.disconnect("mouse_entered", $Plug/RightPin, "_on_ConnectionArea_mouse_entered")
	
func _on_drag_end():
	$Plug/LeftPin/ConnectionArea.connect("mouse_entered", $Plug/LeftPin, "_on_ConnectionArea_mouse_entered")
	$Plug/RightPin/ConnectionArea.connect("mouse_entered", $Plug/RightPin, "_on_ConnectionArea_mouse_entered")
