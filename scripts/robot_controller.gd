class_name RobotController
extends Control

@export var max_linear_speed := 2.6
@export var max_angular_speed := 6.0

var tim_ := Timer.new()

var collecting_ := false
var all_expanding_ := false

@onready var cmd_vel_indicator_ = %CmdVelIndicator

func _ready() -> void:
    cmd_vel_indicator_.max_linear_velocity = max_linear_speed
    cmd_vel_indicator_.max_angular_velocity = max_angular_speed
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
                RobotInterface.arm_length -= 0.25 * dt
            else:
                RobotInterface.arm_length += 0.25 * dt
            RobotInterface.set_arm_length(clampf(RobotInterface.arm_length, 0.0, 0.9))

        if Input.is_joy_button_pressed(device, JOY_BUTTON_B):
            if reverse:
                var in_safe_range := RobotInterface.arm_angle >= deg_to_rad(60.0)
                RobotInterface.arm_angle -= deg_to_rad(60.0) * dt
                if in_safe_range and RobotInterface.arm_angle < deg_to_rad(60.0):
                    RobotInterface.arm_angle = deg_to_rad(60.0)
            else:
                RobotInterface.arm_angle += deg_to_rad(60.0) * dt
            RobotInterface.set_arm_angle(clampf(RobotInterface.arm_angle, deg_to_rad(-60.0), deg_to_rad(120.0)))
    
    var tmp_linear := Vector2.ZERO
    var tmp_angular := 0.0
    for device in CustomInput.allowed_device:
        var slow_mode := Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT) > 0.5
        var shulder := clampf((Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT) - 0.5) * 2, 0, 1.0)
        var mul := 1.0 - shulder * 0.666
        tmp_linear.x += mul * -Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
        tmp_linear.y += mul * -Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
        tmp_linear.x += mul if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_UP) else 0.0
        tmp_linear.x -= mul if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN) else 0.0
        tmp_linear.y += mul if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_LEFT) else 0.0
        tmp_linear.y -= mul if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_RIGHT) else 0.0
        tmp_angular += mul * -Input.get_joy_axis(device, JOY_AXIS_RIGHT_X)
    var length := maxf(tmp_linear.length() - CustomInput.deadzone_radius, 0.0)
    length /= 1 - CustomInput.deadzone_radius
    var ang := tmp_linear.angle()
    tmp_linear = Vector2(length, 0.0).rotated(ang)
    tmp_angular = signf(tmp_angular) * maxf(absf(tmp_angular) - CustomInput.deadzone_radius, 0.0)
    tmp_angular /= 1 - CustomInput.deadzone_radius
    RobotInterface.target_linear_velocity = tmp_linear * max_linear_speed
    RobotInterface.target_angular_velocity = tmp_angular * max_angular_speed

func _input(event: InputEvent) -> void:
    var reverse := _is_reverse(event.device)

    if event is InputEventJoypadButton and event.pressed:
        if event.device not in CustomInput.allowed_device: return
#        print(event.button_index)
        match event.button_index:
            JOY_BUTTON_A:
                RobotInterface.set_collector_cmd(not RobotInterface.collector_cmd)

            JOY_BUTTON_RIGHT_STICK:
                if RobotInterface.large_wheel_cmd == 0:
                    RobotInterface.set_large_wheel_cmd(0.6)
                else:
                    RobotInterface.set_large_wheel_cmd(0.0)

            JOY_BUTTON_MISC1:
                if RobotInterface.large_wheel_cmd == 0:
                    RobotInterface.set_large_wheel_cmd(0.6)
                else:
                    RobotInterface.set_large_wheel_cmd(0.0)

            JOY_BUTTON_LEFT_STICK:
                RobotInterface.start_unwinding()

            JOY_BUTTON_Y:
                if reverse:
                    _retract_all()
                else:
                    _expand_all()

var _working := false

func _expand_all() -> void:
    if _working: return
    _working = true
    RobotInterface.set_donfan_cmd(1)
    await get_tree().create_timer(1.0).timeout
    RobotInterface.set_expander_length(1.0)
    await get_tree().create_timer(1.0).timeout
    RobotInterface.set_arm_angle(deg_to_rad(120))
    _working = false

func _retract_all() -> void:
    if _working: return
    _working = true
    RobotInterface.set_arm_angle(deg_to_rad(-60))
    await get_tree().create_timer(1.0).timeout
    RobotInterface.set_expander_length(0.0)
    await get_tree().create_timer(1.0).timeout
    RobotInterface.set_donfan_cmd(-1)
    _working = false
