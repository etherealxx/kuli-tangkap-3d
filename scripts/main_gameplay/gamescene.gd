extends Node3D

const chance = [1,1,1,0]
var semen = preload("res://scenes/main_gameplay/semen.tscn")
var batu = preload("res://scenes/main_gameplay/rock.tscn")

@onready var gameoverui = $CanvasLayer/GameOverUI
@onready var character = $maincharacter
@onready var camera = $Camera3D


func add_to_these_group(node : Node, grouplist : Array[String]):
	for groupname in grouplist:
		node.add_to_group(groupname)

func _on_spawn_timer_timeout():
	var spawnchance : int = chance.pick_random()
	match (spawnchance):
		0:
			var batu_inst : Node3D = batu.instantiate()
			add_child(batu_inst)
			#semen_inst.scale = Vector3(0.08, 0.08, 0.08)
			batu_inst.position = Vector3(randf_range(-3.0, 3.0), 5.8, 5.65)
			add_to_these_group(batu_inst, ["cankill", "destroyable"])
		1:
			var semen_inst : Node3D = semen.instantiate()
			add_child(semen_inst)
			#semen_inst.scale = Vector3(0.08, 0.08, 0.08)
			semen_inst.position = Vector3(randf_range(-3.0, 3.0), 5.8, 5.65)
			add_to_these_group(semen_inst, ["catchable", "destroyable"])

func _ready():
	character.gameover.connect(_on_gameover)

func _on_gameover():
	get_tree().paused = true
	gameoverui.show()
	
func _on_debug_button_pressed():
	character.change_state(character.PlayerState.CUTSCENE)
	var tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(camera, "position", Vector3(0.145, 3.7, 8), 1.5)
	tween.parallel().tween_property(camera, "rotation",
									Vector3(deg_to_rad(-27), deg_to_rad(180), deg_to_rad(0)), 1.5)
	tween.parallel().tween_property(character, "position", Vector3(0.185, 0.405, 10), 1.5)
	tween.tween_callback(func() : character.change_state(character.PlayerState.RUNNING))
