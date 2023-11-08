extends Panel

@onready var arm_angle_slider: SliderWithPresetButtons = $HBoxContainer/ArmAngle
@onready var arm_length_slider: SliderWithPresetButtons = $HBoxContainer/ArmLength

func _ready() -> void:
    arm_angle_slider.slider.max_value = rad_to_deg(RobotInterface.ARM_ANGLE_MAX)
    arm_angle_slider.slider.min_value = rad_to_deg(RobotInterface.ARM_ANGLE_MIN)
    arm_angle_slider.submitted.connect(
        func():
            RobotInterface.set_arm_angle(deg_to_rad(arm_angle_slider.slider.value))
    )
    RobotInterface.arm_angle_changed.connect(
        func():
            arm_angle_slider.slider.value = rad_to_deg(RobotInterface.arm_angle)
    )
    
    arm_length_slider.submitted.connect(
        func():
            RobotInterface.set_arm_length(arm_length_slider.slider.value / 1000)
    )
    RobotInterface.arm_length_changed.connect(
        func():
            arm_length_slider.slider.value = RobotInterface.arm_length * 1000
    )
