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

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_time_counter = 0.0
var jump_buffer_counter = 0.0
var jump_hold_counter = 0.0
var is_wall_sliding = false

@onready var animated_sprite = $AnimatedSprite2D

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
