## BoardManager: Manages board initialization and state
class_name BoardManager
extends RefCounted

const Position = preload("res://scripts/game_core/chess_engine/position.gd")
const ChessPiece = preload("res://scripts/game_core/chess_engine/chess_piece.gd")
const BoardState = preload("res://scripts/game_core/chess_engine/board_state.gd")
const ChessRules = preload("res://scripts/game_core/chess_engine/chess_rules.gd")

var board_state: BoardState

func _init() -> void:
	board_state = BoardState.new()
	initialize_standard_position()

func initialize_standard_position() -> void:
	# Initialize red pieces
	_setup_side_pieces(ChessPiece.RED)
	# Initialize black pieces
	_setup_side_pieces(ChessPiece.BLACK)

func _setup_side_pieces(side: int) -> void:
	var positions = ChessRules.STARTING_POSITIONS[side]
	
	# King
	var king_pos = positions[ChessRules.KING][0]
	var king = ChessPiece.new(
		ChessRules.KING,
		side,
		Position.new(king_pos[0], king_pos[1], 0)
	)
	board_state.place_piece(king)
	
	# Rooks
	for pos in positions[ChessRules.ROOK]:
		var rook = ChessPiece.new(
			ChessRules.ROOK,
			side,
			Position.new(pos[0], pos[1], 0)
		)
		board_state.place_piece(rook)
	
	# Knights
	for pos in positions[ChessRules.KNIGHT]:
		var knight = ChessPiece.new(
			ChessRules.KNIGHT,
			side,
			Position.new(pos[0], pos[1], 0)
		)
		board_state.place_piece(knight)
	
	# Cannons
	for pos in positions[ChessRules.CANNON]:
		var cannon = ChessPiece.new(
			ChessRules.CANNON,
			side,
			Position.new(pos[0], pos[1], 0)
		)
		board_state.place_piece(cannon)
	
	# Elephants
	for pos in positions[ChessRules.ELEPHANT]:
		var elephant = ChessPiece.new(
			ChessRules.ELEPHANT,
			side,
			Position.new(pos[0], pos[1], 0)
		)
		board_state.place_piece(elephant)
	
	# Advisors
	for pos in positions[ChessRules.ADVISOR]:
		var advisor = ChessPiece.new(
			ChessRules.ADVISOR,
			side,
			Position.new(pos[0], pos[1], 0)
		)
		board_state.place_piece(advisor)
	
	# Pawns
	for pos in positions[ChessRules.PAWN]:
		var pawn = ChessPiece.new(
			ChessRules.PAWN,
			side,
			Position.new(pos[0], pos[1], 0)
		)
		board_state.place_piece(pawn)

func get_board_state() -> BoardState:
	return board_state

func reset_board() -> void:
	board_state = BoardState.new()
	initialize_standard_position()

func get_piece_at(position: Position) -> ChessPiece:
	return board_state.get_piece_at(position)

func get_all_pieces_for_side(side: int) -> Array[ChessPiece]:
	return board_state.get_all_pieces_for_side(side)

func get_king(side: int) -> ChessPiece:
	return board_state.get_king(side)
