## Tests for game state and check/checkmate detection
extends Node

const ChessGameState = preload("res://scripts/game_core/chess_engine/game_state.gd")
const Position = preload("res://scripts/game_core/chess_engine/position.gd")
const ChessPiece = preload("res://scripts/game_core/chess_engine/chess_piece.gd")
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
	test_game_initialization()
	test_move_execution()
	test_check_detection()
	test_game_status()

# Test game initialization
func test_game_initialization() -> void:
	var game = ChessGameState.new()
	var board = game.get_board_state()
	
	assert_equal(board.pieces.size(), 32, "Game starts with 32 pieces")
	assert_equal(board.current_player, ChessPiece.RED, "Red starts first")
	assert_equal(board.move_history.size(), 0, "Game starts with no moves")

# Test move execution
func test_move_execution() -> void:
	var game = ChessGameState.new()
	
	# Red king at (4, 0), move to (4, 1)
	var from = Position.new(4, 0, 0)
	var to = Position.new(4, 1, 0)
	
	var result = game.execute_move(from, to)
	assert_true(result, "Move execution succeeds")
	
	var board = game.get_board_state()
	assert_equal(board.move_history.size(), 1, "Move recorded in history")
	assert_equal(board.current_player, ChessPiece.BLACK, "Turn switches to black")
	
	# Verify piece moved
	var piece = board.get_piece_at(to)
	assert_not_null(piece, "Piece found at destination")
	assert_equal(piece.type, ChessRules.KING, "Correct piece moved")

# Test check detection
func test_check_detection() -> void:
	var game = ChessGameState.new()
	
	# This is a simplified test - in a real scenario we'd set up
	# a specific position to test check detection
	var is_check = game.is_in_check(ChessPiece.RED)
	assert_false(is_check, "Red not in check at start")

# Test game status
func test_game_status() -> void:
	var game = ChessGameState.new()
	
	var status = game.get_game_status()
	assert_equal(status, "ongoing", "Game is ongoing at start")

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
	print("GAME STATE TEST RESULTS")
	print("=".repeat(50))
	
	for test in test_results["tests"]:
		print(test)
	
	print("\n" + "-".repeat(50))
	print("Total: %d passed, %d failed" % [test_results["passed"], test_results["failed"]])
	print("=".repeat(50) + "\n")
