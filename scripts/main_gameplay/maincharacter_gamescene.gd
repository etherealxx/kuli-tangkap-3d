extends CharacterBody3D

#@onready var semen_ref = load
@onready var animplyr : AnimationPlayer = $maincharacter/AnimationPlayer #$AnimationPlayer
@onready var animtree : AnimationTree = $AnimationTree

const JUMP_VELOCITY := 9.0

var moving_while_catching_speed := 1.5
var running_speed := 6.0
var score := 0
var turn = "straight"
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2
var changinglane := false
var debugtexttoprint := ""

signal gameover
signal switchtorunning
signal winning

enum PlayerState {MENU, CATCHING, CUTSCENE, RUNNING, TETRIS = -1}
enum RunningLane {LEFT, MIDDLE, RIGHT = -1}
enum PlayerAnim {IDLE, MOVING, RUNNING, JUMP = -1}

var state : PlayerState
var lane : RunningLane
var anim : PlayerAnim

var animblendvalue = [0,0,0,0]

func _ready():
	state = PlayerState.MENU # PlayerState.CATCHING
	lane = RunningLane.MIDDLE
	anim = PlayerAnim.IDLE
	#print(str(animtree.get_property_list()))
	#animplyr.play("moving_sideway3", -1, 2.0)
	#animplyr.pause()
	#print(animplyr.get_current_animation_length())

func change_state(statename : PlayerState):
	state = statename

func change_lane(movetype : String):
	match movetype:
		"left":
			if lane == RunningLane.RIGHT: lane = RunningLane.MIDDLE
			elif lane == RunningLane.MIDDLE: lane = RunningLane.LEFT
		"right":
			if lane == RunningLane.LEFT: lane = RunningLane.MIDDLE
			elif lane == RunningLane.MIDDLE: lane = RunningLane.RIGHT
	changinglane = false

func change_lane_direction(direction: String):
	changinglane = true
	var target_position = position
	var pos_axis_to_change : String
	var final_target_position
	# Normalize the rotation to range 0 to 2*PI
	var normalized_rotation = fmod(rotation.y, 2 * PI)
	if normalized_rotation < 0:
		normalized_rotation += 2 * PI

	# Define a small tolerance for rotation comparison
	var tolerance = 0.1

	if abs(normalized_rotation - 0) < tolerance or abs(normalized_rotation - 2 * PI) < tolerance:
		target_position.x += 2.0 if direction == "left" else -2.0
		pos_axis_to_change = "position:x"
		final_target_position = target_position.x
	elif abs(normalized_rotation - PI / 2) < tolerance:
		target_position.z += -2.0 if direction == "left" else 2.0
		pos_axis_to_change = "position:z"
		final_target_position = target_position.z
	elif abs(normalized_rotation - PI) < tolerance:
		target_position.x += -2.0 if direction == "left" else 2.0
		pos_axis_to_change = "position:x"
		final_target_position = target_position.x
	elif abs(normalized_rotation - 3 * PI / 2) < tolerance:
		target_position.z += 2.0 if direction == "left" else -2.0
		pos_axis_to_change = "position:z"
		final_target_position = target_position.z
	
	if not pos_axis_to_change or not final_target_position:
		return
		
	var tween = create_tween()
	tween.tween_property(self, pos_axis_to_change, final_target_position, 0.3)
	tween.tween_callback(func() : change_lane(direction))

func animlerp(array : Array, delta):
	animblendvalue = [
		lerpf(animblendvalue[0], array[0], 15*delta),
		lerpf(animblendvalue[1], array[1], 15*delta),
		lerpf(animblendvalue[2], array[2], 15*delta),
		lerpf(animblendvalue[3], array[3], 15*delta)
	]

func handle_anim(delta):
	if state == PlayerState.MENU:
		animlerp([0,0,0,0], delta)
	else:
		match (anim):
			PlayerAnim.IDLE:
				animlerp([1,0,0,0], delta)
			PlayerAnim.MOVING:
				animlerp([1,1,0,0], delta)
			PlayerAnim.RUNNING:
				animlerp([1,0,1,0], delta)
			PlayerAnim.JUMP:
				animlerp([1,0,0,1], delta)
	
	animtree["parameters/IdleBlend/blend_amount"] = animblendvalue[0]
	animtree["parameters/MoveBlend/blend_amount"] = animblendvalue[1]
	animtree["parameters/RunBlend/blend_amount"] = animblendvalue[2]
	animtree["parameters/JumpBlend/blend_amount"] = animblendvalue[3]
	
