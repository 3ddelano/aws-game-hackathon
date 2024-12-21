extends State

@export var min_wait_time_sec = 1.0
@export var max_wait_time_sec = 7.0

@export var animated_sprite_2d: AnimatedSprite2D


func enter(_prev_state_path: String, _data = {}) -> void:
	animated_sprite_2d.play(&"idle")
	animated_sprite_2d.flip_h = randf() > 0.5

	if randf() > 0.5:
		await get_tree().create_timer(min_wait_time_sec, max_wait_time_sec).timeout

	state_machine.change_state(&"walk")


func _on_idle_timer_timeout():
	state_machine.change_state(&"walk")
