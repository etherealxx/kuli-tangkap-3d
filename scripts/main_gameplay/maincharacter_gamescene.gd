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
var changinglane := false

signal gameover
signal switchtorunning

enum PlayerState {CATCHING, CUTSCENE, RUNNING, TETRIS = -1}
enum RunningLane {LEFT, MIDDLE, RIGHT = -1}

var state : PlayerState
var lane : RunningLane

func _ready():
	state = PlayerState.CATCHING
	lane = RunningLane.MIDDLE
	animplyr.play("moving_sideway3", -1, 2.0)
	animplyr.pause()
	print(animplyr.get_current_animation_length())

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
	var tween = create_tween()
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

	tween.tween_property(self, pos_axis_to_change, final_target_position, 0.3)
	tween.tween_callback(func() : change_lane(direction))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	match (state):
		PlayerState.CATCHING:
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
			
		PlayerState.RUNNING:
			velocity.x = running_speed * sin(rotation.y)
			velocity.z = running_speed * cos(rotation.y)
			##TODO benerin biar jalan ke semua jenis rotasi!
			if not changinglane:
				if Input.is_action_just_pressed("ui_left") and lane != RunningLane.LEFT and turn == "straight":
					change_lane_direction("left")
				elif Input.is_action_just_pressed("ui_right") and lane != RunningLane.RIGHT and turn == "straight":
					change_lane_direction("right")
			
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
	lane = RunningLane.MIDDLE
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", turn_degree, 0.5).as_relative().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func() : turn = "straight")
	
#func _on_turn_complete(timer):
	##turn = "straight"
	#timer.queue_free()
	
