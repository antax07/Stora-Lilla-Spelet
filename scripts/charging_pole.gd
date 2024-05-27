extends Area2D

signal player_entered
signal player_exited

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body is CharacterBody2D:
		emit_signal("player_entered")

func _on_body_exited(body):
	if body is CharacterBody2D:
		emit_signal("player_exited")
