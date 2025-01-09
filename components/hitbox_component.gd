class_name HitboxComponent
extends Area2D


signal got_damaged(amt: int)


@export var health_component: HealthComponent


func damage(amt: float):
	health_component.damage(amt)
	got_damaged.emit(amt)
