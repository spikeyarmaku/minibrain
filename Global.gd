extends Node

enum PIN_TYPE {INPUT, OUTPUT}
enum CONNECT_TYPE {INPUT_OUTPUT, OUTPUT_INPUT}
enum KNOB_TYPE {NODE_KNOB, EDGE_KNOB}

static func invert_connect_type(connect_type):
	if connect_type == CONNECT_TYPE.INPUT_OUTPUT:
		return CONNECT_TYPE.OUTPUT_INPUT
	else:
		return CONNECT_TYPE.INPUT_OUTPUT

static func make_bezier_line(start_pos, end_pos):
	var line = Line2D.new()
	var curve = Curve2D.new()
	var ctr_vector = Vector2(abs(end_pos.x - start_pos.x), 0)
	curve.add_point(start_pos, Vector2(0,0), ctr_vector)
	curve.add_point(end_pos, -ctr_vector, Vector2(0,0))
	var points = curve.tessellate()
	for p in points:
		line.add_point(p)
	return line
