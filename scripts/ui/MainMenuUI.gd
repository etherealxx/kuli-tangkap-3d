extends Control

@onready var menu_right = $MenuRight
@onready var title = $Title

signal playpressed
signal playstart
signal transition

var menu_to_title_scaling
var viewport_width

func _ready():
	viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	get_tree().get_root().set_min_size(Vector2i(1152, 648))
	transition.connect(_on_transition)
	playpressed.connect(_on_play)
	get_viewport().connect("size_changed", _on_window_resize)
	menu_to_title_scaling = title.size.y / menu_right.size.y
	self.position.x -= viewport_width

func _on_transition():
	var tween = create_tween()
	tween.tween_property(self, "position:x", 0, 1.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_callback(after_transition)
		
func after_transition():
	for node in get_children():
		if node.is_in_group("menubutton"):
			node.safe_to_press.emit()

func _on_play():
	var tween = create_tween()
	tween.tween_property(self, "position:x", -viewport_width, 1.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): playstart.emit())
	
func _on_window_resize():
	#var viewport_reso = get_viewport().get_visible_rect().size
	#viewport_width = viewport_reso.y
	#menu_right.size.y = viewport_width
	#title.size.y = viewport_width * menu_to_title_scaling
	pass
	
