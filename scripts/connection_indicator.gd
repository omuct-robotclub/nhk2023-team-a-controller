extends VBoxContainer

@onready var state_label: Label = %StateLabel
@onready var transport_name_label: Label = %TransportNameLabel
@onready var interfaces: VBoxContainer = %Interfaces
@onready var upload_label: Label = %UploadLabel
@onready var download_label: Label = %DownloadLabel


var _timer := Timer.new()

func _ready() -> void:
    state_label.text = "Disconnected"
    state_label.self_modulate = Color.RED
    
    transport_name_label.text = "Transport: Not Set"

    rosbridge.connection_established.connect(
        func():
            state_label.text = "Connected"
            state_label.self_modulate = Color.GREEN
    )
    
    rosbridge.disconnected.connect(
        func():
            state_label.text = "Disconnected"
            state_label.self_modulate = Color.RED
    )
    
    rosbridge.transport_changed.connect(
        func():
            var tr := rosbridge.get_current_transport()
            if tr != null:
                transport_name_label.text = "Transport: %s" % tr.get_name()
            else:
                transport_name_label.text = "Transport: Not Set"
    )
    
    _timer.autostart = true
    _timer.wait_time = 1.0
    _timer.timeout.connect(_timer_callback)
    add_child(_timer)
    
    _timer_callback()

func _timer_callback() -> void:
    for child in interfaces.get_children():
        interfaces.remove_child(child)
    var ifaces := IP.get_local_interfaces()
    ifaces.sort_custom(func(a, b): return int(a["index"]) < int(b["index"]))
    for iface in ifaces:
        var text := "  %s: %s: [" % [iface["index"], iface["name"]]
        for ip in iface["addresses"]:
            text += ip
            text += ", "
        text = text.trim_suffix(", ")
        text += "]"
        var label := Label.new()
        label.text = text
        interfaces.add_child(label)
    
    upload_label.text =   "  Upload: %5.0f [B/s]" % rosbridge.get_upload_speed()
    download_label.text = "Download: %5.0f [B/s]" % rosbridge.get_download_speed()
