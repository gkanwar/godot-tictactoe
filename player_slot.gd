class_name PlayerSlot
extends Control

@onready var name_label: Label = %Name
@onready var server_icon: TextureRect = %ServerIcon
@export var button_group: ButtonGroup
@export var button_x: Button
@export var button_o: Button
@export var is_host: bool

signal player_selected(player)

const EMPTY_TEXT = "<EMPTY>"

func _ready():
	name_label.text = EMPTY_TEXT
	server_icon.visible = is_host
	_set_buttons_enabled(false)
	button_group.pressed.connect(_button_pressed)
	
const MODULATE_SELECTED = Color(1.0, 0.0, 0.0)
const MODULATE_UNSELECTED = Color(1.0, 1.0, 1.0)

@rpc("any_peer", "call_local", "reliable")
func update_selected_button(player: Global.Player):
	print("Setting selected %s to %s" % [name_label.text, player])
	if player == Global.Player.PLAYER_X:
		button_x.self_modulate = MODULATE_SELECTED
		button_o.self_modulate = MODULATE_UNSELECTED
	elif player == Global.Player.PLAYER_O:
		button_o.self_modulate = MODULATE_SELECTED
		button_x.self_modulate = MODULATE_UNSELECTED
	else:
		assert(false)
	player_selected.emit(player)

func get_selected_player():
	var button = button_group.get_pressed_button()
	if button == button_x:
		return Global.Player.PLAYER_X
	elif button == button_o:
		return Global.Player.PLAYER_O
	else:
		assert(false)

func _button_pressed(button: BaseButton):
	update_selected_button.rpc(get_selected_player())

func _set_buttons_enabled(enabled: bool):
	for button in button_group.get_buttons():
		button.disabled = !enabled
func connect_player(info, is_me: bool):
	name_label.text = info.name
	_set_buttons_enabled(is_me)
func update_player(old_info, new_info, is_me: bool):
	if new_info.name != old_info.name:
		# TODO: some kind of animation?
		name_label.text = new_info.name
func disconnect_player():
	name_label.text = EMPTY_TEXT
	_set_buttons_enabled(false)
