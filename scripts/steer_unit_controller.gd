extends HBoxContainer

@export var index: int
@export var left_side := false

@onready var steer: Control = %Steer
@onready var invert_button: CheckButton = %InvertButton
@onready var offset_label: Label = %OffsetLabel
@onready var angle_label: Label = %AngleLabel
@onready var velocity_label: Label = %VelocityLabel
@onready var current_label: Label = %CurrentLabel

@onready var _offset_param := rosbridge.create_parameter_wrapper("/can_bridge", "steer" + str(index) + ".offset", 0.0)

func _ready() -> void:
    if left_side: move_child(steer, 1)
    
    _offset_param.value_updated.connect(
        func(val: float) -> void:
            invert_button.set_pressed_no_signal(abs(wrapf(val, -PI, PI)) > PI/2)
            steer.offset = wrapf(_offset_param.get_value(), -PI/2, PI/2)
    )
    steer.offset_changed.connect(
        func() -> void:
            _offset_param.set_value(steer.offset + (PI if invert_button.button_pressed else 0.0))
    )
    invert_button.toggled.connect(
        func(button_pressed: bool) -> void:
            _offset_param.set_value(steer.offset + (PI if invert_button.button_pressed else 0.0))
    )
    RobotInterface.steer_state_changed.connect(_on_steer_state_changed)
    _on_steer_state_changed()

func _on_steer_state_changed() -> void:
    steer.velocity = RobotInterface.steer_velocities[index]
    steer.angle = RobotInterface.steer_angles[index]
    steer.current = RobotInterface.steer_currents[index]

    offset_label.text = "Offset:   %7.2f [deg]" % rad_to_deg(steer.offset)
    angle_label.text = "Angle:    %7.2f [deg]" % rad_to_deg(steer.angle)
    velocity_label.text = "Velocity: %7.2f [rad/s]" % steer.velocity
    current_label.text = "Current:  %7.2f [A]" % steer.current
