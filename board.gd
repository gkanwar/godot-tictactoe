class_name Board
extends Node2D

@onready var tile_11: Tile = $Tile11
@onready var tile_12: Tile = $Tile12
@onready var tile_13: Tile = $Tile13
@onready var tile_21: Tile = $Tile21
@onready var tile_22: Tile = $Tile22
@onready var tile_23: Tile = $Tile23
@onready var tile_31: Tile = $Tile31
@onready var tile_32: Tile = $Tile32
@onready var tile_33: Tile = $Tile33

@onready var tile_grid = [
	[tile_11, tile_12, tile_13],
	[tile_21, tile_22, tile_23],
	[tile_31, tile_32, tile_33],
]

@onready var game: Game = %Game
var playing: bool = true

func connect_tile_clicked(tile, i, j):
	tile.tile_clicked.connect(func(): _on_tile_clicked(i, j))

func _ready():
	assert(game != null)
	for i in range(len(tile_grid)):
		var row = tile_grid[i]
		for j in range(len(row)):
			connect_tile_clicked(row[j], i, j)

func complete_line(x):
	var tile_state = x[0].state
	if tile_state == Tile.State.EMPTY:
		return false
	for xi in x:
		if xi.state != tile_state:
			return false
	return true

func check_game_over():
	var n_rows = len(tile_grid)
	var n_cols = len(tile_grid[0])
	for i in range(n_rows):
		if complete_line(tile_grid[i]):
			return true
	for j in range(n_cols):
		var col = range(n_rows).map(func(i): return tile_grid[i][j])
		if complete_line(col):
			return true
	var diag1 = range(n_rows).map(func(i): return tile_grid[i][i])
	var diag2 = range(n_rows).map(func(i): return tile_grid[n_rows-i-1][i])
	if complete_line(diag1):
		return true
	if complete_line(diag2):
		return true
	return false

func _on_tile_clicked(i, j):
	if tile_grid[i][j].state != Tile.State.EMPTY:
		return
	if not playing:
		return
	if Global.player == Global.Player.PLAYER_X:
		tile_grid[i][j].state = Tile.State.X
	else:
		tile_grid[i][j].state = Tile.State.O
	if check_game_over():
		playing = false
		game.game_over.emit(Global.player)
	Global.player = Global.switch_player(Global.player)
