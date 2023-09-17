extends CheckButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    set_pressed_no_signal(RobotInterface.cmd_vel_publisher_enabled)
    toggled.connect(
        func(_button_pressed: bool) -> void:
            RobotInterface.set_cmd_vel_publisher_enabled(button_pressed)
    )
    RobotInterface.cmd_vel_publisher_enabled_changed.connect(
        func() -> void:
            button_pressed = RobotInterface.cmd_vel_publisher_enabled
    )

