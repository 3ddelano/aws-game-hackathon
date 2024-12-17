class_name HealthComponent
extends Node2D

signal health_changed(old_val: float, new_val: float)
signal died


@export
var MAX_HEALTH: float = 100:
	set(new_max_health):
		MAX_HEALTH = new_max_health
		if health > MAX_HEALTH:
			health = MAX_HEALTH

var health = 0.0


func _ready() -> void:
	health = MAX_HEALTH


func damage(amt: float):
	var old_health = health

	health = max(0, health - amt)
	health = min(MAX_HEALTH, health)

	if health != old_health:
		print("HealthComponent: health changed")
		health_changed.emit(old_health, health)

	if health == 0:
		print("HealthComponent: died")
		died.emit()


func heal(amt: int):
	damage(-amt)


## Returns float between 0-1
func get_health_percentage() -> float:
	return (health * 1.0) / MAX_HEALTH
