## Tests for board initialization and data structures
extends Node

const Position = preload("res://scripts/game_core/chess_engine/position.gd")
const ChessPiece = preload("res://scripts/game_core/chess_engine/chess_piece.gd")
const BoardManager = preload("res://scripts/game_core/chess_engine/board_manager.gd")
const ChessRules = preload("res://scripts/game_core/chess_engine/chess_rules.gd")

var test_results = {
	"passed": 0,
	"failed": 0,
	"tests": []
}

func _ready() -> void:
	run_all_tests()
	print_results()

func run_all_tests() -> void:
	test_position_creation()
	test_position_validity()
	test_chess_piece_creation()
	test_board_state_initialization()
	test_board_manager_initialization()
	test_piece_placement()
	test_piece_retrieval()

# Test Position class
func test_position_creation() -> void:
	var pos = Position.new(4, 5, 0)
	assert_equal(pos.x, 4, "Position x coordinate")
	assert_equal(pos.y, 5, "Position y coordinate")
	assert_equal(pos.z, 0, "Position z coordinate")

func test_position_validity() -> void:
	var valid_pos = Position.new(4, 5, 0)
	assert_true(valid_pos.is_valid(), "Valid position")
	
	var invalid_x = Position.new(-1, 5, 0)
	assert_false(invalid_x.is_valid(), "Invalid x coordinate")
	
	var invalid_y = Position.new(4, 10, 0)
	assert_false(invalid_y.is_valid(), "Invalid y coordinate")
	
	var invalid_z = Position.new(4, 5, 3)
	assert_false(invalid_z.is_valid(), "Invalid z coordinate")

# Test ChessPiece class
func test_chess_piece_creation() -> void:
	var pos = Position.new(4, 0, 0)
	var piece = ChessPiece.new(ChessRules.KING, ChessPiece.RED, pos)
	
	assert_equal(piece.type, ChessRules.KING, "Piece type")
	assert_equal(piece.side, ChessPiece.RED, "Piece side")
	assert_equal(piece.position.x, 4, "Piece position x")
	assert_false(piece.captured, "Piece not captured initially")

# Test BoardState initialization
func test_board_state_initialization() -> void:
	var board = BoardState.new()
	
	assert_equal(board.pieces.size(), 0, "Empty board has no pieces")
	assert_equal(board.move_history.size(), 0, "Empty board has no moves")
	assert_equal(board.captured_pieces.size(), 0, "Empty board has no captured pieces")
	assert_equal(board.current_player, ChessPiece.RED, "Red starts first")

# Test BoardManager initialization
func test_board_manager_initialization() -> void:
	var manager = BoardManager.new()
	var board = manager.get_board_state()
	
	# Should have 32 pieces total (16 per side)
	assert_equal(board.pieces.size(), 32, "Standard position has 32 pieces")
	
	# Check red pieces
	var red_pieces = manager.get_all_pieces_for_side(ChessPiece.RED)
	assert_equal(red_pieces.size(), 16, "Red has 16 pieces")
	
	# Check black pieces
	var black_pieces = manager.get_all_pieces_for_side(ChessPiece.BLACK)
	assert_equal(black_pieces.size(), 16, "Black has 16 pieces")

# Test piece placement
func test_piece_placement() -> void:
	var board = BoardState.new()
	var pos = Position.new(4, 5, 0)
	var piece = ChessPiece.new(ChessRules.KING, ChessPiece.RED, pos)
	
	var result = board.place_piece(piece)
	assert_true(result, "Piece placement succeeds")
	assert_equal(board.pieces.size(), 1, "Piece added to board")
	
	# Try placing on occupied square
	var piece2 = ChessPiece.new(ChessRules.ROOK, ChessPiece.RED, pos)
	var result2 = board.place_piece(piece2)
	assert_false(result2, "Cannot place on occupied square")

# Test piece retrieval
func test_piece_retrieval() -> void:
	var manager = BoardManager.new()
	
	# Red king should be at (4, 0, 0)
	var king_pos = Position.new(4, 0, 0)
	var king = manager.get_piece_at(king_pos)
	assert_not_null(king, "King found at starting position")
	assert_equal(king.type, ChessRules.KING, "Retrieved piece is king")
	assert_equal(king.side, ChessPiece.RED, "Retrieved piece is red")
	
	# Black king should be at (4, 9, 0)
	var black_king_pos = Position.new(4, 9, 0)
	var black_king = manager.get_piece_at(black_king_pos)
	assert_not_null(black_king, "Black king found")
	assert_equal(black_king.side, ChessPiece.BLACK, "Black king is black")

# Helper functions
func assert_equal(actual, expected, test_name: String) -> void:
	if actual == expected:
		test_results["passed"] += 1
		test_results["tests"].append("✓ " + test_name)
	else:
		test_results["failed"] += 1
		var msg = "✗ %s (expected: %s, got: %s)" % [test_name, expected, actual]
		test_results["tests"].append(msg)

func assert_true(value: bool, test_name: String) -> void:
	if value:
		test_results["passed"] += 1
		test_results["tests"].append("✓ " + test_name)
	else:
		test_results["failed"] += 1
		test_results["tests"].append("✗ " + test_name)

func assert_false(value: bool, test_name: String) -> void:
	if not value:
		test_results["passed"] += 1
		test_results["tests"].append("✓ " + test_name)
	else:
		test_results["failed"] += 1
		test_results["tests"].append("✗ " + test_name)

func assert_not_null(value, test_name: String) -> void:
	if value != null:
		test_results["passed"] += 1
		test_results["tests"].append("✓ " + test_name)
	else:
		test_results["failed"] += 1
		test_results["tests"].append("✗ " + test_name)

func print_results() -> void:
	print("\n" + "=".repeat(50))
	print("BOARD INITIALIZATION TEST RESULTS")
	print("=".repeat(50))
	
	for test in test_results["tests"]:
		print(test)
	
	print("\n" + "-".repeat(50))
	print("Total: %d passed, %d failed" % [test_results["passed"], test_results["failed"]])
	print("=".repeat(50) + "\n")
