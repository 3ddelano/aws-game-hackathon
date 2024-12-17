extends Area2D

@onready var lifetime_timer = $LifetimeTimer
@onready var visible_on_screen_notifier_2d = $VisibleOnScreenNotifier2D

var _speed: float
var _direction: Vector2


func _ready():
	lifetime_timer.timeout.connect(func ():
		queue_free()
	)
	visible_on_screen_notifier_2d.screen_exited.connect(func ():
		queue_free()
	)
	area_entered.connect(func (area: Area2D):
		if area is HitboxComponent:
			area.damage(10)
		queue_free()
	)


func shoot(p_direction: Vector2, p_speed: float):
	_direction = p_direction
	_speed = p_speed


func _physics_process(delta):
	position += _direction * _speed * delta
