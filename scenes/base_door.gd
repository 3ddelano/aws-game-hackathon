extends StaticBody2D

@export var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set initial animation state
	if is_open:
		$AnimatedSprite2D.play("opening")
	else:
		$AnimatedSprite2D.play("closed")

func interact():
	if is_open:
		$AnimatedSprite2D.play("closed")
		is_open = false
	else:
		$AnimatedSprite2D.play("opening")
		is_open = true
