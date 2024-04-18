extends Panel

@onready var check_button: CheckButton = $CheckButton

func _ready() -> void:
	check_button.toggled.connect(
		func(button_pressed: bool):
			RobotInterface.set_collector_cmd(check_button.button_pressed)
	)
	RobotInterface.collector_cmd_changed.connect(
		func():
			check_button.button_pressed = RobotInterface.collector_cmd
	)