func _physics_process(delta):
	#print(str(animtree["parameters/jumping/time"]))
	handle_anim(delta)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	match (state):
		PlayerState.CATCHING:
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction:
				velocity.x = direction.x * moving_while_catching_speed
				anim = PlayerAnim.MOVING
				#print(direction.x)
				if direction.x < 0: # -1
					#animplyr.play("moving_sideway3")
					animtree["parameters/TimeScale/scale"] = 1
				if direction.x > 0: # 1
					#animplyr.play("moving_sideway3", -1, -1.0)
					animtree["parameters/TimeScale/scale"] = -1
				#print(animplyr.get_current_animation_position())
				#velocity.z = direction.z * SPEED
			else:
				#animplyr.play("IdleHandsUp")
				#animplyr.pause()
				anim = PlayerAnim.IDLE
				velocity.x = move_toward(velocity.x, 0, moving_while_catching_speed)
				velocity.z = move_toward(velocity.z, 0, moving_while_catching_speed)
			
		PlayerState.RUNNING:
			velocity.x = running_speed * sin(rotation.y)
			velocity.z = running_speed * cos(rotation.y)
			##TODO benerin biar jalan ke semua jenis rotasi!
			if not changinglane:
				if Input.is_action_just_pressed("ui_left") and lane != RunningLane.LEFT:
					change_lane_direction("left")
				elif Input.is_action_just_pressed("ui_right") and lane != RunningLane.RIGHT:
					change_lane_direction("right")
				## Handle jump.
				elif Input.is_action_just_pressed("ui_up") and is_on_floor():
					velocity.y = JUMP_VELOCITY
					animtree["parameters/jumping/time"] = 0
					anim = PlayerAnim.JUMP
					#animplyr.play("Jump")
			if anim == PlayerAnim.JUMP:
				#if abs(animtree["parameters/jumping/time"] - 1.3) < 0.001:
				if animtree["parameters/jumping/time"] > 1.299:
					anim = PlayerAnim.RUNNING
			debugtexttoprint = "rotation degree: %f ; X: %f ; Z: %f" % [rotation_degrees.y, velocity.x, velocity.z]
	
	if turn == "straight":
		move_and_slide()
	
	match (state):
		PlayerState.CATCHING:
			#if animtree["parameters/MoveBlend/blend_amount"] == 1.0:
			if animtree["parameters/moveside/time"]: # and animtree["parameters/MoveBlend/blend_amount"]
				#if abs(animtree["parameters/MoveBlend/blend_amount"] - 1.0) < 0.001:
					if animtree["parameters/moveside/time"] > 0.5:
						moving_while_catching_speed = 1.5
					else:
						moving_while_catching_speed = 3.0
		#PlayerState.RUNNING:
			#if animplyr.get_current_animation() == "Jump":
				#var animpos = animplyr.get_current_animation_position()
				##if animpos < 0.5 or animpos > 2.0:
					##animplyr.speed_scale = 2.5
				##else:
					##animplyr.speed_scale = 1.0
					
func add_score():
	score += 1
	$ScoreLabel.set_text("Score: " + str(score))

func _on_catch_hitbox_body_entered(body):
	if body is StaticBody3D and body.is_in_group("catchable") and state == PlayerState.CATCHING:
		body.catched()
		add_score()
		if score >= 10:
			switchtorunning.emit()

func _on_death_hitbox_body_entered(body):
	if body is StaticBody3D and body.is_in_group("cankill") and state == PlayerState.CATCHING:
		gameover.emit()

func _on_destroy_hitbox_body_entered(body):
	if body is StaticBody3D:
		if body.is_in_group("destroyable") and state == PlayerState.CATCHING:
			body.catched()

func _on_destroy_hitbox_area_entered(area): #bottom part of body
	if area.is_in_group("turnbox"):
		if !area.triggered and !area.block_trigger:
			area.trigger() # trigger turning
			turn = area.get_turn_type()
			#print("triggered %s" % area.name)
			#print("turning to: " + turn)
			rotate_player()
		#var turntimer : Timer = Timer.new()
		#turntimer.timeout.connect(_on_turn_complete.bind(turntimer))
		#turntimer.one_shot = true
		#add_child(turntimer)
		#turntimer.start(1.0)
	elif area.is_in_group("deathcolliders"):
		gameover.emit()
	elif area.is_in_group("winningbox"):
		if !area.triggered and !area.block_trigger:
			winning.emit()
		
func after_rotate():
	lane = RunningLane.MIDDLE
	turn = "straight"
	changinglane = false
	
func rotate_player():
	changinglane = true
	var turn_degree
	match turn:
		"left":
			turn_degree = 90
		"right":
			turn_degree = -90
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", turn_degree, 0.5).as_relative().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(after_rotate)
	
#func _on_turn_complete(timer):
	##turn = "straight"
	#timer.queue_free()
	
