extends Area3D
@export_enum("left", "right") var turn_type : String
@export var toggle_on_other : NodePath
@export var block_trigger := false

var triggered = false
var othertoggled = false

func get_turn_type():
	return turn_type

func trigger():
	if not block_trigger:
		triggered = true
	
func _on_area_entered(_area):
		if toggle_on_other and !othertoggled:
			othertoggled = true
			#print("%s activating %s" % [self.name, get_node(toggle_on_other).name])
			get_node(toggle_on_other).show()
			get_node(toggle_on_other).block_trigger = false
