class_name RobotController
extends Control

@export var max_linear_speed := 2.6
@export var max_angular_speed := 4.0

@export var deadzone_radius := 0.1
@export var arm_base_length := 0.775

@export var arm_angle_vel := deg_to_rad(60.0)

@export var wall_tracing_auto_diable_timeout := 1.0

var tim_ := Timer.new()

var collecting_ := false
var all_expanding_ := false
var _is_prev_slow_mode := false
var _wall_tracing_enabled_time := NAN

@onready var tab_container: TabContainer = $TabContainer
@onready var cmd_vel_indicator_ = %CmdVelIndicator
@onready var arm_length_slider: HBoxContainer = $TabContainer/Mech/ArmLengthController/Slider
@onready var arm_length_slider_runzone: HBoxContainer = $TabContainer/Mech/ArmLengthControllerRunZone/Slider
@onready var linear_acc_limit: HBoxContainer = $TabContainer/Limits/MarginContainer/HBoxContainer/LinearAccLimit
@onready var angular_acc_limit: HBoxContainer = $TabContainer/Limits/MarginContainer/HBoxContainer/AngularAccLimit
@onready var cheat_arm_angle: HBoxContainer = $TabContainer/Mech2/HBoxContainer/ArmAngle
@onready var cheat_arm_length: HBoxContainer = $TabContainer/Mech2/HBoxContainer/ArmLength


func _ready() -> void:
	cmd_vel_indicator_.max_linear_velocity = max_linear_speed
	cmd_vel_indicator_.max_angular_velocity = max_angular_speed
	RobotInterface.cmd_vel_publisher_enabled_changed.connect(_update_bg_color)
	RobotInterface.enable_wall_tracking_changed.connect(_update_bg_color)
	RobotInterface.enable_wall_tracking_changed.connect(
		func() -> void:
			if RobotInterface.enable_wall_tracking:
				_wall_tracing_enabled_time = Time.get_ticks_msec() * 1e-3
	)
	_update_bg_color()
	add_child(tim_)
	tim_.wait_time = 1.0 / 60
	tim_.timeout.connect(_timer_callback)
	tim_.start()
	RobotInterface.init()

func _update_bg_color() -> void:
	match [RobotInterface.cmd_vel_publisher_enabled, RobotInterface.enable_wall_tracking]:
		[false, false]:
			RenderingServer.set_default_clear_color(Color(0.3, 0.3, 0.3, 1.0))
		[true, false]:
			RenderingServer.set_default_clear_color(Color.AQUAMARINE)
		[false, true]:
			RenderingServer.set_default_clear_color(Color(0.3, 0.3, 0.3, 1.0))
		[true, true]:
			RenderingServer.set_default_clear_color(Color.ORANGE)

func get_linear_vel() -> Vector2:
	return Vector2(Input.get_axis("move_backward", "move_forward"), Input.get_axis("move_right", "move_left"))

func _is_reverse(device: int) -> bool:
	if RobotInterface.enable_wall_tracking:
		return false
	else:
		return Input.get_joy_axis(device, JOY_AXIS_TRIGGER_RIGHT) > 0.5

var _prev_time := Time.get_ticks_msec()

func _get_velocity_multiplier(device: int) -> float:
	if RobotInterface.enable_wall_tracking:
		return 1.0
	else:
		var shulder := clampf((Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT) - 0.5) * 2, 0, 1.0)
		return 1.0 - shulder * 0.666

func _is_slow_mode(device: int) -> bool:
	if RobotInterface.enable_wall_tracking:
		return false
	else:
		var a := Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT)
		return 0.8 < a

func _get_joy_stick(device: int, x_axis: int, y_axis: int) -> Vector2:
	var v := Vector2(
		-Input.get_joy_axis(device, x_axis),
		-Input.get_joy_axis(device, y_axis),
	)
	var length := maxf(v.length() - deadzone_radius, 0.0)
	length /= 1 - deadzone_radius
	var angle := v.angle()
	return Vector2(length, 0.0).rotated(angle)

