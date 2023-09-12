extends Panel

@onready var extend: Button = $VBoxContainer/Extend
@onready var retract: Button = $VBoxContainer/Retract


func _ready() -> void:
    extend.pressed.connect(
        func():
            RobotInterface.set_donfan_cmd(1)
    )
    retract.pressed.connect(
        func():
            RobotInterface.set_donfan_cmd(-1)
    )
