extends Control


const SPEED_NORMAL = 5.0
const SPEED_FAST = 100.0
const SPEED_SUPERFAST = 300.0

func _ready() -> void:
	TimeManager.time_updated.connect(_on_time_updated)
	%NormalSpeedButton.pressed.connect(_on_normal_speed_pressed)
	%FastSpeedButton.pressed.connect(_on_fast_speed_pressed)
	%SuperFastSpeedButton.pressed.connect(_on_superfast_speed_pressed)


func _on_time_updated(day: int, hour: int, minute: int):
	%DayLabel.text = "DAY %s" % day
	%TimeLabel.text = "%02d:%02d" % [hour, minute]

func _on_normal_speed_pressed():
	TimeManager.time_speed = SPEED_NORMAL

func _on_fast_speed_pressed():
	TimeManager.time_speed = SPEED_FAST

func _on_superfast_speed_pressed():
	TimeManager.time_speed = SPEED_SUPERFAST
