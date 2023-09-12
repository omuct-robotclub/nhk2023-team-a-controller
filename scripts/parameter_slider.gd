extends HBoxContainer
class_name ParameterSlider

@export var auto_init := false
@export var label_format := "%f"
@export var node_name := ""
@export var parameter_name := ""
@export var min_value := 0.0
@export var max_value := 100.0

@onready var label: Label = $Label
@onready var slider: HSlider = $HSlider

var _param: RosBridge.Parameter

func _ready() -> void:
    label.self_modulate = Color.RED
    rosbridge.disconnected.connect(
        func(): label.self_modulate = Color.RED
    )
    if auto_init:
        init()

func init() -> void:
    _param = rosbridge.create_parameter_wrapper(node_name, parameter_name, null)
    slider.min_value = min_value
    slider.max_value = max_value
    slider.value_changed.connect(
        func(_new_value: float):
            _update_label()
    )
    slider.drag_ended.connect(
        func(value_changed: bool):
            _param.set_value(slider.value)
    )
    _param.value_updated.connect(
        func(new_value: float):
            label.self_modulate = Color.WHITE
            _update_label()
            slider.value = new_value
    )
    _update_label()

func _update_label() -> void:
    label.text = label_format % slider.value
