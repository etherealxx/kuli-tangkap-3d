extends CharacterBody3D

@onready var animplyr : AnimationPlayer = $AnimationPlayer

const JUMP_VELOCITY := 4.5

var speed := 7.0
var score := 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	animplyr.play("moving_sideway3", -1, 2.0)
	animplyr.pause()
	print(animplyr.get_current_animation_length())

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
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
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	if animplyr.get_current_animation() == "moving_sideway3":
		if animplyr.get_current_animation_position() > 0.5:
			speed = 1.5
		else:
			speed = 3.0

func add_score():
	score += 1
	$ScoreLabel.set_text("Score: " + str(score))

func _on_area_3d_body_entered(body):
	if body is StaticBody3D:
		body.catched()
		add_score()
