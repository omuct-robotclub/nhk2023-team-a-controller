extends Transport

const listen_port := 5007
const send_port := 5008
const reply_port := 5009
const multicast_addr := "224.1.1.1"
const mcast_name := "robot"
const mcast_period_ms := 1000

var _socket: PacketPeerUDP
var _server: UDPServer
var _cli: WebSocketPeer
var _last_multicast_send_ms: int

var _total_download: int
var _total_upload: int

func open():
    _socket = PacketPeerUDP.new()
    _server = UDPServer.new()
    _cli = WebSocketPeer.new()
    _last_multicast_send_ms = Time.get_ticks_msec()

    if _socket.bind(listen_port, multicast_addr) != OK:
        push_error("coundn't listen " + str(listen_port))

    var interfaces := IP.get_local_interfaces()

    var multicastable_iface_count := 0
    for iface in interfaces:
        var err := _socket.join_multicast_group(multicast_addr, iface["name"])

        if err != OK:
            print("joining multicast group failed. interface: ", iface["name"])
        else:
            multicastable_iface_count += 1

    if multicastable_iface_count == 0:
        push_error("No multicastable interface available")

    if _server.listen(reply_port) != OK:
        push_error("listen failed")

func poll() -> void:
    if _server.poll() != OK:
        push_error("UDPServer poll error")

    _cli.poll()
    
    if _cli.get_ready_state() == WebSocketPeer.STATE_CLOSED:
        var now := Time.get_ticks_msec()
        if now - _last_multicast_send_ms >= mcast_period_ms:
            _last_multicast_send_ms = now
            _send_multicast()

        if _socket.get_available_packet_count() > 0:
            print("multicast received")
            var server_ip := _socket.get_packet_ip()
            var array_bytes := _socket.get_packet()
            var data_str = array_bytes.get_string_from_utf8()

            if server_ip != "" and  len(data_str) > 24 and data_str.substr(0, 24) == "robot_discovery_service:":
                var url := "ws://" + str(server_ip) + ":9090"
                print("connecting to " + url)
                var err := _cli.connect_to_url(url)
                _cli.set_no_delay(true)
                assert(err == OK)
                return

        if _server.is_connection_available():
            print("response received")
            var peer: PacketPeerUDP = _server.take_connection()
            var server_ip := peer.get_packet_ip()

            if server_ip != "":
                var url := "ws://" + str(server_ip) + ":9090"
                print("connecting to " + url)
                var err := _cli.connect_to_url(url)
#                assert(err == OK)
                return
    elif _cli.get_ready_state() == WebSocketPeer.STATE_OPEN:
        if _socket.get_available_packet_count() > 0:
            var _server_ip := _socket.get_packet_ip()
            var _array_bytes := _socket.get_packet()

        if _server.is_connection_available():
            var _peer: PacketPeerUDP = _server.take_connection()

        while _cli.get_available_packet_count():
            var data := _cli.get_packet()
            _total_download += data.size()
            var j := JSON.new()
            var res := j.parse(data.get_string_from_utf8())
            if res == OK:
                msg_received.emit(j.data)
            else:
                push_error("parse error")

func is_ready() -> bool:
    return _cli.get_ready_state() == WebSocketPeer.STATE_OPEN

func close() -> void:
    _socket.close()
    _server.stop()
    _cli.close()

func send(data: Dictionary) -> void:
    var bytes := JSON.stringify(data).to_utf8_buffer()
    _total_upload += bytes.size()
    if _cli.put_packet(bytes) != OK:
        printerr("put packet failed")

func get_total_download() -> int:
    return _total_download

func get_total_upload() -> int:
    return _total_upload

func get_name() -> String:
    return "Websocket"

func _send_multicast():
    if _socket.set_dest_address(multicast_addr, send_port) != OK:
        push_error("set dest address failed")
    if _socket.put_packet(("robot_discovery_service:" + mcast_name).to_ascii_buffer()) != OK:
        push_error("err")
