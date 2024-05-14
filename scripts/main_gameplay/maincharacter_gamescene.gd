extends CharacterBody3D

#@onready var semen_ref = load
@onready var animplyr : AnimationPlayer = $AnimationPlayer

const JUMP_VELOCITY := 4.5

var moving_while_catching_speed := 7.0
var running_speed := 6.0
var score := 0
var turn = "straight"
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal gameover
signal switchtorunning

enum PlayerState {CATCHING, CUTSCENE, RUNNING, TETRIS = -1}

var state : PlayerState

func _ready():
	state = PlayerState.CATCHING
	animplyr.play("moving_sideway3", -1, 2.0)
	animplyr.pause()
	print(animplyr.get_current_animation_length())

func change_state(statename : PlayerState):
	state = statename

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
	if state == PlayerState.CATCHING:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * moving_while_catching_speed
			print(direction.x)
			if direction.x < 0: # -1
				animplyr.play("moving_sideway3")
			if direction.x > 0: # 1
				#animplyr.play_backwards("moving_sideway3")
				animplyr.play("moving_sideway3", -1, -1.0)
			print(animplyr.get_current_animation_position())
			#velocity.z = direction.z * SPEED
		else:
			#animplyr.play("IdleHandsUp")
			animplyr.pause()
			velocity.x = move_toward(velocity.x, 0, moving_while_catching_speed)
			velocity.z = move_toward(velocity.z, 0, moving_while_catching_speed)
			
	elif state == PlayerState.RUNNING:
		velocity.x = running_speed * sin(rotation.y)
		velocity.z = running_speed * cos(rotation.y)
		print("rotation degree: %f ; X: %f ; Z: %f" % [rotation_degrees.y, velocity.x, velocity.z])
		#match turn:
			#"left":
				#rotation_degrees.y += 1
			#"right":
				#rotation_degrees.y -= 1
	
	if turn == "straight":
		move_and_slide()
	
	if state == PlayerState.CATCHING:
		if animplyr.get_current_animation() == "moving_sideway3":
			if animplyr.get_current_animation_position() > 0.5:
				moving_while_catching_speed = 1.5
			else:
				moving_while_catching_speed = 3.0

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
		turn = area.get_turn_type()
		print("turning to: " + turn)
		rotate_player()
		#var turntimer : Timer = Timer.new()
		#turntimer.timeout.connect(_on_turn_complete.bind(turntimer))
		#turntimer.one_shot = true
		#add_child(turntimer)
		#turntimer.start(1.0)

func rotate_player():
	var turn_degree
	match turn:
		"left":
			turn_degree = 90
		"right":
			turn_degree = -90
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", turn_degree, 0.5).as_relative().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func() : turn = "straight")
	
#func _on_turn_complete(timer):
	##turn = "straight"
	#timer.queue_free()
	
