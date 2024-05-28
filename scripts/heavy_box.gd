extends RigidBody2D

@export var weight = 1

@onready var sprite_2d = $Sprite2D

var vel : Vector2 = Vector2.ZERO
var player : CharacterBody2D = null

func _physics_process(delta):
	var direction = Input.get_axis("move_left", "move_right")
	if player != null and player.current_scale >= weight and (sprite_2d.global_position.x - player.global_position.x) * direction > 0:
		apply_force(Vector2(direction * 200, 0))

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player = body

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player = null
	
