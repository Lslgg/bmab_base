class_name BoardState
extends RefCounted

## Board State data model for rhythm chess system
## Represents the complete state of the 3D chess board
## Includes piece positions, game phase, and rhythm synchronization data

enum Layer {
	GROUND = 0,    # Ground layer (traditional board level)
	STANDARD = 1,  # Standard layer (main playing level)
	SKY = 2        # Sky layer (elevated level)
}

enum GamePhase {
	OPENING,       # Opening phase - piece development
	MIDDLE_GAME,   # Middle game - tactical combat
	END_GAME       # End game - few pieces remaining
}

# Board dimensions (Chinese chess: 9x10)
const BOARD_WIDTH: int = 9
const BOARD_HEIGHT: int = 10
const LAYER_COUNT: int = 3

# Board state data
var pieces: Array[Array] = []  # 3D array: [layer][x][y] = piece_data
var current_player: String = "red"  # "red" or "black"
var game_phase: GamePhase = GamePhase.OPENING
var move_count: int = 0
var last_move_time: float = 0.0

# Rhythm synchronization data
var last_beat_timestamp: float = 0.0
var moves_on_beat: int = 0
var total_moves: int = 0
var rhythm_accuracy: float = 0.0

# Game state metadata
var game_start_time: float = 0.0
var time_per_player: Dictionary = {"red": 0.0, "black": 0.0}
var captured_pieces: Dictionary = {"red": [], "black": []}

func _init():
	_initialize_board()

## Initialize empty board structure
func _initialize_board():
	pieces.clear()
	
	# Create 3D board structure: [layer][x][y]
	for layer in range(LAYER_COUNT):
		var layer_data = []
		for x in range(BOARD_WIDTH):
			var column = []
			for y in range(BOARD_HEIGHT):
				column.append(null)  # Empty position
			layer_data.append(column)
		pieces.append(layer_data)
	
	game_start_time = Time.get_unix_time_from_system()

## Get piece at specific position
func get_piece(layer: int, x: int, y: int):
	if _is_valid_position(layer, x, y):
		return pieces[layer][x][y]
	return null

## Set piece at specific position
func set_piece(layer: int, x: int, y: int, piece_data):
	if _is_valid_position(layer, x, y):
		pieces[layer][x][y] = piece_data
		return true
	return false

## Remove piece from position
func remove_piece(layer: int, x: int, y: int):
	if _is_valid_position(layer, x, y):
		var piece = pieces[layer][x][y]
		pieces[layer][x][y] = null
		return piece
	return null

## Check if position is valid
func _is_valid_position(layer: int, x: int, y: int) -> bool:
	return (layer >= 0 and layer < LAYER_COUNT and 
			x >= 0 and x < BOARD_WIDTH and 
			y >= 0 and y < BOARD_HEIGHT)

## Move piece from one position to another
func move_piece(from_layer: int, from_x: int, from_y: int, to_layer: int, to_x: int, to_y: int) -> bool:
	var piece = get_piece(from_layer, from_x, from_y)
	if piece == null:
		return false
	
	# Check if target position is valid
	if not _is_valid_position(to_layer, to_x, to_y):
		return false
	
	# Handle capture
	var captured_piece = get_piece(to_layer, to_x, to_y)
	if captured_piece != null:
		_capture_piece(captured_piece)
	
	# Move the piece
	remove_piece(from_layer, from_x, from_y)
	set_piece(to_layer, to_x, to_y, piece)
	
	# Update move tracking
	move_count += 1
	total_moves += 1
	last_move_time = Time.get_unix_time_from_system()
	
	# Switch players
	current_player = "black" if current_player == "red" else "red"
	
	return true

## Handle piece capture
func _capture_piece(piece_data):
	var piece_owner = piece_data.get("owner", "unknown")
	var opponent = "black" if piece_owner == "red" else "red"
	captured_pieces[opponent].append(piece_data)

## Record move made on beat
func record_beat_move(beat_timestamp: float):
	last_beat_timestamp = beat_timestamp
	moves_on_beat += 1
	_update_rhythm_accuracy()

## Update rhythm accuracy calculation
func _update_rhythm_accuracy():
	if total_moves > 0:
		rhythm_accuracy = float(moves_on_beat) / float(total_moves)

## Get current game phase based on pieces remaining
func update_game_phase():
	var total_pieces = _count_total_pieces()
	
	if total_pieces > 20:
		game_phase = GamePhase.OPENING
	elif total_pieces > 10:
		game_phase = GamePhase.MIDDLE_GAME
	else:
		game_phase = GamePhase.END_GAME

## Count total pieces on board
func _count_total_pieces() -> int:
	var count = 0
	for layer in range(LAYER_COUNT):
		for x in range(BOARD_WIDTH):
			for y in range(BOARD_HEIGHT):
				if pieces[layer][x][y] != null:
					count += 1
	return count

## Get board state summary
func get_state_summary() -> Dictionary:
	return {
		"current_player": current_player,
		"game_phase": GamePhase.keys()[game_phase],
		"move_count": move_count,
		"total_pieces": _count_total_pieces(),
		"rhythm_accuracy": rhythm_accuracy,
		"moves_on_beat": moves_on_beat,
		"total_moves": total_moves,
		"game_duration": Time.get_unix_time_from_system() - game_start_time
	}

## Convert to dictionary for serialization
func to_dict() -> Dictionary:
	return {
		"pieces": pieces,
		"current_player": current_player,
		"game_phase": game_phase,
		"move_count": move_count,
		"last_move_time": last_move_time,
		"last_beat_timestamp": last_beat_timestamp,
		"moves_on_beat": moves_on_beat,
		"total_moves": total_moves,
		"rhythm_accuracy": rhythm_accuracy,
		"game_start_time": game_start_time,
		"time_per_player": time_per_player,
		"captured_pieces": captured_pieces
	}

## Create from dictionary (deserialization)
static func from_dict(data: Dictionary) -> BoardState:
	var board_state = BoardState.new()
	
	board_state.pieces = data.get("pieces", [])
	board_state.current_player = data.get("current_player", "red")
	board_state.game_phase = data.get("game_phase", GamePhase.OPENING)
	board_state.move_count = data.get("move_count", 0)
	board_state.last_move_time = data.get("last_move_time", 0.0)
	board_state.last_beat_timestamp = data.get("last_beat_timestamp", 0.0)
	board_state.moves_on_beat = data.get("moves_on_beat", 0)
	board_state.total_moves = data.get("total_moves", 0)
	board_state.rhythm_accuracy = data.get("rhythm_accuracy", 0.0)
	board_state.game_start_time = data.get("game_start_time", 0.0)
	board_state.time_per_player = data.get("time_per_player", {"red": 0.0, "black": 0.0})
	board_state.captured_pieces = data.get("captured_pieces", {"red": [], "black": []})
	
	return board_state
