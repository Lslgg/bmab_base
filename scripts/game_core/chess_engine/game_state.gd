## ChessGameState: Manages chess game state and win/loss conditions
class_name ChessGameState
extends RefCounted

const Position = preload("res://scripts/game_core/chess_engine/position.gd")
const ChessPiece = preload("res://scripts/game_core/chess_engine/chess_piece.gd")
const Move = preload("res://scripts/game_core/chess_engine/move.gd")
const BoardState = preload("res://scripts/game_core/chess_engine/board_state.gd")
const BoardManager = preload("res://scripts/game_core/chess_engine/board_manager.gd")
const MoveValidator = preload("res://scripts/game_core/chess_engine/move_validator.gd")
const MoveGenerator = preload("res://scripts/game_core/chess_engine/move_generator.gd")
const ChessRules = preload("res://scripts/game_core/chess_engine/chess_rules.gd")

var board_manager: BoardManager
var move_generator: MoveGenerator
var move_validator: MoveValidator

func _init() -> void:
	board_manager = BoardManager.new()
	move_generator = MoveGenerator.new(board_manager.get_board_state())
	move_validator = MoveValidator.new(board_manager.get_board_state())

func get_board_state() -> BoardState:
	return board_manager.get_board_state()

func is_in_check(side: int) -> bool:
	var king = board_manager.get_king(side)
	if not king:
		return false
	
	var opponent_side = ChessRules.get_opposite_side(side)
	var opponent_moves = move_generator.generate_all_moves(opponent_side)
	
	for move in opponent_moves:
		if move.to.equals(king.position):
			return true
	
	return false

func is_checkmate(side: int) -> bool:
	# Must be in check
	if not is_in_check(side):
		return false
	
	# No legal moves available
	return not move_generator.has_legal_moves(side)

func is_stalemate(side: int) -> bool:
	# Not in check but no legal moves
	if is_in_check(side):
		return false
	
	return not move_generator.has_legal_moves(side)

func execute_move(from: Position, to: Position) -> bool:
	if not move_validator.is_legal_move(from, to):
		return false
	
	var board = board_manager.get_board_state()
	var piece = board.get_piece_at(from)
	if not piece:
		return false
	
	# Create move object
	var move = Move.new(from, to, piece)
	
	# Handle capture
	var target = board.get_piece_at(to)
	if target:
		move.captured_piece = target
		board.capture_piece(to)
	
	# Move piece
	board.move_piece(from, to)
	
	# Record move
	board.record_move(move)
	
	# Check for check/checkmate
	var opponent_side = ChessRules.get_opposite_side(piece.side)
	if is_in_check(opponent_side):
		move.is_check = true
		if is_checkmate(opponent_side):
			move.is_checkmate = true
	
	# Switch player
	board.current_player = opponent_side
	
	return true

func get_game_status() -> String:
	var current_side = board_manager.get_board_state().current_player
	
	if is_checkmate(current_side):
		var winner = ChessRules.get_opposite_side(current_side)
		return "checkmate" if winner == ChessPiece.RED else "checkmate_black"
	
	if is_stalemate(current_side):
		return "stalemate"
	
	if is_in_check(current_side):
		return "check"
	
	return "ongoing"

func reset_game() -> void:
	board_manager.reset_board()
	move_generator = MoveGenerator.new(board_manager.get_board_state())
	move_validator = MoveValidator.new(board_manager.get_board_state())
