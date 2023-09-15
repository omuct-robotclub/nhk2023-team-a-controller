extends Button


func _ready() -> void:
    pressed.connect(
        func() -> void:
            OS.shell_open("https://github.com/omuct-robotclub/nhk2023-team-a-controller/releases")
    )
