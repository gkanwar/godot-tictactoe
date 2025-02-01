extends Node

enum Player { PLAYER_X, PLAYER_O }
var player = Player.PLAYER_X

func switch_player(player: Player):
	if player == Player.PLAYER_X:
		return Player.PLAYER_O
	else:
		return Player.PLAYER_X
