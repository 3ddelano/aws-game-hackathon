class_name HitboxComponent
extends Area2D

@export var health_component: HealthComponent

func damage(amt: float):
	health_component.damage(amt)
