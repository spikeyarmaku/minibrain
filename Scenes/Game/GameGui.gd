extends Control

signal exit()
signal clear()
signal reset()
signal play()
signal pause()
signal step()
signal notes(is_active)

var notes
var title

var control_panel
var btn_exit : TextureButton
var btn_clear : TextureButton
var btn_notes : TextureButton

# Called when the node enters the scene tree for the first time.
func _ready():
	btn_exit = $ButtonExit
	btn_exit.material.set_shader_param("btn_color", Color(1, 0.25, 0.25, 1))
	btn_exit.connect("pressed", self, "_on_exit_pressed")
	btn_clear = $ButtonClear
	btn_clear.connect("pressed", self, "_on_clear_pressed")
	btn_notes = $ButtonNotes
	btn_notes.connect("pressed", self, "_on_notes_pressed")
	control_panel = $ControlPanel
	control_panel.connect("reset", self, "_on_reset")
	control_panel.connect("play", self, "_on_play")
	control_panel.connect("pause", self, "_on_pause")
	control_panel.connect("step", self, "_on_step")
	$PanelNotes.visible = false

func _on_exit_pressed():
	emit_signal("exit")

func _on_clear_pressed():
	emit_signal("clear")

func _on_reset():
	emit_signal("reset")

func _on_play():
	emit_signal("play")

func _on_pause():
	emit_signal("pause")

func _on_step():
	emit_signal("step")

func set_running():
	control_panel.set_running()

func set_paused():
	control_panel.set_paused()

func _input(event):
	if not $PanelNotes.get_rect().has_point(event.position):
		close_notes()

func _on_notes_pressed():
	$PanelNotes/LabelNotes.bbcode_text = notes
	$PanelNotes/LabelTitle.text = title
	$PanelNotes.visible = not $PanelNotes.visible
	emit_signal("notes", $PanelNotes.visible)

func close_notes():
	$PanelNotes.visible = false
	emit_signal("notes", false)
