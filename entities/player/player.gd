class_name Player
extends CharacterBody2D

@export var move_speed = 100.0
@export var bullet_scene: PackedScene

@export var anim_tree: AnimationTree
@export var shoot_cooldown_timer: Timer

var anim_playback: AnimationNodeStateMachinePlayback


func _ready():
	anim_playback = anim_tree.get("parameters/playback")


func _process(_delta):

	if Input.is_action_pressed("shoot"):
		handle_shoot()


func _physics_process(_delta):
	handle_movement()


func handle_movement():
	#var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input_vector = Vector2()
	if Input.is_action_pressed("move_right"):
		input_vector.x = 1
	elif Input.is_action_pressed("move_left"):
		input_vector.x = -1
	elif Input.is_action_pressed("move_up"):
		input_vector.y = -1
	elif Input.is_action_pressed("move_down"):
		input_vector.y = 1
	velocity = input_vector * move_speed
	move_and_slide()

	if velocity:
		anim_tree.set("parameters/Idle/blend_position", input_vector)
		anim_tree.set("parameters/Walk/blend_position", input_vector)
		anim_playback.travel("Walk")
	else:
		anim_playback.travel("Idle")

func handle_shoot():
	if not shoot_cooldown_timer.is_stopped():
		return
	var bullet = bullet_scene.instantiate()
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()

	bullet.position = global_position + direction * 5
	bullet.shoot(direction, 180.0)
	get_tree().get_current_scene().add_child(bullet)

	shoot_cooldown_timer.start()
