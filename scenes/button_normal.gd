extends Area2D

@onready var sprite_2d = $Sprite2D

@export var toggle = false

func _ready():
	sprite_2d.frame = 1

func activate():
	print("Activated!")
	if toggle:
		if sprite_2d.frame == 0:
			sprite_2d.frame = 1
		else:
			sprite_2d.frame = 0
	else:
		_set_frame_temporarily(0, 0.75)

func _set_frame_temporarily(frame_value: int, duration: float):
	sprite_2d.frame = frame_value
	await get_tree().create_timer(duration).timeout
	sprite_2d.frame = 1
