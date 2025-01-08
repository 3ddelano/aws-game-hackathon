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


func interact():
	interacted.emit()
