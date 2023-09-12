extends VBoxContainer

@export var display_name := ""
@export var node_name := ""
@export var parameter_base := ""

@onready var label: Label = %Label
@onready var kp: ParameterSlider = %Kp
@onready var ki: ParameterSlider = %Ki
@onready var kd: ParameterSlider = %Kd
@onready var min: ParameterSlider = %Min
@onready var max: ParameterSlider = %Max
@onready var antiwindup: ParameterButton = %Antiwindup
@onready var use_velocity_for_d_term: ParameterButton = %UseVelocityForDTerm

func _ready() -> void:
    label.text = display_name
    
    kp.node_name = node_name
    ki.node_name = node_name
    kd.node_name = node_name
    min.node_name = node_name
    max.node_name = node_name
    antiwindup.node_name = node_name
    use_velocity_for_d_term.node_name = node_name

    kp.parameter_name = parameter_base + ".kp"
    ki.parameter_name = parameter_base + ".ki"
    kd.parameter_name = parameter_base + ".kd"
    min.parameter_name = parameter_base + ".min"
    max.parameter_name = parameter_base + ".max"
    antiwindup.parameter_name = parameter_base + ".antiwindup"
    use_velocity_for_d_term.parameter_name = parameter_base + ".use_velocity_for_d_term"

    kp.init()
    ki.init()
    kd.init()
    min.init()
    max.init()
    antiwindup.init()
    use_velocity_for_d_term.init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
