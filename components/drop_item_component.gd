class_name DropItemComponent
extends Node2D

@export var scene: PackedScene


func drop_at_position(parent: Node, drop_pos: Vector2) -> void:
	var obj = scene.instantiate()
	obj.global_position = drop_pos
	parent.add_child(obj)
