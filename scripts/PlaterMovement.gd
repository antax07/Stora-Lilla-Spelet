extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var gravity = 300 

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# Collision shapes for different sizes
@onready var collision_shape_big = $CollisionShapeBig
@onready var collision_shape_normal = $CollisionShapeNormal
@onready var collision_shape_small = $CollisionShapeSmall

# The AnimatedSprite2D node
@onready var animated_sprite = $AnimatedSprite2D

# The TextureProgressBar node
@onready var battery_progress_bar = $UI/VBoxContainer/TextureProgressBar

# UI elements for delay
@onready var delay_label = $UI/VBoxContainer/DelayLabel
@onready var increase_delay_button = $UI/VBoxContainer/IncreaseDelayButton
@onready var decrease_delay_button = $UI/VBoxContainer/DecreaseDelayButton
