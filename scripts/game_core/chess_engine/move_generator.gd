## MoveGenerator: Generates all legal moves for a position
class_name MoveGenerator
extends RefCounted

const Position = preload("res://scripts/game_core/chess_engine/position.gd")
const ChessPiece = preload("res://scripts/game_core/chess_engine/chess_piece.gd")
const Move = preload("res://scripts/game_core/chess_engine/move.gd")
const BoardState = preload("res://scripts/game_core/chess_engine/board_state.gd")
const MoveValidator = preload("res://scripts/game_core/chess_engine/move_validator.gd")
const ChessRules = preload("res://scripts/game_core/chess_engine/chess_rules.gd")

var board_state: BoardState
var validator: MoveValidator

func _init(p_board_state: BoardState) -> void:
	board_state = p_board_state
	validator = MoveValidator.new(p_board_state)

func generate_all_moves(side: int) -> Array[Move]:
	var moves: Array[Move] = []
	var pieces = board_state.get_all_pieces_for_side(side)
	
	for piece in pieces:
		var piece_moves = generate_moves_for_piece(piece)
		moves.append_array(piece_moves)
	
	return moves

func generate_moves_for_piece(piece: ChessPiece) -> Array[Move]:
	var moves: Array[Move] = []
	
	# Try all possible destination squares
	for x in range(9):
		for y in range(10):
			for z in range(3):
				var to = Position.new(x, y, z)
				if validator.is_legal_move(piece.position, to):
					var move = Move.new(piece.position, to, piece)
					var target = board_state.get_piece_at(to)
					if target:
						move.captured_piece = target
					moves.append(move)
	
	return moves

func get_capture_moves(side: int) -> Array[Move]:
	var all_moves = generate_all_moves(side)
	var capture_moves: Array[Move] = []
	
	for move in all_moves:
		if move.is_capture():
			capture_moves.append(move)
	
	return capture_moves

func get_moves_for_piece(piece: ChessPiece) -> Array[Move]:
	return generate_moves_for_piece(piece)

func has_legal_moves(side: int) -> bool:
	return generate_all_moves(side).size() > 0
