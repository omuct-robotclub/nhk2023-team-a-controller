extends CheckButton
class_name ParameterButton

@export var auto_init := false
@export var node_name := ""
@export var parameter_name := ""

var _param: RosBridge.Parameter

func _ready() -> void:
    self_modulate = Color.RED
    rosbridge.disconnected.connect(
        func(): self_modulate = Color.RED
    )
    if auto_init:
        init()

func init() -> void:
    _param = rosbridge.create_parameter_wrapper(node_name, parameter_name, null)
    toggled.connect(
        func(_button_pressed: bool):
            _param.set_value(button_pressed)
    )
    _param.value_updated.connect(
        func(new_value: bool):
            self_modulate = Color.WHITE
            set_pressed_no_signal(new_value)
    )
