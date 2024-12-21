class_name InteractableComponent
extends Area2D

signal interacted

var player_in_area = false


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = false


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"interact") and player_in_area:
		get_viewport().set_input_as_handled()
		interacted.emit()