func _timer_callback() -> void:
	var now := Time.get_ticks_msec()
	var dt := (now - _prev_time) * 1e-3
	_prev_time = now
	for device in CustomInput.allowed_device:
		if not Input.is_joy_button_pressed(device, JOY_BUTTON_RIGHT_SHOULDER) \
			and not Input.is_joy_button_pressed(device, JOY_BUTTON_LEFT_SHOULDER):
			var reverse := _is_reverse(device)
			if Input.is_joy_button_pressed(device, JOY_BUTTON_X):
				if reverse:
					RobotInterface.arm_length -= 0.25 * dt
				else:
					RobotInterface.arm_length += 0.25 * dt
				RobotInterface.set_arm_length(clampf(RobotInterface.arm_length, RobotInterface.ARM_LENGTH_MIN, RobotInterface.ARM_LENGTH_MAX))

			if Input.is_joy_button_pressed(device, JOY_BUTTON_B):
				if reverse:
					RobotInterface.arm_angle -= arm_angle_vel * dt
				else:
					RobotInterface.arm_angle += arm_angle_vel * dt
				RobotInterface.set_arm_angle(clampf(RobotInterface.arm_angle, RobotInterface.ARM_ANGLE_MIN, RobotInterface.ARM_ANGLE_MAX))

	var linear := Vector2.ZERO
	var angular := 0.0
	var target_course := RobotInterface.Course.NO_COURSE

	var slow_mode := false
	for device in CustomInput.allowed_device:
		slow_mode = slow_mode || _is_slow_mode(device)
		var left_stick := _get_joy_stick(device, JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
		var right_stick := _get_joy_stick(device, JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y)
		if abs(right_stick.x) > 0.2 and (now * 1e-3) - _wall_tracing_enabled_time > wall_tracing_auto_diable_timeout:
			RobotInterface.set_enable_wall_tracking(false)
		var mul := _get_velocity_multiplier(device)
		linear.x += left_stick.y * mul
		linear.y += left_stick.x * mul
		angular += right_stick.x * mul

		if Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT) > 0.5:
			target_course = RobotInterface.Course.IN_COURSE
		elif Input.get_joy_axis(device, JOY_AXIS_TRIGGER_RIGHT) > 0.5:
			target_course = RobotInterface.Course.OUT_COURSE
		elif Input.is_joy_button_pressed(device, JOY_BUTTON_RIGHT_SHOULDER):
			target_course = RobotInterface.Course.PARKING_COURSE

	if slow_mode and (not _is_prev_slow_mode):
		linear_acc_limit.buttons.get_child(1).normal_pressed.emit()
		angular_acc_limit.buttons.get_child(1).normal_pressed.emit()
	elif (not slow_mode) and _is_prev_slow_mode:
		linear_acc_limit.buttons.get_child(0).normal_pressed.emit()
		angular_acc_limit.buttons.get_child(0).normal_pressed.emit()
	_is_prev_slow_mode = slow_mode

	RobotInterface.target_linear_velocity = linear.limit_length(1) * max_linear_speed
	RobotInterface.target_angular_velocity = clampf(angular, -1, 1) * max_angular_speed
	RobotInterface.target_course = target_course

func _cheat(index: int) -> void:
	assert(1 <= index and index <= 8)
	cheat_arm_angle.buttons.get_child(index-1).normal_pressed.emit()
	await get_tree().create_timer(0.5).timeout
	cheat_arm_length.buttons.get_child(index-1).normal_pressed.emit()

func _input(event: InputEvent) -> void:
	var reverse := _is_reverse(event.device)

	if event is InputEventJoypadButton and event.pressed:
		if event.device not in CustomInput.allowed_device: return
		var l1 := Input.is_joy_button_pressed(event.device, JOY_BUTTON_LEFT_SHOULDER)
		var r1 := Input.is_joy_button_pressed(event.device, JOY_BUTTON_RIGHT_SHOULDER)
		match [event.button_index, l1, r1]:
			[JOY_BUTTON_START, _, _]:
				var tab_idx := tab_container.current_tab
				if reverse:
					tab_idx -= 1
					if tab_idx < 0: tab_idx = tab_container.get_child_count() - 1
				else:
					tab_idx += 1
				tab_container.current_tab = tab_idx % tab_container.get_child_count()

			[JOY_BUTTON_DPAD_UP, false, false]: _cheat(1)
			[JOY_BUTTON_DPAD_DOWN, false, false]: RobotInterface.set_collector_cmd(not RobotInterface.collector_cmd)
			[JOY_BUTTON_DPAD_LEFT, false, false]: _cheat(2)
			[JOY_BUTTON_DPAD_RIGHT, false, false]: _cheat(3)

			[JOY_BUTTON_Y, false, false]:
				if reverse: RobotInterface.retract_all()
				else: RobotInterface.expand_all()
			[JOY_BUTTON_Y, true, false]:
				if reverse: RobotInterface.retract_all()
				else: RobotInterface.expand_chiku()
			
			[JOY_BUTTON_A, false, false]: RobotInterface.start_unwinding()

			[JOY_BUTTON_B, true, false]: arm_length_slider_runzone.buttons.get_child(0).normal_pressed.emit()
			[JOY_BUTTON_A, true, false]: arm_length_slider_runzone.buttons.get_child(1).normal_pressed.emit()
			[JOY_BUTTON_X, true, false]: arm_length_slider_runzone.buttons.get_child(2).normal_pressed.emit()

			[JOY_BUTTON_DPAD_UP, true, false]: _cheat(4)
			[JOY_BUTTON_DPAD_DOWN, true, false]: _cheat(5)
			[JOY_BUTTON_DPAD_LEFT, true, false]: _cheat(6)
			[JOY_BUTTON_DPAD_RIGHT, true, false]: _cheat(7)
			
			[JOY_BUTTON_LEFT_STICK, _, _]: RobotInterface.set_enable_large_wheel(not RobotInterface.enable_large_wheel)

			[JOY_BUTTON_Y, false, true]: arm_length_slider.buttons.get_child(0).normal_pressed.emit()
			[JOY_BUTTON_B, false, true]: arm_length_slider.buttons.get_child(1).normal_pressed.emit()
			[JOY_BUTTON_A, false, true]: arm_length_slider.buttons.get_child(2).normal_pressed.emit()
			[JOY_BUTTON_X, false, true]: RobotInterface.set_arm_length(RobotInterface.ARM_LENGTH_MIN)

			[JOY_BUTTON_RIGHT_STICK, _, _]: RobotInterface.set_enable_wall_tracking(not RobotInterface.enable_wall_tracking)
			[JOY_BUTTON_MISC1, _, _]: RobotInterface.set_enable_wall_tracking(not RobotInterface.enable_wall_tracking)
