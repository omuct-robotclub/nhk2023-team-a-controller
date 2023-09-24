extends Panel

@onready var arm_virtical_button: Button = $HBoxContainer/ArmControlButtons/ArmVirticalButton
@onready var arm_holizontal_button: Button = $HBoxContainer/ArmControlButtons/ArmHolizontalButton
@onready var arm_retract_button: Button = $HBoxContainer/ArmControlButtons/ArmRetractButton
@onready var donfan_expand_button: Button = $HBoxContainer/DonfanControlButtons/DonfanExpandButton
@onready var donfan_retract_button: Button = $HBoxContainer/DonfanControlButtons/DonfanRetractButton
@onready var pre_get_over_button: Button = $HBoxContainer/GetOverControlButtons/PreGetOverButton
@onready var post_get_over_button: Button = $HBoxContainer/GetOverControlButtons/PostGetOverButton
@onready var post_get_over_button_center: Button = $HBoxContainer/GetOverControlButtons/PostGetOverButtonCenter


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
            RobotInterface.set_arm_angle(deg_to_rad(-60))
    )
    
    donfan_expand_button.pressed.connect(
        func() -> void:
            RobotInterface.set_donfan_cmd(1)
    )
    donfan_retract_button.pressed.connect(
        func() -> void:
            RobotInterface.set_donfan_cmd(-1)
    )
    
    pre_get_over_button.pressed.connect(
        func() -> void:
            RobotInterface.set_large_wheel_cmd(0.6)
            RobotInterface.set_arm_angle(deg_to_rad(0))
    )
    post_get_over_button.pressed.connect(
        func() -> void:
            RobotInterface.set_donfan_cmd(-1)
            RobotInterface.set_large_wheel_cmd(0.0)
            RobotInterface.set_arm_angle(deg_to_rad(-60))
    )
    post_get_over_button_center.pressed.connect(
        func() -> void:
            RobotInterface.set_large_wheel_cmd(0.0)
    )
