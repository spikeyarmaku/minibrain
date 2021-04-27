extends Control

signal exit()
signal clear()
signal reset()
signal play()
signal pause()
signal step()
signal notes(is_active)

var is_notes_open = false
var is_hovering = false

var control_panel
var btn_exit : TextureButton
var btn_clear : TextureButton
var pnl_title : Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	btn_exit = $ButtonExit
	btn_exit.material.set_shader_param("btn_color", Color(1, 0.25, 0.25, 1))
	btn_exit.connect("pressed", self, "_on_exit_pressed")
	btn_clear = $ButtonClear
	btn_clear.connect("pressed", self, "_on_clear_pressed")
	pnl_title = $PanelTitle
	control_panel = $ControlPanel
	control_panel.connect("reset", self, "_on_reset")
	control_panel.connect("play", self, "_on_play")
	control_panel.connect("pause", self, "_on_pause")
	control_panel.connect("step", self, "_on_step")
	close_notes()

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
	if event is InputEventMouseMotion:
		if pnl_title.get_rect().has_point(event.position) and \
		not is_hovering:
			is_hovering = true
			# Workaround for https://github.com/godotengine/godot/issues/43284
			open_notes()
		elif not pnl_title.get_rect().has_point(event.position) and \
		is_hovering:
			is_hovering = false
		if not $PanelNotes.get_rect().has_point(event.position):
			close_notes()

func set_title(title):
	if title == null:
		$PanelTitle/LabelTitle.text = ""
	else:
		$PanelTitle/LabelTitle.text = title
	
func set_notes(notes):
	if notes == null:
		$PanelNotes/LabelNotes.bbcode_text = ""
	else:
		$PanelNotes/LabelNotes.bbcode_text = notes

func open_notes():
	emit_signal("notes", true)
	$PanelNotes.visible = true
	is_notes_open = true

func close_notes():
	emit_signal("notes", false)
	$PanelNotes.visible = false
	is_notes_open = false
