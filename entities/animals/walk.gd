extends State


@export var animated_sprite_2d: AnimatedSprite2D
@export var navigation_agent_2d: NavigationAgent2D
@export var character_body_2d: CharacterBody2D

@export var min_speed = 5.0
@export var max_speed = 10.0


var walk_speed: float


func init() -> void:
	navigation_agent_2d.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)


func enter(_prev_state_path: String, _data = {}) -> void:
	animated_sprite_2d.play(&"walk")
	_set_walk_target()


func process_physics(_delta: float):
	# Do not query when the map has never synchronized and is empty
	if not NavigationServer2D.map_get_iteration_id(navigation_agent_2d.get_navigation_map()):
		return

	if navigation_agent_2d.is_navigation_finished():
		_on_target_reached()
		return


	var next_path_position = navigation_agent_2d.get_next_path_position()
	var target_direction = character_body_2d.global_position.direction_to(next_path_position)
	var desired_velocity = target_direction * walk_speed

	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.velocity = desired_velocity
	else:
		_on_navigation_agent_2d_velocity_computed(desired_velocity)


func _on_target_reached():
	if randf() > 0.5:
		_set_walk_target()
	else:
		character_body_2d.velocity = Vector2.ZERO
		state_machine.change_state(&"idle")


func _set_walk_target():
	var target_position = NavigationServer2D.map_get_random_point(navigation_agent_2d.get_navigation_map(), navigation_agent_2d.navigation_layers, false)
	navigation_agent_2d.target_position = target_position
	walk_speed = randf_range(min_speed, max_speed)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	animated_sprite_2d.flip_h = safe_velocity.x < 0
	character_body_2d.velocity = safe_velocity
	character_body_2d.move_and_slide()
