extends Node2D

var agars = []
var bot
var speed = 0
var turn = 0

const turn_vel = PI # Radians per second

# Called when the node enters the scene tree for the first time.
func _ready():
	bot = $Bot
	var count = 20
	for i in range(count):
		generate_agar(i, count)

func _physics_process(delta):
	bot.rotation += turn_vel * turn * delta
	var theta = bot.rotation
	var speed_vec = Vector2(cos(theta), sin(theta)) * speed * 10.0
#	bot.apply_central_impulse(Vector2(cos(theta), sin(theta)) * speed)
	bot.move_and_slide(speed_vec)

func _draw():
	for a in agars:
		draw_circle(a, 3, Color.from_hsv(0, 0, 0.4))

func define_inputs_outputs():
	return [["distance", "direction"], ["move", "rotate"]]

func provide_inputs():
	var min_dst = measure_distance_to(agars[0])
	var closest_agar = agars[0]
	for a in agars:
		var dst = measure_distance_to(a)
		if dst < min_dst:
			min_dst = dst
			closest_agar = a
	var dir = measure_direction_to(closest_agar)
	return [100 / max(min_dst, 1), dir]

func measure_distance_to(p):
	return (bot.position - p).length()

func measure_direction_to(p):
	var d1 = p.angle_to_point(bot.position)
	var d2 = bot.rotation
	return d1 - d2

func receive_outputs(outputs):
	speed = outputs[0] / 100.0
	turn = outputs[1] / 100.0

func generate_agar(i, count):
	var angle = i * 2 * PI / count
	var dst = 50 + randf() * 100
	var pos = Vector2(cos(angle) * dst, sin(angle) * dst)
	agars.append(pos)

