extends Node3D

var semen = preload("res://scenes/main_gameplay/semen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_spawn_timer_timeout():
	var semen_inst : Node3D = semen.instantiate()
	add_child(semen_inst)
	semen_inst.scale = Vector3(0.08, 0.08, 0.08)
	semen_inst.position = Vector3(randf_range(-3.0, 3.0), 5.8, 5.65)
