class_name RobotController
extends Control

@export var max_linear_speed := 3.0
@export var max_angular_speed := 3.0

var tim_ := Timer.new()

var collecting_ := false
var all_expanding_ := false

@onready var cmd_vel_indicator_: Control = %CmdVelIndicator

func _ready() -> void:
    add_child(tim_)
    tim_.wait_time = 1.0 / 60
    tim_.timeout.connect(_timer_callback)
    tim_.start()
    RobotInterface.init()

func get_linear_vel() -> Vector2:
    return Vector2(Input.get_axis("move_backward", "move_forward"), Input.get_axis("move_right", "move_left"))

func _is_reverse(device: int) -> bool:
    return Input.get_joy_axis(device, JOY_AXIS_TRIGGER_RIGHT) > 0.5

var _prev_time := Time.get_ticks_msec()

func _timer_callback() -> void:
    var now := Time.get_ticks_msec()
    var dt := (now - _prev_time) * 1e-3
    _prev_time = now
    for device in CustomInput.allowed_device:
        var reverse := _is_reverse(device)
        if Input.is_joy_button_pressed(device, JOY_BUTTON_X):
            if reverse:
                RobotInterface.arm_length -= 0.5 * dt
            else:
                RobotInterface.arm_length += 0.5 * dt
            RobotInterface.set_arm_length(clampf(RobotInterface.arm_length, 0.0, 1.0))

        if Input.is_joy_button_pressed(device, JOY_BUTTON_B):
            if reverse:
                RobotInterface.arm_angle -= deg_to_rad(10.0) * dt
            else:
                RobotInterface.arm_angle += deg_to_rad(10.0) * dt
            RobotInterface.set_arm_angle(clampf(RobotInterface.arm_angle, 0.0, deg_to_rad(120.0)))

func _input(event: InputEvent) -> void:
    var tgt_linear_vel := get_linear_vel() * max_linear_speed
    var tgt_angular_vel := Input.get_axis("turn_right", "turn_left") * max_angular_speed
    RobotInterface.target_linear_velocity = tgt_linear_vel
    RobotInterface.target_angular_velocity = tgt_angular_vel

    var reverse := _is_reverse(event.device)

    if event is InputEventJoypadButton and event.pressed:
        if event.device not in CustomInput.allowed_device: return
        match event.button_index:
            JOY_BUTTON_A:
                RobotInterface.set_collector_cmd(not RobotInterface.collector_cmd)

            JOY_BUTTON_RIGHT_STICK:
                if RobotInterface.large_wheel_cmd == 0:
                    RobotInterface.set_large_wheel_cmd(1.0)
                else:
                    RobotInterface.set_large_wheel_cmd(0.0)

            JOY_BUTTON_LEFT_STICK:
                RobotInterface.start_unwinding()

            JOY_BUTTON_Y:
                if reverse:
                    RobotInterface.set_donfan_cmd(-1)
                    RobotInterface.set_expander_length(0.0)
                    RobotInterface.set_arm_angle(0)
                else:
                    RobotInterface.set_donfan_cmd(1)
                    RobotInterface.set_expander_length(2.0)
                    RobotInterface.set_arm_angle(deg_to_rad(90))
