class_name RobotController
extends Control

@export var max_linear_speed := 2.6
@export var max_angular_speed := 6.0
@export var max_arm_pos_velocity := 0.3

@export var deadzone_radius := 0.2
@export var arm_base_length := 0.775

var tim_ := Timer.new()

var collecting_ := false
var all_expanding_ := false
var _is_prev_slow_mode := false

@onready var cmd_vel_indicator_ = %CmdVelIndicator
@onready var arm_length_slider: HBoxContainer = $TabContainer/Mech/ArmLengthController/Slider
@onready var linear_acc_limit: HBoxContainer = $TabContainer/Limits/MarginContainer/HBoxContainer/LinearAccLimit
@onready var angular_acc_limit: HBoxContainer = $TabContainer/Limits/MarginContainer/HBoxContainer/AngularAccLimit

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

func _get_velocity_multiplier(device: int) -> float:
    var shulder := clampf((Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT) - 0.5) * 2, 0, 1.0)
    return 1.0 - shulder * 0.666

func _is_slow_mode(device: int) -> bool:
    var a := Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT)
    return 0.8 < a

func _get_joy_stick(device: int, x_axis: int, y_axis: int) -> Vector2:
    var v: Vector2
    v.x = -Input.get_joy_axis(device, x_axis)
    v.y = -Input.get_joy_axis(device, y_axis)
    var length := maxf(v.length() - deadzone_radius, 0.0)
    length /= 1 - deadzone_radius
    var angle := v.angle()
    return Vector2(length, 0.0).rotated(angle)

func _is_safe_arm_pos(pos: Vector2) -> bool:
    const eps := 0.0001
    var angle := rad_to_deg(pos.angle())
    var length := pos.length()
    return (60 - eps) <= angle and angle <= (110 + eps) and (arm_base_length - eps) <= length and length <= (0.8 + arm_base_length + eps)

func _timer_callback() -> void:
    var now := Time.get_ticks_msec()
    var dt := (now - _prev_time) * 1e-3
    _prev_time = now
    for device in CustomInput.allowed_device:
        if not Input.is_joy_button_pressed(device, JOY_BUTTON_RIGHT_SHOULDER):
            var reverse := _is_reverse(device)
            if Input.is_joy_button_pressed(device, JOY_BUTTON_X):
                if reverse:
                    RobotInterface.arm_length -= 0.25 * dt
                else:
                    RobotInterface.arm_length += 0.25 * dt
                RobotInterface.set_arm_length(clampf(RobotInterface.arm_length, 0.0, 0.8))

            if Input.is_joy_button_pressed(device, JOY_BUTTON_B):
                if reverse:
                    var in_safe_range := RobotInterface.arm_angle >= deg_to_rad(60.0)
                    RobotInterface.arm_angle -= deg_to_rad(60.0) * dt
                    if in_safe_range and RobotInterface.arm_angle < deg_to_rad(60.0):
                        RobotInterface.arm_angle = deg_to_rad(60.0)
                else:
                    RobotInterface.arm_angle += deg_to_rad(60.0) * dt
                RobotInterface.set_arm_angle(clampf(RobotInterface.arm_angle, deg_to_rad(-60.0), deg_to_rad(110.0)))
    
    var linear := Vector2.ZERO
    var angular := 0.0
    var arm_vel := Vector2.ZERO
    
    var slow_mode := false
    for device in CustomInput.allowed_device:
        slow_mode = slow_mode || _is_slow_mode(device)
        var left_stick := _get_joy_stick(device, JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
        var right_stick := _get_joy_stick(device, JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y)
        var mul := _get_velocity_multiplier(device)
        linear.x += left_stick.y * mul
        linear.y += left_stick.x * mul
        if Input.is_joy_button_pressed(device, JOY_BUTTON_LEFT_SHOULDER):
            arm_vel += right_stick * max_arm_pos_velocity
        else:
            angular += right_stick.x * mul
    
    if slow_mode and (not _is_prev_slow_mode):
        linear_acc_limit.buttons.get_child(1).normal_pressed.emit()
        angular_acc_limit.buttons.get_child(1).normal_pressed.emit()
    elif (not slow_mode) and _is_prev_slow_mode:
        linear_acc_limit.buttons.get_child(0).normal_pressed.emit()
        angular_acc_limit.buttons.get_child(0).normal_pressed.emit()
    _is_prev_slow_mode = slow_mode
    
    for device in CustomInput.allowed_device:
        var mul := _get_velocity_multiplier(device)
        linear.x += mul if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_UP) else 0.0
        linear.x -= mul if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN) else 0.0
        linear.y += mul if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_LEFT) else 0.0
        linear.y -= mul if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_RIGHT) else 0.0
    
    RobotInterface.target_linear_velocity = linear.limit_length(1) * max_linear_speed
    RobotInterface.target_angular_velocity = clampf(angular, -1, 1) * max_angular_speed
    
    var arm_pos := Vector2.from_angle(RobotInterface.arm_angle) * (RobotInterface.arm_length + arm_base_length)
    if arm_vel.length() > 0.001 and _is_safe_arm_pos(arm_pos):
        var new_arm_pos := arm_pos + arm_vel * dt
        RobotInterface.set_arm_angle(clampf(new_arm_pos.angle(), deg_to_rad(60), deg_to_rad(110)))
        RobotInterface.set_arm_length(clampf(new_arm_pos.length() - arm_base_length, 0, 0.8))

func _input(event: InputEvent) -> void:
    var reverse := _is_reverse(event.device)

    if event is InputEventJoypadButton and event.pressed:
        if event.device not in CustomInput.allowed_device: return
        match [event.button_index, Input.is_joy_button_pressed(event.device, JOY_BUTTON_RIGHT_SHOULDER)]:
            [JOY_BUTTON_RIGHT_STICK, _]:
                if RobotInterface.large_wheel_cmd == 0:
                    RobotInterface.set_large_wheel_cmd(0.6)
                else:
                    RobotInterface.set_large_wheel_cmd(0.0)

            [JOY_BUTTON_MISC1, _]:
                if RobotInterface.large_wheel_cmd == 0:
                    RobotInterface.set_large_wheel_cmd(0.6)
                else:
                    RobotInterface.set_large_wheel_cmd(0.0)

            [JOY_BUTTON_LEFT_STICK, _]:
                RobotInterface.start_unwinding()
            
            [JOY_BUTTON_A, false]:
                RobotInterface.set_collector_cmd(not RobotInterface.collector_cmd)

            [JOY_BUTTON_Y, false]:
                if reverse:
                    _retract_all()
                else:
                    _expand_all()
            
            [JOY_BUTTON_Y, true]:
                arm_length_slider.buttons.get_child(0).normal_pressed.emit()
                
            [JOY_BUTTON_B, true]:
                arm_length_slider.buttons.get_child(1).normal_pressed.emit()
            
            [JOY_BUTTON_A, true]:
                arm_length_slider.buttons.get_child(2).normal_pressed.emit()

var _working := false

func _expand_all() -> void:
    if _working: return
    _working = true
    RobotInterface.set_donfan_cmd(1)
    await get_tree().create_timer(1.0).timeout
    RobotInterface.set_expander_length(0.9)
    await get_tree().create_timer(1.0).timeout
    RobotInterface.set_arm_angle(deg_to_rad(110))
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
