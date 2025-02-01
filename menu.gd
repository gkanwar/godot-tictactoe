class_name Menu
extends Control

@onready var play_button: Button = %PlayButton
@onready var host_button: Button = %HostButton
@onready var exit_button: Button = %ExitButton
@onready var scene_manager: Node = %SceneManager


func _ready():
	play_button.pressed.connect(_play_pressed)
	host_button.pressed.connect(_host_pressed)
	exit_button.pressed.connect(_exit_pressed)

func _play_pressed():
	scene_manager.jumped_to_scene.emit(
		SceneManager.Scene.LOBBY_SCENE, SceneManager.Intent.LOBBY_PLAY)

func _host_pressed():
	scene_manager.jumped_to_scene.emit(
		SceneManager.Scene.LOBBY_SCENE, SceneManager.Intent.LOBBY_HOST)

func _exit_pressed():
	get_tree().quit()
