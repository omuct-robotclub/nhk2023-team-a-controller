extends Panel

@onready var check_button: CheckButton = $CheckButton

func _ready() -> void:
    check_button.toggled.connect(
        func(button_pressed: bool):
            if button_pressed:
                RobotInterface.set_large_wheel_cmd(0.6)
            else:
                RobotInterface.set_large_wheel_cmd(0)
    )
    RobotInterface.large_wheel_cmd_changed.connect(
        func():
            check_button.set_pressed_no_signal(abs(RobotInterface.large_wheel_cmd) > 0.1)
    )
