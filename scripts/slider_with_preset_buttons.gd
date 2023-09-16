extends HBoxContainer
class_name SliderWithPresetButtons

@export var display_name: String
@export var save_name: String
@export var value_format := "%0.1f [mm]"
@export var button_name_format := "%s  (%0.1f [mm])"
@export var min_value := 0.0
@export var max_value := 500.0
@export var preset_names: Array[String]
@export var preset_values: Array[float]

@onready var slider: VSlider = %Slider
@onready var name_label: Label = %NameLabel
@onready var current_value_label: Label = %CurrentValueLabel
@onready var buttons: VBoxContainer = %Buttons

signal submitted()

func _ready() -> void:
    name_label.text = display_name
    slider.min_value = min_value
    slider.max_value = max_value
    slider.drag_ended.connect(func(_value_changed: bool): submitted.emit())
    
    _try_load_presets()
    
    _on_value_changed()
    slider.value_changed.connect(_on_value_changed)
    
    _on_preset_changed()
    assert(preset_names.size() == preset_values.size())

func _get_save_path() -> String:
    return "user://preset_%s.json" % save_name

func _try_load_presets() -> void:
    var f := FileAccess.open(_get_save_path(), FileAccess.READ)
    if f == null:
        return
    
    var j = JSON.parse_string(f.get_as_text())
    if typeof(j) != TYPE_ARRAY:
        return
    
    if preset_names.size() != j.size():
        return
    
    preset_values.clear()
    for jj in j:
#        preset_names.push_back(jj["name"])
        preset_values.push_back(jj["value"])

func _save_presets() -> void:
    var f := FileAccess.open(_get_save_path(), FileAccess.WRITE)
    if f == null:
        push_error(error_string(FileAccess.get_open_error()))
        return
    
    var data: Array[Dictionary] = []
    for i in range(preset_names.size()):
        data.push_back({"name": preset_names[i], "value": preset_values[i]})

    f.store_line(JSON.stringify(data))

func _on_value_changed(_value: float = 0.0) -> void:
    current_value_label.text = value_format % slider.value

func _on_preset_changed() -> void:
    for c in buttons.get_children():
        buttons.remove_child(c)
    for i in range(preset_names.size()):
        var b := LongPressButton.new()
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.size_flags_vertical = Control.SIZE_EXPAND_FILL
        b.text = button_name_format % [preset_names[i], preset_values[i]]
        b.long_pressed.connect(
            func():
                preset_values[i] = slider.value
                _on_preset_changed()
        )
        b.normal_pressed.connect(
            func():
                slider.value = preset_values[i]
                submitted.emit()
        )
        buttons.add_child(b)
    _save_presets()
