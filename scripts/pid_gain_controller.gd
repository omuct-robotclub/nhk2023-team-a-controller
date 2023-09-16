extends VBoxContainer

@export var display_name := ""
@export var node_name := ""
@export var parameter_base := ""

@onready var label: Label = %Label
@onready var kp: ParameterSlider = %Kp
@onready var ki: ParameterSlider = %Ki
@onready var kd: ParameterSlider = %Kd
@onready var _min: ParameterSlider = %Min
@onready var _max: ParameterSlider = %Max
@onready var antiwindup: ParameterButton = %Antiwindup
@onready var use_velocity_for_d_term: ParameterButton = %UseVelocityForDTerm

func _ready() -> void:
    label.text = display_name
    
    kp.node_name = node_name
    ki.node_name = node_name
    kd.node_name = node_name
    _min.node_name = node_name
    _max.node_name = node_name
    antiwindup.node_name = node_name
    use_velocity_for_d_term.node_name = node_name

    kp.parameter_name = parameter_base + ".kp"
    ki.parameter_name = parameter_base + ".ki"
    kd.parameter_name = parameter_base + ".kd"
    _min.parameter_name = parameter_base + ".min"
    _max.parameter_name = parameter_base + ".max"
    antiwindup.parameter_name = parameter_base + ".antiwindup"
    use_velocity_for_d_term.parameter_name = parameter_base + ".use_velocity_for_d_term"

    kp.init()
    ki.init()
    kd.init()
    _min.init()
    _max.init()
    antiwindup.init()
    use_velocity_for_d_term.init()
