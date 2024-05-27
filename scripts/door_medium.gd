extends StaticBody2D

@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D

var is_open = false

func _ready():
	update_door_state()

func open_door():
	if not is_open:
		is_open = true
		update_door_state()

func close_door():
	if is_open:
		is_open = false
		update_door_state()

func update_door_state():
	if is_open:
		sprite_2d.frame = 0
		collision_shape_2d.call_deferred("set", "disabled", true)
	else:
		sprite_2d.frame = 1
		collision_shape_2d.call_deferred("set", "disabled", false)
