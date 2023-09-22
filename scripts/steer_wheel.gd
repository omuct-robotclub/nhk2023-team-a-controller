extends Control

signal offset_changed()

@export var wheel_size: Vector2 = Vector2(50, 100)
@export var offset_magnification := 3.0
@export var line_count := 10

var offset: float
var angle: float
var velocity: float
var current: float
var pos := 0.0

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    var center := size / 2
    draw_set_transform(center - wheel_size / 2, -angle)
    draw_rect(Rect2(-wheel_size / 2, wheel_size), Color.CORAL)

    for i in range(line_count):
        var rot = pos + 2 * PI * (i / float(line_count))
        rot = wrapf(rot, -PI, PI)
        if 0 < rot:
            var y := wheel_size.y*cos(rot)/2
            var color := Color.BLACK
            color.a = 0.8
            draw_line(Vector2(-wheel_size.x / 2, y), Vector2(wheel_size.x / 2, y), color, 2)

    draw_line(Vector2(wheel_size.x / 2 + 8, 0), Vector2(wheel_size.x / 2 + 8, -5 * velocity), Color.ORANGE, 16.0)
    draw_line(Vector2(wheel_size.x / 2 + 16, 0), Vector2(wheel_size.x / 2 + 16, -100), Color.BLACK, 1)
    draw_line(Vector2(wheel_size.x / 2 + 24, 0), Vector2(wheel_size.x / 2 + 24, -10 * current), Color.YELLOW, 16.0)

    draw_line(Vector2(0, -wheel_size.y * 1.15), Vector2(0, -wheel_size.y * 1.25), Color.WHITE)
    draw_arc(Vector2.ZERO, wheel_size.y * 1.2, -PI/2, -offset*offset_magnification - PI/2, 50, Color.WHITE)
    draw_line(Vector2(0, -wheel_size.y * 1.15).rotated(-offset*offset_magnification), Vector2(0, -wheel_size.y * 1.25).rotated(-offset*offset_magnification), Color.WHITE)

func _process(delta: float) -> void:
    pos += velocity * delta * 0.1
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if event.button_mask == MOUSE_BUTTON_LEFT:
            offset -= event.relative.x / size.x
    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
            offset_changed.emit()
