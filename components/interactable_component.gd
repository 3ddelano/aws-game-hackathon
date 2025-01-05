class_name InteractableComponent
extends Area2D

signal interacted
signal player_in_area_changed(player_in_area)

var player_in_area = false


func enable():
	monitorable = true
	monitoring = true


func disable():
	monitorable = false
	monitoring = false


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if not player_in_area:
			player_in_area_changed.emit(true)
		player_in_area = true
		


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		if player_in_area:
			player_in_area_changed.emit(false)
		player_in_area = false


func interact():
	interacted.emit()
