extends Node

#region Signals
signal time_updated(day: int, hour: int, minute: int)
signal day_changed(day: int)
#endregion

#region Constants
const HOURS_PER_DAY = 24
const MINUTES_PER_HR = 60
const MINUTES_PER_DAY = HOURS_PER_DAY * MINUTES_PER_HR
const GAME_MINUTE_DURATION: float = TAU / MINUTES_PER_DAY
#endregion

var time_speed = 1.0
var initial_day = 1:
	set(val):
		initial_day = val
		calculate_initial_time()
var initial_hour = 12:
	set(val):
		initial_hour = val
		calculate_initial_time()
var initial_minutes = 30:
	set(val):
		initial_minutes = val
		calculate_initial_time()

var time = 0.0
var current_day = 0
var current_minutes = 0
var current_tick = 0


func _ready() -> void:
	time = calculate_initial_time()
	current_tick = get_process_delta_time()


func _process(delta: float) -> void:
	time += delta * time_speed * GAME_MINUTE_DURATION
	recalculate_time()


func calculate_initial_time() -> float:
	var total_minutes = (initial_day * MINUTES_PER_DAY) + (initial_hour * MINUTES_PER_HR) + initial_minutes
	return total_minutes * GAME_MINUTE_DURATION


func recalculate_time():
	var total_minutes = int(time / GAME_MINUTE_DURATION)
	@warning_ignore("integer_division")
	var new_day = int(total_minutes / MINUTES_PER_DAY)
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	@warning_ignore("integer_division")
	var new_hour = int(current_day_minutes / MINUTES_PER_HR)
	var new_minutes = int(current_day_minutes % MINUTES_PER_HR)

	if current_minutes != new_minutes:
		current_minutes = new_minutes
		time_updated.emit(new_day, new_hour, current_minutes)

	if current_day != new_day:
		current_day = new_day
		day_changed.emit(current_day)
