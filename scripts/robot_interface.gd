extends Node

signal cmd_vel_frame_changed()
signal donfan_cmd_changed()
signal expander_length_changed()
signal collector_cmd_changed()
signal arm_length_changed()
signal arm_angle_changed()
signal large_wheel_cmd_changed()

var cmd_vel_frame := "base_footprint"
var donfan_cmd: int
var expander_length: float
var collector_cmd: bool
var arm_angle: float
var arm_length: float
var large_wheel_cmd: float

var target_linear_velocity := Vector2()
var target_angular_velocity := 0.0

var _publish_command_timer := Timer.new()
@onready var _cmd_vel_stamped_pub := rosbridge.create_publisher("geometry_msgs/TwistStamped", "cmd_vel_stamped")
@warning_ignore("unused_private_class_variable")
@onready var _cmd_vel_filtered_sub := rosbridge.create_subscription("geometry_msgs/Twist", "cmd_vel_filtered", _cmd_vel_filtered_callback)
var _filtered_linear_vel := Vector2()
var _filtered_angular_vel := 0.0

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

func _cmd_vel_filtered_callback(msg: Dictionary) -> void:
    _filtered_linear_vel.x = msg.linear.x
    _filtered_linear_vel.y = msg.linear.y
    _filtered_angular_vel = msg.angular.z

func _publish_command() -> void:
    _cmd_vel_stamped_pub.publish({
        "header": {
            "frame_id": cmd_vel_frame
        },
        "twist": {
            "linear": {
                "x": target_linear_velocity.x,
                "y": target_linear_velocity.y
            },
            "angular": {
                "z": target_angular_velocity
            }
        }
    })

func get_filtered_target_linear_velocity() -> Vector2: return _filtered_linear_vel
func get_filtered_target_angular_velocity() -> float: return _filtered_angular_vel

func start_unwinding() -> void:
    _unwind_cli.call_service({})

func set_cmd_vel_frame(frame: String) -> void:
    cmd_vel_frame = frame
    cmd_vel_frame_changed.emit()

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
