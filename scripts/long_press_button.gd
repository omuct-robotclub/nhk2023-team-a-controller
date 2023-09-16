extends Button
class_name LongPressButton

signal long_pressed()
signal normal_pressed()

@export var long_press_time := 1.0

var _tim: Timer
var _is_longpress := false

func _ready() -> void:
    _tim = Timer.new()
    _tim.one_shot = true
    add_child(_tim)
    _tim.wait_time = long_press_time
    _tim.timeout.connect(
        func():
            self_modulate = Color.AQUA
            _is_longpress = true
    )
    button_down.connect(
        func():
            _is_longpress = false
            _tim.start()
    )
    button_up.connect(
        func():
            self_modulate = Color.WHITE
            _tim.stop()
            if _is_longpress:
                long_pressed.emit()
            else:
                normal_pressed.emit()
    )
