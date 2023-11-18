extends Panel

@onready var arm_virtical_button: Button = $HBoxContainer/ArmControlButtons/ArmVirticalButton
@onready var arm_holizontal_button: Button = $HBoxContainer/ArmControlButtons/ArmHolizontalButton
@onready var arm_retract_button: Button = $HBoxContainer/ArmControlButtons/ArmRetractButton
@onready var donfan_expand_button: Button = $HBoxContainer/DonfanControlButtons/DonfanExpandButton
@onready var donfan_retract_button: Button = $HBoxContainer/DonfanControlButtons/DonfanRetractButton
@onready var block_upper_button: Button = $HBoxContainer/Blocker/BlockUpperButton
@onready var block_hol_button: Button = $HBoxContainer/Blocker/BlockHolButton
@onready var pre_get_over_button: Button = $HBoxContainer/GetOverControlButtons/PreGetOverButton
@onready var post_get_over_button: Button = $HBoxContainer/GetOverControlButtons/PostGetOverButton
@onready var expand_runzone_button: Button = $HBoxContainer/GetOverControlButtons/ExpandRunzoneButton
@onready var arm_length: Button = $HBoxContainer/Calibration/ArmLength
@onready var expander: Button = $HBoxContainer/Calibration/Expander
@onready var arm_angle: Button = $HBoxContainer/Calibration/ArmAngle

func _ready() -> void:
    arm_virtical_button.pressed.connect(
        func() -> void:
            RobotInterface.set_arm_angle(deg_to_rad(90))
    )
    arm_holizontal_button.pressed.connect(
        func() -> void:
            RobotInterface.set_arm_angle(deg_to_rad(0))
    )
    arm_retract_button.pressed.connect(
        func() -> void:
            RobotInterface.set_arm_angle(RobotInterface.ARM_ANGLE_MIN)
    )

    donfan_expand_button.pressed.connect(
        func() -> void:
            RobotInterface.set_donfan_cmd(1)
    )
    donfan_retract_button.pressed.connect(
        func() -> void:
            RobotInterface.set_donfan_cmd(-1)
    )

    block_upper_button.pressed.connect(
        func() -> void:
            RobotInterface.set_arm_angle(deg_to_rad(45.0))
            RobotInterface.set_arm_length(1.0)
    )
    block_hol_button.pressed.connect(
        func() -> void:
            RobotInterface.set_arm_angle(deg_to_rad(0.0))
            RobotInterface.set_arm_length(1.0)
    )

    expand_runzone_button.pressed.connect(
        func() -> void:
            RobotInterface.set_donfan_cmd(1)
            await get_tree().create_timer(1.0).timeout
            RobotInterface.set_expander_length(0.9)
            RobotInterface.set_arm_angle(deg_to_rad(90))
            RobotInterface.set_arm_length(0.0)
    )
    pre_get_over_button.pressed.connect(
        func() -> void:
            RobotInterface.set_expander_length(0.0)
            RobotInterface.set_arm_angle(0.0)
            RobotInterface.set_arm_length(0.0)
            await get_tree().create_timer(1.5).timeout
            RobotInterface.set_donfan_cmd(-1)
    )
    post_get_over_button.pressed.connect(
        func() -> void:
            RobotInterface.set_donfan_cmd(-1)
            RobotInterface.set_expander_length(0.0)
            RobotInterface.set_arm_angle(RobotInterface.ARM_ANGLE_MIN)
            RobotInterface.set_arm_length(0.0)
    )
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
            RobotInterface.set_arm_angle(RobotInterface.ARM_ANGLE_MIN - deg_to_rad(1))
    )
