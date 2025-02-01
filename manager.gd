class_name SceneManager
extends Node

enum Scene {GAME_SCENE, MENU_SCENE, LOBBY_SCENE}
enum Intent {DEFAULT, LOBBY_PLAY, LOBBY_HOST}

@export_group("Scenes")
@export var game_scene: Game
@export var menu_scene: Menu
@export var lobby_scene: Lobby

@onready var scene_map = {
	Scene.GAME_SCENE: game_scene,
	Scene.MENU_SCENE: menu_scene,
	Scene.LOBBY_SCENE: lobby_scene,
}

signal jumped_to_scene(scene, intent)

func _ready():
	_jumped_to_scene(Scene.MENU_SCENE, Intent.DEFAULT)
	jumped_to_scene.connect(_jumped_to_scene)

func _jumped_to_scene(scene: Scene, intent: Intent):
	for k in scene_map:
		if (k == scene):
			scene_map[k].show()
		else:
			scene_map[k].hide()
	if intent == Intent.DEFAULT:
		return
	elif intent == Intent.LOBBY_PLAY:
		lobby_scene.intent_play()
	elif intent == Intent.LOBBY_HOST:
		lobby_scene.intent_host()
