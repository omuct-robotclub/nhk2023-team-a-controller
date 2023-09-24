extends Panel

@onready var linear_acc_limit: HBoxContainer = $MarginContainer/HBoxContainer/LinearAccLimit
@onready var angular_acc_limit: HBoxContainer = $MarginContainer/HBoxContainer/AngularAccLimit

func _ready() -> void:
    linear_acc_limit.submitted.connect(
        func() -> void:
            RobotInterface.set_linear_accel_limit(linear_acc_limit.slider.value)
    )
    angular_acc_limit.submitted.connect(
        func() -> void:
            RobotInterface.set_angular_accel_limit(angular_acc_limit.slider.value)
    )
    RobotInterface.linear_accel_limit_changed.connect(
        func() -> void:
            linear_acc_limit.slider.value = RobotInterface.linear_accel_limit
    )
    RobotInterface.angular_accel_limit_changed.connect(
        func() -> void:
            angular_acc_limit.slider.value = RobotInterface.angular_accel_limit
    )
    linear_acc_limit.buttons.get_child(0).normal_pressed.emit()
    angular_acc_limit.buttons.get_child(0).normal_pressed.emit()
