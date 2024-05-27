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

const BIG_SCALE = 2.0
const NORMAL_SCALE = 1.0
const SMALL_SCALE = 0.5

const BATTERY_MAX = 3
const BATTERY_DRAIN = 1

const DELAY_MIN = 0
const DELAY_MAX = 10
const DELAY_STEP = 1

@export var sprite_frames_big: SpriteFrames
@export var sprite_frames_normal: SpriteFrames
@export var sprite_frames_small: SpriteFrames

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_time_counter = 0.0
var jump_buffer_counter = 0.0
var jump_hold_counter = 0.0
var is_wall_sliding = false
var battery_level = BATTERY_MAX
var battery_enabled = true
var delay_time = 0
var current_scale = NORMAL_SCALE
var target_scale = NORMAL_SCALE
var scale_change_timer = 0.0
var is_scaling = false
var near_charging_pole = false

@onready var collision_shape_big = $CollisionShapeBig
@onready var collision_shape_normal = $CollisionShapeNormal
@onready var collision_shape_small = $CollisionShapeSmall

@onready var animated_sprite = $AnimatedSprite2D
@onready var battery_progress_bar = $UI/VBoxContainer/TextureProgressBar
@onready var delay_label = $UI/VBoxContainer/DelayLabel
@onready var increase_delay_button = $UI/VBoxContainer/IncreaseDelayButton
@onready var decrease_delay_button = $UI/VBoxContainer/DecreaseDelayButton

func _ready():
	set_collision_shape(NORMAL_SCALE)
	update_battery_ui()
	update_delay_ui()
	increase_delay_button.connect("pressed", _on_increase_delay_button_pressed)
	decrease_delay_button.connect("pressed", _on_decrease_delay_button_pressed)
	var charging_pole = get_node("../ChargingPole")
	charging_pole.connect("player_entered", _on_player_entered)
	charging_pole.connect("player_exited", _on_player_exited)

func set_collision_shape(scale):
	if battery_enabled and battery_level <= 0:
		return

	if not battery_enabled and not near_charging_pole:
		return

	if scale == current_scale:
		return

	target_scale = scale

	if delay_time > 0:
		is_scaling = true
		scale_change_timer = delay_time
	else:
		apply_scale_change()

func apply_scale_change():
	collision_shape_big.disabled = true
	collision_shape_normal.disabled = true
	collision_shape_small.disabled = true

	if target_scale == BIG_SCALE:
		collision_shape_big.disabled = false
		animated_sprite.frames = sprite_frames_big
	elif target_scale == NORMAL_SCALE:
		collision_shape_normal.disabled = false
		animated_sprite.frames = sprite_frames_normal
	elif target_scale == SMALL_SCALE:
		collision_shape_small.disabled = false
		animated_sprite.frames = sprite_frames_small

	current_scale = target_scale

	if battery_enabled:
		battery_level -= BATTERY_DRAIN
		battery_level = max(battery_level, 0)
		update_battery_ui()

	is_scaling = false

func update_battery_ui():
	if battery_progress_bar:
		battery_progress_bar.value = (float(battery_level) / BATTERY_MAX) * 100
	if not battery_enabled:
		battery_progress_bar.value = 0

func update_delay_ui():
	delay_label.text = str(delay_time) + " seconds"

func recharge_battery():
	battery_level = BATTERY_MAX
	update_battery_ui()

func _on_increase_delay_button_pressed():
	if delay_time < DELAY_MAX:
		delay_time += DELAY_STEP
		update_delay_ui()

func _on_decrease_delay_button_pressed():
	if delay_time > DELAY_MIN:
		delay_time -= DELAY_STEP
		update_delay_ui()

func _on_button_big_pressed():
	set_collision_shape(BIG_SCALE)

func _on_button_normal_pressed():
	set_collision_shape(NORMAL_SCALE)

func _on_button_small_pressed():
	set_collision_shape(SMALL_SCALE)
	
func _process(delta):
	if Input.is_action_just_pressed("debug_1"):
		if battery_enabled:
			battery_enabled = false
		else:
			battery_enabled = true
			battery_level = BATTERY_MAX
	if Input.is_action_just_pressed("interact"):
		var interactables = get_tree().get_nodes_in_group("interactable")
		for interactable in interactables:
			if global_position.distance_to(interactable.global_position) < 20:
				interactable.activate()

func _physics_process(delta):
	update_battery_ui()
	
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

	if is_scaling:
		scale_change_timer -= delta
		if scale_change_timer <= 0:
			apply_scale_change()

func _on_player_entered():
	near_charging_pole = true
	if battery_enabled:
		recharge_battery()
	else:
		battery_level = BATTERY_MAX
		update_battery_ui()

func _on_player_exited():
	near_charging_pole = false
	if not battery_enabled:
		battery_level = 0
		update_battery_ui()
