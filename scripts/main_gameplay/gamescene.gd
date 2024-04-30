extends Node3D

const chance = [1,1,1,0]
var semen = preload("res://scenes/main_gameplay/semen.tscn")
var batu = preload("res://scenes/main_gameplay/rock.tscn")

func _on_spawn_timer_timeout():
	var spawnchance : int = chance.pick_random()
	match (spawnchance):
		0:
			var batu_inst : Node3D = batu.instantiate()
			add_child(batu_inst)
			#semen_inst.scale = Vector3(0.08, 0.08, 0.08)
			batu_inst.position = Vector3(randf_range(-3.0, 3.0), 5.8, 5.65)
		1:
			var semen_inst : Node3D = semen.instantiate()
			add_child(semen_inst)
			#semen_inst.scale = Vector3(0.08, 0.08, 0.08)
			semen_inst.position = Vector3(randf_range(-3.0, 3.0), 5.8, 5.65)
