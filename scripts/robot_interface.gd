extends Node

signal steer_state_changed()
signal cmd_vel_frame_changed()
signal cmd_vel_publisher_enabled_changed()
signal donfan_cmd_changed()
signal expander_length_changed()
signal collector_cmd_changed()
signal arm_length_changed()
signal arm_angle_changed()
signal large_wheel_cmd_changed()
signal linear_accel_limit_changed()
signal angular_accel_limit_changed()

var cmd_vel_publisher_enabled := true
var cmd_vel_frame := "base_footprint"
var donfan_cmd: int
var expander_length: float
var collector_cmd: bool
var arm_angle: float
var arm_length: float
var large_wheel_cmd: float

var linear_accel_limit := 10.0
var angular_accel_limit := 10.0

var target_linear_velocity := Vector2()
var target_angular_velocity := 0.0

var filtered_linear_velocity := Vector2()
var filtered_angular_velocity := 0.0

var _publish_command_timer := Timer.new()
@onready var _cmd_vel_stamped_pub := rosbridge.create_publisher("geometry_msgs/TwistStamped", "cmd_vel_stamped")
@warning_ignore("unused_private_class_variable")
@onready var _cmd_vel_filtered_sub := rosbridge.create_subscription("geometry_msgs/Twist", "cmd_vel_filtered", _cmd_vel_filtered_callback)
var _actual_linear_vel := Vector2()
var _actual_angular_vel := 0.0
@onready var _steer_state_sub := rosbridge.create_subscription("robot_interface/SteerUnitStates", "steer_states", _steer_states_callback)
var steer_angles: Array = [0.0, 0.0, 0.0, 0.0]
var steer_velocities: Array = [0.0, 0.0, 0.0, 0.0]
var steer_currents: Array = [0.0, 0.0, 0.0, 0.0]

var _unwind_cli := rosbridge.create_client("unwind")
var _donfan_cmd_pub := rosbridge.create_publisher("std_msgs/Int8", "donfan_cmd")
var _expander_length_pub := rosbridge.create_publisher("std_msgs/Float64", "expander_length")
var _collector_cmd_pub := rosbridge.create_publisher("std_msgs/Bool", "collector_cmd")
var _arm_angle_pub := rosbridge.create_publisher("std_msgs/Float64", "arm_angle")
var _arm_length_pub := rosbridge.create_publisher("std_msgs/Float64", "arm_length")
var _large_wheel_cmd_pub := rosbridge.create_publisher("std_msgs/Float64", "large_wheel_cmd")

func init() -> void:
    _publish_command_timer.wait_time = 0.01
    _publish_command_timer.timeout.connect(_publish_command)
    add_child(_publish_command_timer)
    _publish_command_timer.start()

func _process(delta: float) -> void:
    var linear_diff := target_linear_velocity - filtered_linear_velocity
    var linear_max_delta := linear_accel_limit * delta
    if linear_diff.length() <= linear_max_delta:
        filtered_linear_velocity = target_linear_velocity
    else:
        filtered_linear_velocity += linear_diff.limit_length(linear_max_delta)
    
    var angular_diff := target_angular_velocity - filtered_angular_velocity
    var angular_max_delta := angular_accel_limit * delta
    if absf(angular_diff) <= linear_accel_limit:
        filtered_angular_velocity = target_angular_velocity
    else:
        filtered_angular_velocity += clampf(angular_diff, -angular_max_delta, angular_max_delta)
#    print(target_linear_velocity, filtered_linear_velocity)

func _cmd_vel_filtered_callback(msg: Dictionary) -> void:
    _actual_linear_vel.x = msg.linear.x
    _actual_linear_vel.y = msg.linear.y
    _actual_angular_vel = msg.angular.z

func _steer_states_callback(msg: Dictionary) -> void:
    steer_angles = msg.angles
    steer_currents = msg.currents
    steer_velocities = msg.velocities
    steer_state_changed.emit()

func _publish_command() -> void:
    if cmd_vel_publisher_enabled:
        _cmd_vel_stamped_pub.publish({
            "header": {
                "frame_id": cmd_vel_frame
            },
            "twist": {
                "linear": {
                    "x": filtered_linear_velocity.x,
                    "y": filtered_linear_velocity.y
                },
                "angular": {
                    "z": filtered_angular_velocity
                }
            }
        })

func get_filtered_target_linear_velocity() -> Vector2: return _actual_linear_vel
func get_filtered_target_angular_velocity() -> float: return _actual_angular_vel

func start_unwinding() -> void:
    _unwind_cli.call_service({})

func set_cmd_vel_frame(frame: String) -> void:
    cmd_vel_frame = frame
    cmd_vel_frame_changed.emit()

func set_cmd_vel_publisher_enabled(enabled: bool) -> void:
    cmd_vel_publisher_enabled = enabled
    cmd_vel_publisher_enabled_changed.emit()

func set_donfan_cmd(dir: int) -> void:
    donfan_cmd = dir
    _donfan_cmd_pub.publish({"data": dir})
    donfan_cmd_changed.emit()

func set_expander_length(length: float) -> void:
    expander_length = length
    _expander_length_pub.publish({"data": length})
    expander_length_changed.emit()

func set_collector_cmd(cmd: bool) -> void:
    collector_cmd = cmd
    _collector_cmd_pub.publish({"data": cmd})
    collector_cmd_changed.emit()

func set_arm_angle(angle: float) -> void:
    arm_angle = angle
    _arm_angle_pub.publish({"data": angle})
    arm_angle_changed.emit()

func set_arm_length(length: float) -> void:
    arm_length = length
    _arm_length_pub.publish({"data": length})
    arm_length_changed.emit()

func set_large_wheel_cmd(cmd: float) -> void:
    large_wheel_cmd = cmd
    _large_wheel_cmd_pub.publish({"data": cmd})
    large_wheel_cmd_changed.emit()

func set_linear_accel_limit(limit: float) -> void:
    linear_accel_limit = limit
    linear_accel_limit_changed.emit()

func set_angular_accel_limit(limit: float) -> void:
    angular_accel_limit = limit
    angular_accel_limit_changed.emit()
