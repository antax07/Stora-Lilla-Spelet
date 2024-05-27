extends Area2D

@onready var sprite_2d = $Sprite2D
@export var door: NodePath
@export var toggle = false
@export var open_time = 0.75

func _ready():
	sprite_2d.frame = 1

func activate():
	var door_node = get_node(door)
	if toggle:
		if sprite_2d.frame == 1:
			sprite_2d.frame = 0
			door_node.open_door()
		else:
			sprite_2d.frame = 1
			door_node.close_door()
	else:
		_set_frame_temporarily(0, open_time)

func _set_frame_temporarily(frame_value: int, duration: float):
	var door_node = get_node(door)
	sprite_2d.frame = frame_value
	door_node.open_door()
	await get_tree().create_timer(duration).timeout
	sprite_2d.frame = 1
	door_node.close_door()
