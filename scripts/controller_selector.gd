extends Control

@onready var main_button: Button = %MainButton
@onready var sub_a_button: Button = %SubAButton
@onready var sub_b_button: Button = %SubBButton

const controller:= preload("res://controller.tscn")
#const sub_controller := preload("res://sub_controller.tscn")

func _ready() -> void:
    main_button.pressed.connect(switch_scene.bind(controller, true, 0))
    sub_a_button.pressed.connect(switch_scene.bind(controller, false, 0))
    sub_b_button.pressed.connect(switch_scene.bind(controller, false, 1))

func switch_scene(to: PackedScene, is_main: bool, arm_index: int) -> void:
    var instance := to.instantiate()
    (instance as RobotController).init(is_main, arm_index)
    get_tree().root.add_child(instance)
    queue_free()
