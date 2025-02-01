extends Node

### GAMEPLAY
enum Player { PLAYER_X, PLAYER_O }
var player = Player.PLAYER_X

func other_player(p: Player):
	if p == Player.PLAYER_X:
		return Player.PLAYER_O
	else:
		return Player.PLAYER_X

### NETWORKING
const PORT = 7676
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 1

signal player_connected(peer_id, player_info)
signal player_updated(peer_id, old_player_info, new_player_info)
signal player_disconnected(peer_id)
signal server_disconnected()

var players = {}
var my_peer_id = 0
var my_player_info = {}

func _ready():
	var scale = DisplayServer.screen_get_scale()
	get_tree().root.content_scale_factor = scale
	get_window().size *= scale
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_player_connected(id):
	# print("Player connected")
	# no need to do anything, we wait for the peer to register their
	# player info which will then be broadcasted
	pass

func _on_player_disconnected(id):
	# print("Player disconnected")
	players.erase(id)
	_set_players.rpc(players)

func _on_connected_ok():
	my_peer_id = multiplayer.multiplayer_peer.get_unique_id()
	print("Connected ok, ID %s" % my_peer_id)
	# register with the server, who will broadcast the new
	# players list, including us
	_register_player.rpc_id(1, my_player_info)

func _on_connected_failed():
	print("Connected failed")
	players.erase(my_peer_id)
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	print("Server disconnected")
	players.clear()
	my_peer_id = 0
	server_disconnected.emit()

func join_game(player_info, address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	my_player_info = player_info

@rpc("any_peer", "reliable")
func _register_player(player_info):
	var player_id = multiplayer.get_remote_sender_id()
	var all_players = players.duplicate()
	all_players[player_id] = player_info
	_set_players.rpc(all_players)

@rpc("any_peer", "call_local", "reliable")
func _set_players(all_players):
	print("set players %s -> %s" % [players, all_players])
	for k in players:
		if k not in all_players:
			player_disconnected.emit(k)
			players.erase(k)
		else:
			player_updated.emit(k, players[k], all_players[k])
			players[k] = all_players[k]
	for k in all_players:
		if k in players: continue
		player_connected.emit(k, all_players[k])
		players[k] = all_players[k]

func host_game(my_player_info):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	my_peer_id = 1
	var all_players = {
		my_peer_id: my_player_info
	}
	print("hosted!")
	_set_players(all_players)
