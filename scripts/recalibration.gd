extends Panel

@onready var arm_length: Button = $HBoxContainer/ArmLength
@onready var expander: Button = $HBoxContainer/Expander
@onready var arm_angle: Button = $HBoxContainer/ArmAngle

func _ready() -> void:
    arm_length.pressed.connect(
        func() -> void:
            RobotInterface.set_arm_length(-1)
    )
    expander.pressed.connect(
        func() -> void:
            RobotInterface.set_expander_length(-1)
    )
    arm_angle.pressed.connect(
        func() -> void:
            RobotInterface.set_arm_angle(deg_to_rad(-61))
    )
