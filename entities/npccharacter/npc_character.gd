class_name NpcCharacter
extends CharacterBody2D


@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var move_dir_timer: Timer = $MoveDirTimer
@onready var sprite_2d: Sprite2D = $Sprite2D

var MOVE_SPEED = 8

func _ready() -> void:
	move_dir_timer.timeout.connect(change_move_dir)
	anim_player.speed_scale = 0.7
	change_move_dir()


func change_move_dir():
	if randf() > 0.5:
		velocity.x = MOVE_SPEED if randf() > 0.5 else -MOVE_SPEED
		velocity.y = 0
	else:
		velocity.x = 0
		velocity.y = MOVE_SPEED if randf() > 0.5 else -MOVE_SPEED
	prints("vel", velocity)


func _physics_process(delta: float) -> void:

	if velocity.x < 0:
		anim_player.play("walk_left")
		sprite_2d.flip_h = false
	elif velocity.x > 0:
		anim_player.play("walk_left")
		sprite_2d.flip_h = true

	if velocity.y < 0:
		anim_player.play("walk_up")
	elif velocity.y > 0:
		anim_player.play("walk_down")


	move_and_slide()
