extends Node

class Subscription:
    signal on_message(msg: Variant)
    var _id: int
    var _typesupprt: GDScript

    func _init(id: int, typesupport: GDScript) -> void:
        _id = id
        _typesupprt = typesupport

    func _dispatch(bytes: PackedByteArray) -> void:
        on_message.emit(_typesupprt.decode(bytes, 12))

class MessageEncoder:
    var data: PackedByteArray
    var pos := 0

    func reserve(s: int) -> void:
        var new_size = pos + s
        if new_size > data.size():
            data.resize(pos + s)
    
    func f32(v: float) -> void:
        reserve(4)
        data.encode_float(v, pos)
        pos += 4
    
    func f64(v: float) -> void:
        reserve(8)
        data.encode_double(v, pos)
        pos += 8
    
    func i8(v: int) -> void:
        reserve(1)
        data.encode_s8(v, pos)
        pos += 1

    func i16(v: int) -> void:
        reserve(2)
        data.encode_s8(v, pos)
        pos += 2

    func i32(v: int) -> void:
        reserve(4)
        data.encode_s8(v, pos)
        pos += 4

    func i64(v: int) -> void:
        reserve(8)
        data.encode_s8(v, pos)
        pos += 8
    
    func u8(v: int) -> void:
        reserve(1)
        data.encode_s8(v, pos)
        pos += 1

    func u16(v: int) -> void:
        reserve(2)
        data.encode_s8(v, pos)
        pos += 2

    func u32(v: int) -> void:
        reserve(4)
        data.encode_s8(v, pos)
        pos += 4

    func u64(v: int) -> void:
        reserve(8)
        data.encode_s8(v, pos)
        pos += 8

class Publisher:
    var _id: int
    var _typesupport: GDScript
    
    func _init(id: int, typesupport: GDScript) -> void:
        _id = id
        _typesupport = typesupport
    
    func publish(msg: Variant) -> void:
        var bytes := PackedByteArray()
        bytes.resize(5)
        bytes.encode_u8(0, 0x01)
        bytes.encode_u32(1, _id)
        _typesupport.encode(msg, )

var _url := "ws://localhost:8765"
var _sock := WebSocketPeer.new()
var _sub_channels: Dictionary
var _sub_data: Dictionary
var _subs: Dictionary
var _pub_chennels: Dictionary
var _services: Dictionary

enum State {
    INACTIVE,
    ACTIVE,
}

var _state := State.INACTIVE

func _init() -> void:
    _sock.supported_protocols = ["foxglove.websocket.v1"]

func _ready() -> void:
    _sock.connect_to_url(_url)

func _server_info(d: Dictionary) -> void:
    print("Server info:")
    print("  name: ", d.name)
    print("  capabilities: ", d.capabilities)
    print("  supportedEncodings: ", d.supportedEncodings)

func _server_status(d: Dictionary) -> void:
    match d.level:
        0: print("info: ", d.message)
        1: push_warning("warn: ", d.message)
        2: push_error("error: ", d.message)

func _server_advertise(d: Dictionary) -> void:
    for chan in d.channels:
        print(chan.topic, " ", chan.encoding)
        _sub_channels[chan.id] = chan

func _server_unadvertise(d: Dictionary) -> void:
    for id in d.channelIds:
        _sub_channels.erase(id)

func _server_advertise_services(d: Dictionary) -> void:
    for srv in d.services:
        _services[srv.id] = srv

func _server_unadvertise_services(d: Dictionary) -> void:
    for id in d.serviceIds:
        _services.erase(id)

func _server_subscribe(d: Dictionary) -> void:
    for sub in d.subscriptions:
        _sub_data[d.id] = d

func _server_unsubscribe(d: Dictionary) -> void:
    for id in d.subscriptionIds:
        _sub_data.erase(id)

func _server_message_data(data: PackedByteArray) -> void:
    var id = data.decode_u32(1)
    if id in _subs:
        _subs[id]._dispatch(data)

func _send(data: Dictionary) -> void:
    var bytes := JSON.stringify(data).to_utf8_buffer()
    _sock.send(bytes, WebSocketPeer.WRITE_MODE_BINARY)

func _client_advertise(id: int, topic: String, encoding: String, schemaName: String) -> void:
    _send({
        "op": "advertise",
        "channels": [{
            "id": id, "topic": topic, "encoding": encoding, "schemaName": schemaName
        }]
    })

func _client_unadvertise(id: int) -> void:
    _send({"op": "unadvertise", "channelIds": [id]})

func _client_get_parameters(parameterNames: Array[String], id: String) -> void:
    _send({"op": "getParameters", "parameterNames": parameterNames, "id": id})

func _client_set_parameters(parameters: Dictionary, id: String) -> void:
    _send({"op": "setParameters", "parameters": parameters, "id": id})

func _client_subscribe_parameter_updates(parameterNames: Array[String]) -> void:
    _send({"op": "subscribeParameterUpdates", "parameterNames": parameterNames})

func _client_unsubscribe_parameter_updates(parameterNames: Array[String]) -> void:
    _send({"op": "unsubscribeParameterUpdates", "parameterNames": parameterNames})

func _client_message_data(data: PackedByteArray) -> void:
    _sock.send(data)

func _dispatch_packet(pack: PackedByteArray):
    var str := pack.get_string_from_utf8()
    var data = JSON.parse_string(str)
    match data["op"]:
        "serverInfo": _server_info(data)
        "status": _server_status(data)
        "advertise": _server_advertise(data)
        "unadvertise": _server_unadvertise(data)
        "advertiseServices": _server_advertise_services(data)
        "unadvertiseServices": _server_unadvertise_services(data)
        "subscribe": _server_subscribe(data)
        "unsubscribe": _server_unsubscribe(data)
        _: pass

func _process(_delta: float):
    _sock.poll()
    match _sock.get_ready_state():
        WebSocketPeer.STATE_CONNECTING:
            pass
        WebSocketPeer.STATE_OPEN:
            while _sock.get_available_packet_count():
                _dispatch_packet(_sock.get_packet())
        WebSocketPeer.STATE_CLOSING:
            pass
        WebSocketPeer.STATE_CLOSED:
            var code := _sock.get_close_code()
            var reason := _sock.get_close_reason()
            print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
            _sock.connect_to_url(_url)
