extends Panel

@onready var slider: SliderWithPresetButtons = $Slider

func _ready() -> void:
    slider.slider.max_value = rad_to_deg(RobotInterface.ARM_ANGLE_MAX)
    slider.slider.min_value = rad_to_deg(RobotInterface.ARM_ANGLE_MIN)
    slider.submitted.connect(
        func():
            RobotInterface.set_arm_angle(deg_to_rad(slider.slider.value))
    )
    RobotInterface.arm_angle_changed.connect(
        func():
            slider.slider.value = rad_to_deg(RobotInterface.arm_angle)
    )
