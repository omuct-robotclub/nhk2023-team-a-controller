extends Label


func _ready() -> void:
    var release := _get_release()
    text = "Version: %s   Build date: %s      " % [release["version"], release["date"]]

func _get_release() -> Dictionary:
    var result: Dictionary
    var file := FileAccess.open("res://release.json", FileAccess.READ)
    if file == null:
        result["version"] = "custom"
        result["date"] = "unknown"
    else:
        result = JSON.parse_string(file.get_as_text())
    return result
