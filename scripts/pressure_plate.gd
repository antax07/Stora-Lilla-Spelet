extends Area2D

@onready var sprite_2d = $Sprite2D
@export var toggle = false
@export var door: NodePath
var is_activated = false

func _ready():
	sprite_2d.frame = 1
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body is CharacterBody2D:
		activate()

func _on_body_exited(body):
	if body is CharacterBody2D and not toggle:
		deactivate()

func activate():
	var door_node = get_node(door)
	if toggle:
		if not is_activated:
			is_activated = true
			sprite_2d.frame = 0
			door_node.open_door()
	else:
		sprite_2d.frame = 0
		door_node.open_door()

func deactivate():
	var door_node = get_node(door)
	if not toggle:
		sprite_2d.frame = 1
		door_node.close_door()
