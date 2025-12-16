## MoveValidator: Validates move legality
class_name MoveValidator
extends RefCounted

const Position = preload("res://scripts/game_core/chess_engine/position.gd")
const ChessPiece = preload("res://scripts/game_core/chess_engine/chess_piece.gd")
const BoardState = preload("res://scripts/game_core/chess_engine/board_state.gd")
const ChessRules = preload("res://scripts/game_core/chess_engine/chess_rules.gd")

var board_state: BoardState

func _init(p_board_state: BoardState) -> void:
	board_state = p_board_state

func is_legal_move(from: Position, to: Position) -> bool:
	# Basic validation
	if not from.is_valid() or not to.is_valid():
		return false
	
	if from.equals(to):
		return false
	
	var piece = board_state.get_piece_at(from)
	if not piece:
		return false
	
	var target = board_state.get_piece_at(to)
	if target and target.side == piece.side:
		return false
	
	# Piece-specific validation
	match piece.type:
		ChessRules.KING:
			return _is_valid_king_move(piece, from, to)
		ChessRules.ROOK:
			return _is_valid_rook_move(piece, from, to)
		ChessRules.KNIGHT:
			return _is_valid_knight_move(piece, from, to)
		ChessRules.CANNON:
			return _is_valid_cannon_move(piece, from, to)
		ChessRules.ELEPHANT:
			return _is_valid_elephant_move(piece, from, to)
		ChessRules.ADVISOR:
			return _is_valid_advisor_move(piece, from, to)
		ChessRules.PAWN:
			return _is_valid_pawn_move(piece, from, to)
	
	return false

# King: 1 step in palace
func _is_valid_king_move(piece: ChessPiece, from: Position, to: Position) -> bool:
	# Must stay in palace
	if not ChessRules.is_in_palace(Vector2i(to.x, to.y), piece.side):
		return false
	
	# Must move exactly 1 square
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	
	return (dx + dy) == 1

# Rook: Straight lines, unlimited distance, cannot jump
func _is_valid_rook_move(_piece: ChessPiece, from: Position, to: Position) -> bool:
	# Must move horizontally or vertically
	if from.x != to.x and from.y != to.y:
		return false
	
	# Check for blocking pieces
	return not _has_blocking_pieces(from, to)

# Knight: L-shaped moves (2+1), cannot jump over pieces
func _is_valid_knight_move(_piece: ChessPiece, from: Position, to: Position) -> bool:
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	
	# Must be L-shaped (2+1 or 1+2)
	if not ((dx == 2 and dy == 1) or (dx == 1 and dy == 2)):
		return false
	
	# Check if path is blocked
	var block_x = from.x
	var block_y = from.y
	
	if dx == 2:
		block_x = from.x + (1 if to.x > from.x else -1)
	else:
		block_y = from.y + (1 if to.y > from.y else -1)
	
	var block_pos = Position.new(block_x, block_y, from.z)
	return board_state.get_piece_at(block_pos) == null

# Cannon: Straight lines like rook, but captures by jumping
func _is_valid_cannon_move(_piece: ChessPiece, from: Position, to: Position) -> bool:
	# Must move horizontally or vertically
	if from.x != to.x and from.y != to.y:
		return false
	
	var target = board_state.get_piece_at(to)
	
	if target == null:
		# Non-capture: cannot jump
		return not _has_blocking_pieces(from, to)
	# Capture: must jump over exactly one piece
	return _count_blocking_pieces(from, to) == 1

# Elephant: Diagonal moves within own half, cannot jump
func _is_valid_elephant_move(piece: ChessPiece, from: Position, to: Position) -> bool:
	# Must move diagonally 2 squares
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	
	if dx != 2 or dy != 2:
		return false
	
	# Cannot cross river
	if not ChessRules.is_in_own_half(Vector2i(to.x, to.y), piece.side):
		return false
	
	# Check diagonal block
	var block_x = from.x + (1 if to.x > from.x else -1)
	var block_y = from.y + (1 if to.y > from.y else -1)
	var block_pos = Position.new(block_x, block_y, from.z)
	
	return board_state.get_piece_at(block_pos) == null

# Advisor: Diagonal moves in palace
func _is_valid_advisor_move(piece: ChessPiece, from: Position, to: Position) -> bool:
	# Must stay in palace
	if not ChessRules.is_in_palace(Vector2i(to.x, to.y), piece.side):
		return false
	
	# Must move diagonally 1 square
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	
	return dx == 1 and dy == 1

# Pawn: Forward moves, sideways after river
func _is_valid_pawn_move(piece: ChessPiece, from: Position, to: Position) -> bool:
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	
	# Must move exactly 1 square
	if (dx + dy) != 1:
		return false
	
	# Determine forward direction
	var forward_dir = 1 if piece.side == ChessPiece.RED else -1
	var dy_signed = to.y - from.y
	
	# Cannot move backward
	if dy_signed * forward_dir < 0:
		return false
	
	# Before crossing river: can only move forward
	if ChessRules.is_in_own_half(Vector2i(from.x, from.y), piece.side):
		return dy_signed != 0  # Must be forward
	
	# After crossing river: can move in any direction
	return true

# Helper functions
func _has_blocking_pieces(from: Position, to: Position) -> bool:
	return _count_blocking_pieces(from, to) > 0

func _count_blocking_pieces(from: Position, to: Position) -> int:
	var count = 0
	
	var dx = 0 if from.x == to.x else (1 if to.x > from.x else -1)
	var dy = 0 if from.y == to.y else (1 if to.y > from.y else -1)
	
	var x = from.x + dx
	var y = from.y + dy
	
	while x != to.x or y != to.y:
		var pos = Position.new(x, y, from.z)
		if board_state.get_piece_at(pos) != null:
			count += 1
		x += dx
		y += dy
	
	return count
