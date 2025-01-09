class_name SicknessComponent
extends Node2D


#region Signals
signal got_sick(illness: String)
#endregion


#region enums/constants
#endregion


#region @export vars
## Number of days to wait before falling sick
@export var min_days = 1
@export var max_days = 4
@export var is_sick = false
#endregion


#region public vars
var illness = ""
#endregion


#region private vars
var _starting_time: float
var _days_to_wait: int
#endregion


#region @onready vars
#endregion


#region built-in methods
func _ready() -> void:
	TimeManager.time_updated.connect(_on_time_manager_time_updated)
	_starting_time = TimeManager.time
	_days_to_wait = randi_range(min_days, max_days)
	
	if is_sick:
		_on_got_sick()


func _process(delta: float) -> void:
	pass
#endregion


#region public methods
func reset():
	_starting_time = TimeManager.time
	is_sick = false
#endregion


#region private methods
func _on_time_manager_time_updated(_day: int, _hour: int, _minute: int):
	var days_passed = TimeManager.to_days(TimeManager.time - _starting_time)
	
	if days_passed >= _days_to_wait and not is_sick:
		_on_got_sick()

func _on_got_sick():
	is_sick = true
	illness = Medicines.get_random_illness()
	got_sick.emit(illness)
#endregion


