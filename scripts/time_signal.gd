extends Panel

var elapsed := 0.0

@onready var label: Label = $VBoxContainer/Label
@onready var auto_start: CheckButton = $VBoxContainer/HBoxContainer/AutoStart
@onready var stop: Button = $VBoxContainer/HBoxContainer/Stop
@onready var start: Button = $VBoxContainer/HBoxContainer/Start

var started := false
var _notify_state := 0

func _ready() -> void:
    start.pressed.connect(
        func() -> void:
            _notify_state = 0
            elapsed = 0.0
            started = true
    )
    stop.pressed.connect(
        func() -> void:
            started = false
    )

func _update_label() -> void:
    var minutes := int(elapsed) / 60
    var seconds := fmod(elapsed, 60.0)
    label.text = "%d:%04.1f" % [minutes, seconds]

func _vibrate() -> void:
    var prev_notify_state = _notify_state
    _notify_state = int(elapsed) / 10
    if prev_notify_state == _notify_state: return
    var num_first := _notify_state / 6
    var num_second := _notify_state % 6
    
    for i in range(num_first):
        Input.vibrate_handheld(100)
        await get_tree().create_timer(0.2).timeout
    
    await get_tree().create_timer(0.4).timeout
    
    for i in range(num_second):
        Input.vibrate_handheld(50)
        await get_tree().create_timer(0.15).timeout

func _process(delta: float) -> void:
    if (not started) and auto_start.button_pressed:
        if RobotInterface.target_linear_velocity.length() > 0.01:
            _notify_state = 0
            elapsed = 0.0
            started = true

    if started:
        elapsed += delta
        _update_label()
#        _vibrate()
