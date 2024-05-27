extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const WALL_JUMP_VELOCITY = Vector2(300.0, -500.0)
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.2
const ACCELERATION = 2000.0
const DECELERATION = 1500.0
const AIR_CONTROL = 0.3
const JUMP_HOLD_TIME = 0.2
const WALL_SLIDE_SPEED = 100.0

# Constants for sprite sizes
const BIG_SCALE = 2.0
const NORMAL_SCALE = 1.0
const SMALL_SCALE = 0.5

# SpriteFrames for different sizes
@export var sprite_frames_big: SpriteFrames
@export var sprite_frames_normal: SpriteFrames
@export var sprite_frames_small: SpriteFrames

# Variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_time_counter = 0.0
var jump_buffer_counter = 0.0
var jump_hold_counter = 0.0
var is_wall_sliding = false

# Collision shapes for different sizes
@onready var collision_shape_big = $CollisionShapeBig
@onready var collision_shape_normal = $CollisionShapeNormal
@onready var collision_shape_small = $CollisionShapeSmall

# The AnimatedSprite2D node
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Ensure only the normal collision shape is active initially
	set_collision_shape(NORMAL_SCALE)

func set_collision_shape(scale):
	collision_shape_big.disabled = true
	collision_shape_normal.disabled = true
	collision_shape_small.disabled = true

	if scale == BIG_SCALE:
		collision_shape_big.disabled = false
		animated_sprite.frames = sprite_frames_big
	elif scale == NORMAL_SCALE:
		collision_shape_normal.disabled = false
		animated_sprite.frames = sprite_frames_normal
	elif scale == SMALL_SCALE:
		collision_shape_small.disabled = false
		animated_sprite.frames = sprite_frames_small

func _on_button_big_pressed():
	set_collision_shape(BIG_SCALE)

func _on_button_normal_pressed():
	set_collision_shape(NORMAL_SCALE)

func _on_button_small_pressed():
	set_collision_shape(SMALL_SCALE)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		coyote_time_counter = COYOTE_TIME
		is_wall_sliding = false
	else:
		coyote_time_counter -= delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer_counter = JUMP_BUFFER_TIME
	
	if jump_buffer_counter > 0:
		jump_buffer_counter -= delta

	if Input.is_action_just_released("jump"):
		if velocity.y < 0:
			velocity.y *= 0.5

	if is_on_wall() and not is_on_floor():
		is_wall_sliding = true
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
		animated_sprite.play("fall")

	if is_on_wall() and not is_on_floor() and Input.is_action_just_pressed("jump"):
		var wall_dir = 0
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision.get_normal().x != 0:
				wall_dir = -sign(collision.get_normal().x)
				break

		velocity = Vector2(-WALL_JUMP_VELOCITY.x * wall_dir, WALL_JUMP_VELOCITY.y)
		jump_buffer_counter = 0
		coyote_time_counter = 0
		animated_sprite.play("jump")
		if wall_dir > 0:
			animated_sprite.flip_h = true
		elif wall_dir < 0:
			animated_sprite.flip_h = false

	if jump_buffer_counter > 0 and coyote_time_counter > 0:
		velocity.y = JUMP_VELOCITY
		jump_hold_counter = JUMP_HOLD_TIME
		jump_buffer_counter = 0
		coyote_time_counter = 0
		animated_sprite.play("jump")

	if Input.is_action_pressed("jump") and jump_hold_counter > 0:
		jump_hold_counter -= delta
	else:
		jump_hold_counter = 0

	var direction = Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	if direction != 0:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
			animated_sprite.play("run")
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * AIR_CONTROL * delta)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
			animated_sprite.play("idle")
		else:
			velocity.x = move_toward(velocity.x, 0, DECELERATION * AIR_CONTROL * delta)

	move_and_slide()

	if not is_on_floor() and velocity.y > 0:
		animated_sprite.play("fall")


