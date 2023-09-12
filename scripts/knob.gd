extends Control
class_name Knob

@export var center_pivot := true
var value := 0.0:
    set(val):
        value = val
        _update_angle()
    get:
        return value

signal value_changed()

func _update_angle() -> void:
    var node := get_child(0) as Control
    if center_pivot:
        node.pivot_offset = node.get_rect().size / 2.0
    node.pivot_offset = node.get_rect().size / 2
    node.rotation = value

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if event.button_mask == MOUSE_BUTTON_LEFT:
            value += event.relative.x / size.x
            _update_angle()
    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
            value_changed.emit()
