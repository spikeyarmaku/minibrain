extends Node

# Mission definitions
# var mission_agar = preload("res://Scenes/Missions/Agar.tscn")
var mission1 = preload("res://Scenes/Missions/Mission1.tscn")
var mission2 = null

var missions = [["Lamp", mission1], ["Two\nLamps", mission2]]
var current_mission = 0
# End of mission definitions

enum PIN_TYPE {INPUT, OUTPUT}
enum CONNECT_TYPE {INPUT_OUTPUT, OUTPUT_INPUT}
enum KNOB_TYPE {NODE_KNOB, EDGE_KNOB}
enum NODE_TYPE {INPUT_OUTPUT_NODE, INPUT_NODE, OUTPUT_NODE}

static func invert_connect_type(connect_type):
	if connect_type == CONNECT_TYPE.INPUT_OUTPUT:
		return CONNECT_TYPE.OUTPUT_INPUT
	else:
		return CONNECT_TYPE.INPUT_OUTPUT

static func make_bezier_line(start_pos, end_pos):
	var line = Line2D.new()
	curve_line(line, start_pos, end_pos)
	return line

static func curve_line(line2D, start_pos, end_pos):
	var curve = Curve2D.new()
	var ctr_vector = Vector2(abs(end_pos.x - start_pos.x), 0)
	curve.add_point(start_pos, Vector2(0,0), ctr_vector)
	curve.add_point(end_pos, -ctr_vector, Vector2(0,0))
	var points = curve.tessellate()
	line2D.clear_points()
	for p in points:
		line2D.add_point(p)

static func vp_to_scr(point, viewport):
	return viewport.canvas_transform * point

static func scr_to_vp(point, viewport):
	return viewport.canvas_transform.affine_inverse() * point

static func get_camera_2d(viewport):
	var objects = [viewport]
	while true:
		if objects.size() == 0:
			return null
		var children = []
		for o in objects:
			for oc in o.get_children():
				children.append(oc)
		for c in children:
			if c is Camera2D:
				return c
		objects = children
