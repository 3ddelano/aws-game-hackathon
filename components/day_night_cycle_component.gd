class_name DayNightCycleComponent
extends CanvasModulate


@export var initial_day = 1:
	set(val):
		initial_day = val
		TimeManager.initial_day = initial_day


@export var initial_hour = 12:
	set(val):
		initial_hour = val
		TimeManager.initial_hour = initial_hour

@export var initial_minutes = 30:
	set(val):
		initial_minutes = val
		TimeManager.initial_minutes = initial_minutes

@export var gradient_texture: GradientTexture1D


func _ready() -> void:
	TimeManager.initial_day = initial_day
	TimeManager.initial_hour = initial_hour
	TimeManager.initial_minutes = initial_minutes


func _process(delta: float) -> void:
	# sin wave equation
	var value = 0.5 * (sin(TimeManager.time - PI * 0.5) + 1.0)
	color = gradient_texture.gradient.sample(value)
