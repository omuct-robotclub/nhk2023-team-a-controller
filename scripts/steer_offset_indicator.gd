extends Panel


var params: Array[RosBridge.Parameter] = [
    rosbridge.create_parameter_wrapper("/can_bridge", "steer0.offset", 0.0),
    rosbridge.create_parameter_wrapper("/can_bridge", "steer1.offset", 0.0),
    rosbridge.create_parameter_wrapper("/can_bridge", "steer2.offset", 0.0),
    rosbridge.create_parameter_wrapper("/can_bridge", "steer3.offset", 0.0)
]

@onready var steer_nodes: Array[Knob] = [
    $HBoxContainer/GridContainer/SteerWheel0,
    $HBoxContainer/GridContainer/SteerWheel1,
    $HBoxContainer/GridContainer/SteerWheel2,
    $HBoxContainer/GridContainer/SteerWheel3,
]

@export var angle_multiplier := -10.0


func _ready() -> void:
    for i in range(params.size()):
        params[i].value_updated.connect(
            func(_val):
                steer_nodes[i].value = params[i].get_value() * angle_multiplier
        )
        steer_nodes[i].value_changed.connect(
            func():
                params[i].set_value(steer_nodes[i].value / angle_multiplier)
        )
