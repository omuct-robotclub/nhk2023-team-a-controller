extends CheckButton

@export var activated_color := Color.AQUAMARINE

func _ready() -> void:
    set_pressed_no_signal(RobotInterface.cmd_vel_publisher_enabled)
    RenderingServer.set_default_clear_color(activated_color)
    toggled.connect(
        func(_button_pressed: bool) -> void:
            RobotInterface.set_cmd_vel_publisher_enabled(button_pressed)
            if button_pressed:
                RenderingServer.set_default_clear_color(activated_color)
            else:
                RenderingServer.set_default_clear_color(Color(0.3, 0.3, 0.3, 1.0))
    )
    RobotInterface.cmd_vel_publisher_enabled_changed.connect(
        func() -> void:
            button_pressed = RobotInterface.cmd_vel_publisher_enabled
    )
