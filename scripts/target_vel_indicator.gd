extends Control

@export var linear_color := Color.RED
@export var linear_filtered_color := Color.HOT_PINK
@export var angular_color := Color.GREEN
@export var angular_filtered_color := Color.GREEN_YELLOW
@export var max_linear_velocity := 2.6
@export var max_angular_velocity := 6.0

func conv(vec: Vector2) -> Vector2:
    return Vector2(-vec.y, -vec.x)

func _draw() -> void:
    var linear := RobotInterface.target_linear_velocity
    var angular := RobotInterface.target_angular_velocity
    var linear_filtered := RobotInterface.get_filtered_target_linear_velocity()
    var angular_filtered := RobotInterface.get_filtered_target_angular_velocity()
    
    var center := size / 2
    var linear_scaling = min(size.x, size.y) / 2 / max_linear_velocity
    var angular_scaling :=  size.x / 2 / max_angular_velocity
    
    var angular_line_x := -angular * angular_scaling + center.x
    var angular_filtered_line_x = -angular_filtered * angular_scaling + center.x
    draw_line(Vector2(angular_line_x, 0), Vector2(angular_line_x, size.y), angular_color)
    draw_line(Vector2(angular_filtered_line_x, 0), Vector2(angular_filtered_line_x, size.y), angular_filtered_color)
    
    draw_line(center, center + conv(linear * linear_scaling).clamp(-size / 2, size / 2), linear_color)
    draw_line(center, center + conv(linear_filtered * linear_scaling).clamp(-size / 2, size / 2), linear_filtered_color)

func _process(_delta: float) -> void:
    queue_redraw()
