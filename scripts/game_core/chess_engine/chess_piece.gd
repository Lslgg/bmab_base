## ChessPiece: Represents a piece on the board
## Supports all 14 Chinese chess piece types
class_name ChessPiece
extends RefCounted

# Import Position class
const Position = preload("res://scripts/game_core/chess_engine/position.gd")

# Piece types
const KING = "king"           # 帅/将
const ROOK = "rook"           # 车
const KNIGHT = "knight"       # 马
const CANNON = "cannon"       # 炮
const ELEPHANT = "elephant"   # 相/象
const ADVISOR = "advisor"     # 士
const PAWN = "pawn"           # 卒/兵

# Sides
const RED = 0
const BLACK = 1

var type: String              # Piece type (king, rook, knight, etc.)
var side: int                 # 0 for red, 1 for black
var position: Position        # Current position on board
var captured: bool = false    # Whether piece has been captured

func _init(p_type: String = "", p_side: int = RED, p_position: Position = null) -> void:
	type = p_type
	side = p_side
	position = p_position if p_position else Position.new()
	captured = false

func _to_string() -> String:
	var side_str = "Red" if side == RED else "Black"
	return "%s %s at %s" % [side_str, type, position]

func is_valid_type() -> bool:
	return type in [KING, ROOK, KNIGHT, CANNON, ELEPHANT, ADVISOR, PAWN]

func duplicate() -> ChessPiece:
	var new_piece = ChessPiece.new(type, side, position.duplicate() if position else Position.new())
	new_piece.captured = captured
	return new_piece
