extends MenuButton


func _ready() -> void:
    text = RobotInterface.cmd_vel_frame
    get_popup().index_pressed.connect(
        func(index: int) -> void:
            var frame_name := get_popup().get_item_text(index)
            RobotInterface.set_cmd_vel_frame(frame_name)
    )
    RobotInterface.cmd_vel_frame_changed.connect(
        func() -> void:
            var frame_name := RobotInterface.cmd_vel_frame
            text = frame_name
            var popup := get_popup()
            for i in range(popup.item_count):
                if frame_name == popup.get_item_text(i):
                    popup.set_item_checked(i, true)
                else:
                    popup.set_item_checked(i, false)
    )
