extends MarginContainer


func _ready() -> void:
    if OS.get_name() != "Android": return
    
    var safe_area := DisplayServer.get_display_safe_area()
    var window_size := DisplayServer.window_get_size()

    print(safe_area)
    print(window_size)

    var top := 0
    var left := 0
    var bottom := 0
    var right := 0

    if window_size.x >= safe_area.size.x and window_size.y >= safe_area.size.y:
        left = safe_area.position.x
        right = window_size.x - safe_area.size.x - safe_area.position.x
        top = safe_area.position.y
        bottom = window_size.y - safe_area.size.y - safe_area.position.y

    add_theme_constant_override("margin_top", top)
    add_theme_constant_override("margin_left", left)
    add_theme_constant_override("margin_right", right)
    add_theme_constant_override("margin_bottom", bottom)
