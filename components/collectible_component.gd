class_name CollectibleComponent
extends Area2D

signal collected(collectible_name: String)


@export var collectible_name: String
@export var queue_free_on_collected = true


func _ready() -> void:
	if collectible_name == "":
		push_error("Collectible name is required.")


	monitoring = false
	await get_tree().create_timer(0.2).timeout
	monitoring = true


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print(&"Collected ", collectible_name)
		collected.emit(collectible_name)
		if queue_free_on_collected:
			get_parent().queue_free()
