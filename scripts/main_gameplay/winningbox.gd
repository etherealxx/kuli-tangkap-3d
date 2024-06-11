extends Area3D
@export_enum("left", "right") var turn_type : String
@export var toggle_on_other : NodePath
@export var activated := false

func get_turn_type():
	return turn_type

func activate():
	activated = true
	
func _on_area_entered(_area):
	if not activated:
		if toggle_on_other:
			get_node(toggle_on_other).show()
			get_node(toggle_on_other).activated = false
