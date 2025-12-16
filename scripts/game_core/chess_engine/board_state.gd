## BoardState: Represents complete board state
## Manages piece positions, game history, and board state
class_name BoardState
extends RefCounted

const Position = preload("res://scripts/game_core/chess_engine/position.gd")
const ChessPiece = preload("res://scripts/game_core/chess_engine/chess_piece.gd")
const Move = preload("res://scripts/game_core/chess_engine/move.gd")

# Board dimensions
const BOARD_WIDTH = 9
const BOARD_HEIGHT = 10
const BOARD_LAYERS = 3

var pieces: Array[ChessPiece] = []  # All pieces on board
var board: Array = []               # 3D array for piece lookup [x][y][z]
var current_player: int = ChessPiece.RED  # 0 for red, 1 for black
var move_history: Array[Move] = []  # History of all moves
var captured_pieces: Array[ChessPiece] = []  # Captured pieces

func _init() -> void:
	_initialize_board()

func _initialize_board() -> void:
	# Create 3D board array
	board = []
	for x in range(BOARD_WIDTH):
		var col = []
		for y in range(BOARD_HEIGHT):
			var layer = []
			for z in range(BOARD_LAYERS):
				layer.append(null)
			col.append(layer)
		board.append(col)

func place_piece(piece: ChessPiece) -> bool:
	if not piece.position.is_valid():
		return false
	
	# Check if square is already occupied
	if board[piece.position.x][piece.position.y][piece.position.z] != null:
		return false
	
	# Place piece on board
	board[piece.position.x][piece.position.y][piece.position.z] = piece
	pieces.append(piece)
	return true

func remove_piece(position: Position) -> ChessPiece:
	if not position.is_valid():
		return null
	
	var piece = board[position.x][position.y][position.z]
	if piece:
		board[position.x][position.y][position.z] = null
		pieces.erase(piece)
	return piece

func get_piece_at(position: Position) -> ChessPiece:
	if not position.is_valid():
		return null
	return board[position.x][position.y][position.z]

func move_piece(from: Position, to: Position) -> bool:
	if not from.is_valid() or not to.is_valid():
		return false
	
	var piece = get_piece_at(from)
	if not piece:
		return false
	
	# Remove piece from source
	board[from.x][from.y][from.z] = null
	
	# Place piece at destination
	piece.position = to
	board[to.x][to.y][to.z] = piece
	return true

func capture_piece(position: Position) -> ChessPiece:
	var piece = remove_piece(position)
	if piece:
		piece.captured = true
		captured_pieces.append(piece)
	return piece

func record_move(move: Move) -> void:
	move_history.append(move)

func get_all_pieces_for_side(side: int) -> Array[ChessPiece]:
	var result: Array[ChessPiece] = []
	for piece in pieces:
		if piece.side == side and not piece.captured:
			result.append(piece)
	return result

func get_king(side: int) -> ChessPiece:
	for piece in pieces:
		if piece.type == ChessPiece.KING and piece.side == side and not piece.captured:
			return piece
	return null

func duplicate() -> BoardState:
	var new_state = BoardState.new()
	
	# Copy pieces
	for piece in pieces:
		var new_piece = piece.duplicate()
		new_state.pieces.append(new_piece)
		var x = new_piece.position.x
		var y = new_piece.position.y
		var z = new_piece.position.z
		new_state.board[x][y][z] = new_piece
	
	# Copy other state
	new_state.current_player = current_player
	new_state.captured_pieces = captured_pieces.duplicate()
	new_state.move_history = move_history.duplicate()
	
	return new_state

func _to_string() -> String:
	var piece_count = pieces.size()
	var move_count = move_history.size()
	return "BoardState: %d pieces, %d moves, player=%d" % [
		piece_count, move_count, current_player
	]
