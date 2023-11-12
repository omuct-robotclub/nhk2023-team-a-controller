extends Node

var _timer := Timer.new()

func _ready() -> void:
    _timer.wait_time = 0.1
    _timer.autostart = true
    _timer.timeout.connect(_loop)
    add_child(_timer)

func _loop() -> void:
    if RobotInterface.enable_wall_tracking:
        Input.vibrate_handheld(50)
