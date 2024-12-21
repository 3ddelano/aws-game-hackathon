class_name InteractableComponent
extends Area2D

signal interacted

var player_in_area = false


func enable():
	monitorable = true
	monitoring = true


func disable():
	monitorable = false
	monitoring = false


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = false


func interact():
	interacted.emit()
