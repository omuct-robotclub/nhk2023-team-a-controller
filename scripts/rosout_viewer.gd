extends VBoxContainer

@export var history_length = 100

@onready var autoscroll_button: CheckButton = %AutoscrollButton
@onready var tree: Tree = %Tree
@onready var root := tree.create_item()
@onready var _rosout_sub := rosbridge.create_subscription("rcl_interfaces/Log", "/rosout", _rosout_callback)

var _msg_count := 0

func _ready() -> void:
    tree.hide_root = true
    tree.columns = 4
    tree.set_column_expand(0, false)
    tree.set_column_expand(2, false)
    tree.set_column_expand(3, false)

    tree.set_column_custom_minimum_width(0, 100)
    tree.set_column_custom_minimum_width(2, 100)

    tree.column_titles_visible = true
    tree.set_column_title(0, "#")
    tree.set_column_title(1, "Message")
    tree.set_column_title(2, "Node")
    tree.set_column_title(3, "Severity")

static func _level_to_text(level: int) -> String:
    if level <= 10: return "DEBUG"
    elif level <= 20: return "INFO"
    elif level <= 30: return "WARN"
    elif level <= 40: return "ERROR"
    elif level <= 50: return "FATAL"
    else: return "FATAL"

static func _level_to_color(level: int) -> Color:
    if level <= 10: return Color.DIM_GRAY
    elif level <= 20: return Color.WHITE
    elif level <= 30: return Color.ORANGE
    elif level <= 40: return Color.RED
    elif level <= 50: return Color.DARK_RED
    else: return Color.DARK_RED

func _rosout_callback(msg: Dictionary) -> void:
    var level_text := _level_to_text(msg["level"])
    var level_color := _level_to_color(msg["level"])
    var item := tree.create_item(root)
    item.set_text(0, "%4d  " % _msg_count)
    item.set_text(1, msg["msg"])
    item.set_text(2, msg["name"] + "  ")
    item.set_text(3, level_text.rpad(6))
    item.set_custom_color(3, level_color)
    
    if autoscroll_button.button_pressed:
        tree.scroll_to_item(item)
    
    while history_length < root.get_child_count():
        root.remove_child(root.get_child(0))
    _msg_count += 1
