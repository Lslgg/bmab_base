## ChessRules: Rule definitions and constants for Chinese chess
class_name ChessRules
extends RefCounted

# Board dimensions
const BOARD_WIDTH = 9
const BOARD_HEIGHT = 10
const BOARD_LAYERS = 3

# Palace boundaries (3x3 area)
const PALACE_RED_ROWS = [0, 1, 2]      # Red palace rows
const PALACE_BLACK_ROWS = [7, 8, 9]    # Black palace rows
const PALACE_COLS = [3, 4, 5]          # Palace columns (same for both sides)

# River position
const RIVER_ROW = 4.5  # Between rows 4 and 5

# Piece types
const KING = "king"
const ROOK = "rook"
const KNIGHT = "knight"
const CANNON = "cannon"
const ELEPHANT = "elephant"
const ADVISOR = "advisor"
const PAWN = "pawn"

# Sides
const RED = 0
const BLACK = 1

# All valid piece types
const PIECE_TYPES = [KING, ROOK, KNIGHT, CANNON, ELEPHANT, ADVISOR, PAWN]

# Standard starting positions for both sides
const STARTING_POSITIONS = {
	RED: {
		KING: [[4, 0]],
		ROOK: [[0, 0], [8, 0]],
		KNIGHT: [[1, 0], [7, 0]],
		CANNON: [[1, 2], [7, 2]],
		ELEPHANT: [[2, 0], [6, 0]],
		ADVISOR: [[3, 0], [5, 0]],
		PAWN: [[0, 3], [2, 3], [4, 3], [6, 3], [8, 3]]
	},
	BLACK: {
		KING: [[4, 9]],
		ROOK: [[0, 9], [8, 9]],
		KNIGHT: [[1, 9], [7, 9]],
		CANNON: [[1, 7], [7, 7]],
		ELEPHANT: [[2, 9], [6, 9]],
		ADVISOR: [[3, 9], [5, 9]],
		PAWN: [[0, 6], [2, 6], [4, 6], [6, 6], [8, 6]]
	}
}

static func is_in_palace(pos: Vector2i, side: int) -> bool:
	if pos.x < 3 or pos.x > 5:
		return false
	
	if side == RED:
		return pos.y >= 0 and pos.y <= 2
	return pos.y >= 7 and pos.y <= 9

static func is_in_own_half(pos: Vector2i, side: int) -> bool:
	if side == RED:
		return pos.y <= 4
	return pos.y >= 5

static func has_crossed_river(pos: Vector2i, side: int) -> bool:
	if side == RED:
		return pos.y > 4
	return pos.y < 5

static func get_palace_rows(side: int) -> Array:
	return PALACE_RED_ROWS if side == RED else PALACE_BLACK_ROWS

static func get_opposite_side(side: int) -> int:
	return BLACK if side == RED else RED
