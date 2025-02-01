class_name Tile
extends Node2D

signal tile_clicked

enum State { EMPTY, X, O }
var _state: State = State.EMPTY
var state : State :
	set = _set_state, get = _get_state

func _ready():
	state = State.EMPTY

func _get_state():
	return _state
func _set_state(state: State):
	_state = state
	if _state == State.EMPTY:
		$X.hide()
		$O.hide()
	elif _state == State.X:
		$X.show()
		$O.hide()
	elif _state == State.O:
		$X.hide()
		$O.show()

func _on_click_target_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		tile_clicked.emit()
