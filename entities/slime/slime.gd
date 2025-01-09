class_name Slime
extends CharacterBody2D


#region public vars
var move_speed = 35
#endregion


#region private vars
var _anim_playback: AnimationNodeStateMachinePlayback
var _player: Player
var _player_in_area = false
#endregion


#region @onready vars
@onready var _move_dir_timer = $MoveDirTimer
@onready var _anim_tree = $AnimationTree
@onready var _health_component: HealthComponent = $HealthComponent
@onready var _hitbox_component: HitboxComponent = $HitboxComponent
@onready var _sprite_2d: Sprite2D = $Sprite2D
#endregion


#region built-in methods
func _ready():
	_player = get_tree().get_first_node_in_group(&"player")
	_anim_playback = _anim_tree.get(&"parameters/playback")
	_health_component.died.connect(func():
		queue_free()
	)

	_move_dir_timer.timeout.connect(_move_random_dir)
	
	_assign_random_color()
	_hitbox_component.got_damaged.connect(_on_hitbox_component_got_damaged)


func _physics_process(_delta):
	_handle_movement()
#endregion


#region private methods
func _handle_movement():
	if _player and _player_in_area:
		_move_towards_player()

	if velocity:
		_anim_playback.travel(&"Walk")
	else:
		_anim_playback.travel(&"Idle")
	move_and_slide()


func _move_random_dir():
	if _player_in_area: return
	
	if randf() > 0.5:
		velocity.x = move_speed if randf() > 0.5 else -move_speed
		velocity.y = 0
	else:
		velocity.x = 0
		velocity.y = move_speed if randf() > 0.5 else -move_speed


func _move_towards_player():
	var dir_to_player = (_player.global_position - global_position).normalized()
	if global_position.distance_squared_to(_player.global_position) < 200:
		dir_to_player = Vector2()

	velocity = dir_to_player * move_speed
	if velocity:
		_anim_tree.set(&"parameters/Idle/blend_position", dir_to_player)
		_anim_tree.set(&"parameters/Walk/blend_position", dir_to_player)


func _assign_random_color():
	var rand_color = [Color("#42d0d0"), Color("#ff91f8"), 
					Color("#00e743"), Color("#fd8799")].pick_random()
	_sprite_2d.self_modulate = rand_color


func _on_player_range_area_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_in_area = true


func _on_player_range_area_body_exited(body: Node2D) -> void:
	if body is Player:
		_player_in_area = false


func _on_hitbox_component_got_damaged(_amt: int):
	var original_color = _sprite_2d.self_modulate
	
	var tween = get_tree().create_tween()
	tween.tween_property(_sprite_2d, "self_modulate", Color("#ff0000"), 0.08)
	tween.tween_property(_sprite_2d, "self_modulate", original_color, 0.08)
#endregion
