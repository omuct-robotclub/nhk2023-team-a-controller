extends Node

var deadzone_radius := 0.2

var allowed_device: Array[int]
var denied_device: Array[int]

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

#func _press_acation(positive: StringName, negative: StringName, value: float) -> void:
#    var v = sign(value) * max(abs(value) - deadzone_radius, 0.0)
#    if value >= 0:
#        Input.action_press(positive,  + v)
#        Input.action_press(negative, 0)
#    else:
#        Input.action_press(positive, 0)
#        Input.action_press(negative,  - v)
#
#func _press_vector(positive_x: StringName, negative_x: StringName, positive_y: StringName, negative_y: StringName, vec: Vector2) -> void:
#    var ang := vec.angle()
#    var length = max(vec.length() - deadzone_radius, 0.0)
#    var v = Vector2(length, 0.0).rotated(ang)
#
#    if v.x >= 0:
#        Input.action_press(positive_x,  + v.x)
#        Input.action_press(negative_x, 0)
#    else:
#        Input.action_press(positive_x, 0)
#        Input.action_press(negative_x,  - v.x)
#
#    if v.x >= 0:
#        Input.action_press(positive_y,  + v.y)
#        Input.action_press(negative_y, 0)
#    else:
#        Input.action_press(positive_y, 0)
#        Input.action_press(negative_y,  - v.y)

func _is_device_name_look_loke_joypad(n: String) -> bool:
	return not (
		"Touchpad" in n
		or "TouchScreen" in n
		or "opentrack headpose" in n
		or n == "")

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if connected:
		if device in denied_device or device in allowed_device: return 
		var device_name := Input.get_joy_name(device)
		var device_guid := Input.get_joy_guid(device)
		print("name: %s, guid: %s" % [device_name, device_guid])
		if device_name == "PS4 Controller": return
		if _is_device_name_look_loke_joypad(device_name):
			print("Input device %d:'%s' looks loke a joypad." % [device, device_name])
			allowed_device.push_back(device)
		else:
			print("Input device %d:'%s' does not look like a joypad." % [device, device_name])
			denied_device.push_back(device)
	else:
		print("Input device disconnected.")
		allowed_device.clear()
		denied_device.clear()

func _input(event: InputEvent) -> void:
	if Input.get_joy_name(event.device) == "PS4 Controller" and event.device not in allowed_device:
		if event is InputEventJoypadMotion and event.axis > 1:
			allowed_device.push_back(event.device)
		else:
			return
	else:
		_on_joy_connection_changed(event.device, true)

#    for device in allowed_device:
#        var linear: Vector2
#        linear.x = Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
#        linear.x += 1.0 if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_UP) else 0.0
#        linear.x -= 1.0 if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN) else 0.0
#        linear.y = Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
#        linear.y += 1.0 if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_LEFT) else 0.0
#        linear.y -= 1.0 if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_RIGHT) else 0.0
#        _press_vector("move_backward", "move_forward", "move_right", "move_left", linear)
#        _press_acation("turn_right", "turn_left", Input.get_joy_axis(device, JOY_AXIS_RIGHT_X))
