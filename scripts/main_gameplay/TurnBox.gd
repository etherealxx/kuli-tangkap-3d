extends Area3D
@export_enum("left", "right") var turn_type : String
@export var activate_other : NodePath

func get_turn_type():
	return turn_type

func _on_area_entered(_area):
	if activate_other:
		get_node(activate_other).show()
