class_name Lobby
extends Control

@export var player_slots: Array[PlayerSlot]
@onready var join_form: HBoxContainer = %JoinForm
@onready var host_form: HBoxContainer = %HostForm
@onready var join_button: Button = %JoinForm/JoinButton
@onready var host_button: Button = %HostForm/HostButton
@onready var start_button: Button = %StartButton
@onready var scene_manager: Node = %SceneManager

var player_ids = []
var player_selections = []

func _ready():
	join_button.pressed.connect(_join_pressed)
	host_button.pressed.connect(_host_pressed)
	start_button.pressed.connect(_start_pressed)
	Global.player_connected.connect(_player_connected)
	Global.player_updated.connect(_player_updated)
	Global.player_disconnected.connect(_player_disconnected)
	start_button.disabled = true
	for i in range(len(player_slots)):
		player_selections.append(null)
		player_ids.append(0)
		connect_slot_callback(i)

func connect_slot_callback(i: int):
	player_slots[i].player_selected.connect(
		func(player: Global.Player): _player_selected(i, player)
	)

func _player_selected(i: int, player: Global.Player):
	Global.players[player_ids[i]].selection = player
	player_selections[i] = player
	for selection in player_selections:
		if selection == null:
			start_button.disabled = true
			return
	start_button.disabled = (player_selections[0] == player_selections[1])

func _player_connected(id, info):
	print("Player connected %s %s" % [id, info])
	var is_me = id == Global.my_peer_id
	var idx = 0 if id == 1 else 1
	player_ids[idx] = id
	player_slots[idx].connect_player(info, is_me)
func _player_updated(id, old_info, new_info):
	print("Player update %s %s -> %s" % [id, old_info, new_info])
	var is_me = id == Global.my_peer_id
	var idx = 0 if id == 1 else 1
	player_slots[idx].update_player(old_info, new_info, is_me)
func _player_disconnected(id):
	print("Player disconnected %s" % id)
	var idx = 0 if id == 1 else 1
	player_ids[idx] = 0
	player_slots[idx].disconnect_player()

func intent_play():
	host_form.hide()
	start_button.hide()
	join_form.show()

func intent_host():
	host_form.show()
	start_button.show()
	join_form.hide()

func _join_pressed():
	print("join pressed")
	var name_field: LineEdit = join_form.find_child("NameField")
	var host_field: LineEdit = join_form.find_child("HostField")
	var player_info = {
		name = name_field.text
	}
	var error = Global.join_game(player_info, host_field.text)
	if error:
		print("Error %s" % error)

func _host_pressed():
	print("host pressed")
	var name_field: LineEdit = host_form.find_child("NameField")
	var player_info = {
		name = name_field.text
	}
	var error = Global.host_game(player_info)
	if error:
		print("Error %s" % error)

@rpc("any_peer", "call_local", "reliable")
func launch_game():
	scene_manager.jumped_to_scene.emit(
		SceneManager.Scene.GAME_SCENE, SceneManager.Intent.DEFAULT)

func _start_pressed():
	print("start pressed")
	launch_game.rpc()
