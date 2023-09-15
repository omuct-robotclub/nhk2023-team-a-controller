extends Button


func _ready() -> void:
    pressed.connect(
        func():
            var dialog := ConfirmationDialog.new()
            add_child(dialog)
            dialog.get_ok_button().custom_minimum_size = Vector2(200, 100)
            dialog.get_cancel_button().custom_minimum_size = Vector2(200, 100)
            dialog.get_label().custom_minimum_size = Vector2(0, 100)
            dialog.get_label().vertical_alignment = VERTICAL_ALIGNMENT_CENTER
            dialog.dialog_text = "Are you sure to you want to delete saved presets?"
            dialog.confirmed.connect(
                _remove_preset_files
            )
            dialog.popup_centered()
    )

static func _remove_preset_files() -> void:
    var dir := DirAccess.open("user://")
    for filename in dir.get_files():
        if filename.begins_with("preset_") and filename.ends_with(".json"):
            print("file deleted: %s" % filename)
            dir.remove(filename)
