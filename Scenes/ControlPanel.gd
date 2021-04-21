extends HBoxContainer

signal reset()
signal play()
signal pause()
signal step()

# The simulation can be in one of two states at all times: "Running" or
# "Stopped".

# Four buttons:
# Play - starts the simulation
#     - always enabled, disables Step
# Reset - resets the simulation
#     - always enabled
# Stop - Stops the simulation
#     - always enabled, enables Step
# Step - Plays one single frame of simulation
#     - only enabled if the simulation is stopped

# Default is "Stop"

var btn_reset : TextureButton
var btn_play : TextureButton
var btn_pause : TextureButton
var btn_step : TextureButton

var active_color = Color(0, 0.5, 1, 1)
var default_color = Color(1, 1, 1, 1)

func set_paused():
	btn_pause.material.set_shader_param("btn_color", active_color)
	btn_play.material.set_shader_param("btn_color", default_color)

func set_running():
	btn_play.material.set_shader_param("btn_color", active_color)
	btn_pause.material.set_shader_param("btn_color", default_color)

func _ready():
	btn_reset = $ButtonReset
	btn_play  = $ButtonPlay
	btn_pause = $ButtonPause
	btn_step  = $ButtonStep
	btn_reset.connect("pressed", self, "_on_reset_pressed")
	btn_play.connect( "pressed", self, "_on_play_pressed")
	btn_pause.connect("pressed", self, "_on_pause_pressed")
	btn_step.connect( "pressed", self, "_on_step_pressed")

func _on_reset_pressed():
	emit_signal("reset")
	
func _on_play_pressed():
	btn_step.disabled = true
	emit_signal("play")

func _on_pause_pressed():
	btn_step.disabled = false
	emit_signal("pause")

func _on_step_pressed():
	emit_signal("step")
