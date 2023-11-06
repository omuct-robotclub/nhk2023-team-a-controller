extends Panel

@onready var check_button: CheckButton = $CheckButton

func _ready() -> void:
    check_button.toggled.connect(
        func(button_pressed: bool):
            if button_pressed:
                RobotInterface.set_enable_large_wheel(true)
            else:
                RobotInterface.set_enable_large_wheel(false)
    )
    RobotInterface.enable_large_wheel_changed.connect(
        func():
            check_button.set_pressed_no_signal(RobotInterface.enable_large_wheel)
    )
