extends Panel

@onready var slider: SliderWithPresetButtons = $Slider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    slider.submitted.connect(
        func():
            RobotInterface.set_expander_length(slider.slider.value / 1000)
    )
    RobotInterface.expander_length_changed.connect(
        func():
            slider.slider.value = RobotInterface.expander_length * 1000
    )
