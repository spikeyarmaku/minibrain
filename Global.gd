extends Node

enum PIN_TYPE {INPUT, OUTPUT}
enum CONNECT_TYPE {INPUT_OUTPUT, OUTPUT_INPUT}
enum KNOB_TYPE {NODE_KNOB, EDGE_KNOB}

func invert_connect_type(connect_type):
	if connect_type == CONNECT_TYPE.INPUT_OUTPUT:
		return CONNECT_TYPE.OUTPUT_INPUT
	else:
		return CONNECT_TYPE.INPUT_OUTPUT
