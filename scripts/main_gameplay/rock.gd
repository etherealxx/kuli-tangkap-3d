extends Node3D
@export var speed = -1
var is_catched := false
var catchable_name : String = "semen"
var stopfall := false
#signal catched

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect("catched", _on_catched)
	pass

#func _on_catched():
	#is_catched = true

func catched():
	is_catched = true

func _physics_process(delta):
	if !stopfall:
		position.y += speed * delta
	if is_catched:
		if get_scale() < Vector3(0.5, 0.5, 0.5):
			queue_free()
		scale -= Vector3(0.15, 0.15, 0.15)
		
