extends Button


func _ready() -> void:
    pressed.connect(
        func():
            var dir := DirAccess.open("user://")
            for filename in dir.get_files():
                if filename.begins_with("preset_") and filename.ends_with(".json"):
                    print("file deleted: %s" % filename)
                    dir.remove(filename)
    )
