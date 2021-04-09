extends Node2D

var is_hover = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	var c = Color.from_hsv(0, 0, 0.55)
	var r = $ConnectionArea/CollisionShape2D.shape.radius
	if is_hover == false:
		r = r / 4
	draw_circle(Vector2(0,0), r, c)

func init(radius, pos):
	$ConnectionArea/CollisionShape2D.shape.radius = radius
	position = pos
	update()

func _on_ConnectionArea_mouse_entered():
	is_hover = true
	update()

func _on_ConnectionArea_mouse_exited():
	is_hover = false
	update()
