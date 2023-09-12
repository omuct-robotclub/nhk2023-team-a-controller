extends Panel

@onready var slider: SliderWithPresetButtons = $Slider

func _ready() -> void:
    slider.submitted.connect(
        func():
            RobotInterface.set_arm_length(slider.slider.value / 1000)
    )
    RobotInterface.arm_length_changed.connect(
        func():
            slider.slider.value = RobotInterface.arm_length * 1000
    )
