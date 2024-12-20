class_name Chicken
extends CharacterBody2D


@export var animated_sprite_2d: AnimatedSprite2D
@export var idle_timer: Timer
@export var navigation_agent_2d: NavigationAgent2D

@export var min_speed = 5.0
@export var max_speed = 10.0

@export var min_idle_wait_time_sec = 1.0
@export var max_idle_wait_time_sec = 7.0


enum States {
	IDLE,
	WALK
}


var state = States.IDLE
var walk_speed: float


func _ready() -> void:
	_setup_initial_state.call_deferred()


func _setup_initial_state():
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

	animated_sprite_2d.flip_h = randf() > 0.5
	if randf() > 0.5:
		_change_state(States.IDLE)
	else:
		_change_state(States.WALK)


func _on_idle_timer_timeout() -> void:
	_change_state(States.WALK)


func _change_state(new_state: States):
	state = new_state
	match state:
		States.IDLE:
			animated_sprite_2d.play("idle")
			idle_timer.wait_time = randf_range(min_idle_wait_time_sec, max_idle_wait_time_sec)
			idle_timer.start()
		States.WALK:
			animated_sprite_2d.play("walk")
			_set_walk_target()


func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			pass
		States.WALK:
			if navigation_agent_2d.is_navigation_finished():
				if randf() > 0.5:
					_set_walk_target()
				else:
					velocity = Vector2.ZERO
					_change_state(States.IDLE)
				return

			var target_position = navigation_agent_2d.get_next_path_position()
			var target_direction = global_position.direction_to(target_position)
			animated_sprite_2d.flip_h = target_direction.x < 0

			var desired_velocity = target_direction * walk_speed
			if navigation_agent_2d.avoidance_enabled:
				navigation_agent_2d.velocity = desired_velocity
			else:
				velocity = desired_velocity
				move_and_slide()


func _set_walk_target():
	var target_position = NavigationServer2D.map_get_random_point(navigation_agent_2d.get_navigation_map(), navigation_agent_2d.navigation_layers, false)
	navigation_agent_2d.target_position = target_position
	walk_speed = randf_range(min_speed, max_speed)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
