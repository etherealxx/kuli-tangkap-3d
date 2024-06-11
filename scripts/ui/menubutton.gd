extends TextureButton

@export_enum("default", "play", "setting", "quit", "retry", "replay", "back") var button_type := "default"

@export var press_prevention := true
var is_being_pressed := false
signal safe_to_press

func _ready():
	if press_prevention:
		is_being_pressed = true # wait for signal
	set_material(get_material().duplicate())
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_up.connect(_on_button_up)
	button_down.connect(_on_button_down)
	pressed.connect(_on_pressed)
	safe_to_press.connect(func(): is_being_pressed = false)

func set_highlight(amount : float):
	get_material().set_shader_parameter("highlight_amount", amount)

func _on_mouse_entered():
	set_highlight(0.2)

func _on_mouse_exited():
	set_highlight(0.0)

func _on_button_up():
	if get_global_rect().has_point(get_local_mouse_position()):
		set_highlight(0.2)
	else:
		set_highlight(0.0)
	
func _on_button_down():
	set_highlight(0.5)

func _on_pressed():
	if !is_being_pressed:
		is_being_pressed = true
		await get_tree().create_timer(0.1, true, true).timeout
		match(button_type):
			"play":
				get_parent().playpressed.emit()
			"setting":
				%SettingsUI.show()
			"retry":
				get_tree().paused = false
				GlobalVar.restartaftercutscene = true
				get_tree().reload_current_scene()
			"replay":
				get_tree().paused = false
				GlobalVar.restartaftercutscene = false
				GlobalVar.restartfromcatching = false
				get_tree().reload_current_scene()
			"quit":
				get_tree().quit()
			"back":
				get_parent().hide()
		is_being_pressed = false
