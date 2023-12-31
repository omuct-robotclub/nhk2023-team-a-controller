extends Node

const WebsocketTransport = preload("res://scripts/websocket_transport.gd")

func _ready() -> void:
    var tp = WebsocketTransport.new()
    tp.open()
    rosbridge.add_transport(tp)
