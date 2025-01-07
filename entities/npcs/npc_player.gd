## An NPC (Non-Player Character) that moves randomly in four directions
##
## This class implements a basic NPC that can move in four directions (up, down, left, right)
## with random movement patterns. The NPC's movement direction changes periodically based on
## a timer.
##
## Properties:
## - custom_texture: Optional custom texture for the NPC sprite
## - MOVE_SPEED: Movement speed of the NPC (default: 8)
## - is_idle: Boolean to check if the NPC is in idle state
## - idle_animation: Name of the idle animation
## - idle_down_animation: Name of the idle down animation
## - words_to_say: Words that the NPC can say
## - is_phone: Boolean to check if the NPC is using a phone
##
## Signals:
## None
##
## Node Requirements:
## - AnimationPlayer: For playing movement animations
## - MoveDirTimer: Timer for changing movement direction
## - Visuals/Sprite2D: Sprite node for visual representation
##
## Methods:
## - change_move_dir(): Randomly changes the NPC's movement direction
## - _physics_process(_delta): Handles movement and animation updates

class_name npc_player
extends CharacterBody2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var move_dir_timer: Timer = $MoveDirTimer
@onready var sprite_2d: Sprite2D = $Visuals/Sprite2D

@export var custom_texture: Texture2D
@export var MOVE_SPEED: int = 8
@export var is_idle: bool = false
@export var idle_animation: String = "idle_down"
@export var words_to_say: String = "Hello!"
@export var is_phone: bool = false

func _ready() -> void:
	if custom_texture:
		sprite_2d.texture = custom_texture
	else:
		print("custom_texture is not set.")
	move_dir_timer.timeout.connect(change_move_dir)
	anim_player.speed_scale = 0.7
	change_move_dir()

func change_move_dir():
	if is_idle:
		velocity = Vector2.ZERO
	else:
		if randf() > 0.5:
			velocity.x = MOVE_SPEED if randf() > 0.5 else -MOVE_SPEED
			velocity.y = 0
		else:
			velocity.x = 0
			velocity.y = MOVE_SPEED if randf() > 0.5 else -MOVE_SPEED

func _physics_process(_delta: float) -> void:
	if is_phone and is_idle:
		anim_player.play("phone")
	elif is_idle:
		anim_player.play(idle_animation)
	else:
		if velocity.x < 0:
			anim_player.play("walk_left")
			sprite_2d.flip_h = false
		elif velocity.x > 0:
			anim_player.play("walk_left")
			sprite_2d.flip_h = true
		elif velocity.y < 0:
			anim_player.play("walk_up")
		elif velocity.y > 0:
			anim_player.play("walk_down")
		else:
			anim_player.play(idle_animation)

	move_and_slide()
