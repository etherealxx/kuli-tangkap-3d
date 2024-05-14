extends Node3D
@export var speed = -1
var is_catched := false
#signal catched

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect("catched", _on_catched)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += speed * delta

#func _on_catched():
	#is_catched = true

func catched():
	is_catched = true

func _physics_process(_delta):
	if is_catched:
		if get_scale() < Vector3(0.05, 0.05, 0.05):
			queue_free()
		scale -= Vector3(0.015, 0.015, 0.015)
		
