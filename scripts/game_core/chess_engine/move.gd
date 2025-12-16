## Move: Represents a chess move
class_name Move
extends RefCounted

const Position = preload("res://scripts/game_core/chess_engine/position.gd")
const ChessPiece = preload("res://scripts/game_core/chess_engine/chess_piece.gd")

var from: Position            # Source position
var to: Position              # Destination position
var piece: ChessPiece         # Piece being moved
var captured_piece: ChessPiece = null  # Captured piece (if any)
var is_check: bool = false    # Whether move results in check
var is_checkmate: bool = false  # Whether move results in checkmate

func _init(p_from: Position = null, p_to: Position = null, p_piece: ChessPiece = null) -> void:
	from = p_from if p_from else Position.new()
	to = p_to if p_to else Position.new()
	piece = p_piece

func _to_string() -> String:
	var capture_str = " captures %s" % captured_piece.type if captured_piece else ""
	return "%s → %s%s" % [from, to, capture_str]

func is_capture() -> bool:
	return captured_piece != null

func duplicate() -> Move:
	var new_move = Move.new(from.duplicate(), to.duplicate(), piece.duplicate() if piece else null)
	new_move.captured_piece = captured_piece.duplicate() if captured_piece else null
	new_move.is_check = is_check
	new_move.is_checkmate = is_checkmate
	return new_move
