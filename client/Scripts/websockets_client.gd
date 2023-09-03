extends Node

const Packet = preload("res://Scripts/packet.gd")

signal connected
signal data
signal disconnected
signal error

# Our WebSocketClient instance
var _client = WebSocketPeer.new()
var inc_data= StreamPeer
var data_string: int


func _ready():
	pass

func connect_to_server(hostname: String, port: int) -> void:
	# Connects to the server or emits an error signal.
	# If connected, emits a connect signal.
	var websocket_url = "wss://%s:%d" % [hostname, port]
	var err = _client.connect_to_url(websocket_url, TLSOptions.client_unsafe())
	if err:
		print("Unable to connect")
		set_process(false)
		emit_signal("error")


func send_packet(packet: Packet) -> void:
	# Sends a packet to the server
	_send_string(packet.tostring())

func _process(delta):
	_client.poll()
	var state = _client.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while _client.get_available_packet_count():
			var packet = _client.get_packet()
			#print("Packet: ", packet)
			data.emit(packet.get_string_from_utf8())
		
		
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = _client.get_close_code()
		var reason = _client.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.


func _send_string(string: String) -> void:
	#_client.put_packet(string.to_utf8_buffer())
	_client.send_text(string)
	print("Sent string ", string)

