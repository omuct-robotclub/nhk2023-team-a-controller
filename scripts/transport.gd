extends RefCounted
class_name Transport


# warning-ignore:unused_signal
signal msg_received(data)

func open() -> void:
    push_error("Not implemented")

func send(_data: Dictionary) -> void:
    push_error("Not implemented")

func is_ready() -> bool:
    push_error("Not implemented")
    return false

func poll() -> void:
    push_error("Not implemented")

func close() -> void:
    push_error("Not implemented")

func get_name() -> String:
    return "Default"

func get_total_download() -> int:
    return 0

func get_total_upload() -> int:
    return 0
