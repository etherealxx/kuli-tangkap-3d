extends Node3D

const chance = [1,1,1,0]
var semen = preload("res://scenes/main_gameplay/semen.tscn")
var batu = preload("res://scenes/main_gameplay/rock.tscn")

@onready var gameoverui = $CanvasLayer/GameOverUI
@onready var character = $maincharacter
@onready var camera = $MainCamera
@onready var gamewinui = $CanvasLayer/GameWinUI
@onready var mainmenuui = $CanvasLayer/MainMenuUI

@export var debugprint := false

func add_to_these_group(node : Node, grouplist : Array[String]):
	for groupname in grouplist:
		node.add_to_group(groupname)

func _on_spawn_timer_timeout():
	if character.state == character.PlayerState.CATCHING:
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


#func tween_camera(tween, property, value):
	
func _ready():
	character.gameover.connect(_on_gameover)
	character.winning.connect(_on_winning)
	character.switchtorunning.connect(switch_to_running)
	mainmenuui.playstart.connect(_on_playstart)
	
	if GlobalVar.restartaftercutscene == true:
		if GlobalVar.restartfromcatching == true:
			switch_to_running()
		else:
			character.state = character.PlayerState.CATCHING
		return
	
	# cutscene
	camera.set_position(Vector3(10.21, 17.845, 36))
	camera.set_rotation_degrees(Vector3(-36.7, 17.3, -25.9))
	var tween = create_tween()
	tween.tween_property(camera, "position", Vector3(0.04, 2.25, 7.78), 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(camera, "rotation_degrees", Vector3(-15, 8.5, 0), 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): mainmenuui.transition.emit())

func _on_playstart():
	var tween = create_tween()
	tween.tween_property(camera, "position", Vector3(0.575, 2.9, 9.55), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(camera, "rotation_degrees", Vector3(-2, 0, 0), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): character.state = character.PlayerState.CATCHING)
	
func _on_gameover():
	get_tree().paused = true
	gameoverui.show()
	
func _on_winning():
	get_tree().paused = true
	gamewinui.show()
	
func _on_debug_button_pressed():
	switch_to_running()
	
func switch_to_running():
	for fallingobject in get_tree().get_nodes_in_group("fallingobject"):
		fallingobject.stopfall = true
	character.change_state(character.PlayerState.CUTSCENE)
	character.anim = character.PlayerAnim.RUNNING
	var tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(camera, "position", Vector3(0.145, 3.7, 8), 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(camera, "rotation",
									Vector3(deg_to_rad(-27), deg_to_rad(180), deg_to_rad(0)), 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(character, "position", Vector3(0.185, 0.405, 10), 1.5).set_delay(1)
	tween.tween_callback(_after_transition_to_running)

func _after_transition_to_running():
	character.change_state(character.PlayerState.RUNNING)
	camera.reparent(character)
	character.get_node("ScoreLabel").hide()
	GlobalVar.restartfromcatching = true
	
func _on_debug_print_interval_timeout():
	#print("%s ; %s" % [$racetrackx2/%WinningBox.triggered, $racetrackx2/%TurnBox6.triggered])
	if character.debugtexttoprint != "" and debugprint:
		print(character.debugtexttoprint)
