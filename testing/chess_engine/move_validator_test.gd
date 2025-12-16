## Tests for move validation
extends Node

const Position = preload("res://scripts/game_core/chess_engine/position.gd")
const ChessPiece = preload("res://scripts/game_core/chess_engine/chess_piece.gd")
const BoardState = preload("res://scripts/game_core/chess_engine/board_state.gd")
const BoardManager = preload("res://scripts/game_core/chess_engine/board_manager.gd")
const MoveValidator = preload("res://scripts/game_core/chess_engine/move_validator.gd")
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
	test_king_movement()
	test_rook_movement()
	test_knight_movement()
	test_cannon_movement()
	test_elephant_movement()
	test_advisor_movement()
	test_pawn_movement()

# Test King movement (1 step in palace)
func test_king_movement() -> void:
	var manager = BoardManager.new()
	var validator = MoveValidator.new(manager.get_board_state())
	
	# Red king at (4, 0)
	var king_pos = Position.new(4, 0, 0)
	
	# Valid: 1 step within palace
	assert_true(
		validator.is_legal_move(king_pos, Position.new(4, 1, 0)),
		"King can move 1 step forward"
	)
	assert_true(
		validator.is_legal_move(king_pos, Position.new(3, 0, 0)),
		"King can move 1 step left"
	)
	
	# Invalid: 2 steps
	assert_false(
		validator.is_legal_move(king_pos, Position.new(4, 2, 0)),
		"King cannot move 2 steps"
	)
	
	# Invalid: outside palace
	assert_false(
		validator.is_legal_move(king_pos, Position.new(2, 0, 0)),
		"King cannot move outside palace"
	)

# Test Rook movement (straight lines, no jump)
func test_rook_movement() -> void:
	var board = BoardState.new()
	var rook = ChessPiece.new(ChessRules.ROOK, ChessPiece.RED, Position.new(0, 0, 0))
	board.place_piece(rook)
	
	var validator = MoveValidator.new(board)
	
	# Valid: horizontal movement
	assert_true(
		validator.is_legal_move(Position.new(0, 0, 0), Position.new(5, 0, 0)),
		"Rook can move horizontally"
	)
	
	# Valid: vertical movement
	assert_true(
		validator.is_legal_move(Position.new(0, 0, 0), Position.new(0, 5, 0)),
		"Rook can move vertically"
	)
	
	# Invalid: diagonal movement
	assert_false(
		validator.is_legal_move(Position.new(0, 0, 0), Position.new(3, 3, 0)),
		"Rook cannot move diagonally"
	)

# Test Knight movement (L-shaped, cannot jump)
func test_knight_movement() -> void:
	var board = BoardState.new()
	var knight = ChessPiece.new(ChessRules.KNIGHT, ChessPiece.RED, Position.new(1, 0, 0))
	board.place_piece(knight)
	
	var validator = MoveValidator.new(board)
	
	# Valid: L-shaped move
	assert_true(
		validator.is_legal_move(Position.new(1, 0, 0), Position.new(2, 2, 0)),
		"Knight can move L-shaped (1+2)"
	)
	
	# Invalid: straight move
	assert_false(
		validator.is_legal_move(Position.new(1, 0, 0), Position.new(1, 2, 0)),
		"Knight cannot move straight"
	)

# Test Cannon movement (like rook, but jumps to capture)
func test_cannon_movement() -> void:
	var board = BoardState.new()
	var cannon = ChessPiece.new(ChessRules.CANNON, ChessPiece.RED, Position.new(0, 0, 0))
	board.place_piece(cannon)
	
	var validator = MoveValidator.new(board)
	
	# Valid: horizontal movement without capture
	assert_true(
		validator.is_legal_move(Position.new(0, 0, 0), Position.new(5, 0, 0)),
		"Cannon can move like rook"
	)
	
	# Add a piece to jump over
	var target = ChessPiece.new(ChessRules.PAWN, ChessPiece.BLACK, Position.new(3, 0, 0))
	board.place_piece(target)
	
	# Valid: capture by jumping
	var enemy = ChessPiece.new(ChessRules.PAWN, ChessPiece.BLACK, Position.new(5, 0, 0))
	board.place_piece(enemy)
	assert_true(
		validator.is_legal_move(Position.new(0, 0, 0), Position.new(5, 0, 0)),
		"Cannon can capture by jumping"
	)

# Test Elephant movement (diagonal, within own half)
func test_elephant_movement() -> void:
	var board = BoardState.new()
	var elephant = ChessPiece.new(ChessRules.ELEPHANT, ChessPiece.RED, Position.new(2, 0, 0))
	board.place_piece(elephant)
	
	var validator = MoveValidator.new(board)
	
	# Valid: diagonal 2 squares within own half
	assert_true(
		validator.is_legal_move(Position.new(2, 0, 0), Position.new(4, 2, 0)),
		"Elephant can move diagonally 2 squares"
	)
	
	# Invalid: crossing river
	assert_false(
		validator.is_legal_move(Position.new(2, 3, 0), Position.new(4, 5, 0)),
		"Elephant cannot cross river"
	)

# Test Advisor movement (diagonal in palace)
func test_advisor_movement() -> void:
	var board = BoardState.new()
	var advisor = ChessPiece.new(ChessRules.ADVISOR, ChessPiece.RED, Position.new(3, 0, 0))
	board.place_piece(advisor)
	
	var validator = MoveValidator.new(board)
	
	# Valid: diagonal 1 square in palace
	assert_true(
		validator.is_legal_move(Position.new(3, 0, 0), Position.new(4, 1, 0)),
		"Advisor can move diagonally 1 square"
	)
	
	# Invalid: outside palace
	assert_false(
		validator.is_legal_move(Position.new(3, 0, 0), Position.new(5, 2, 0)),
		"Advisor cannot move outside palace"
	)

# Test Pawn movement (forward before river, any direction after)
func test_pawn_movement() -> void:
	var board = BoardState.new()
	var pawn = ChessPiece.new(ChessRules.PAWN, ChessPiece.RED, Position.new(0, 3, 0))
	board.place_piece(pawn)
	
	var validator = MoveValidator.new(board)
	
	# Valid: forward move before river
	assert_true(
		validator.is_legal_move(Position.new(0, 3, 0), Position.new(0, 4, 0)),
		"Pawn can move forward"
	)
	
	# Invalid: sideways before river
	assert_false(
		validator.is_legal_move(Position.new(0, 3, 0), Position.new(1, 3, 0)),
		"Pawn cannot move sideways before river"
	)

# Helper functions
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

func print_results() -> void:
	print("\n" + "=".repeat(50))
	print("MOVE VALIDATOR TEST RESULTS")
	print("=".repeat(50))
	
	for test in test_results["tests"]:
		print(test)
	
	print("\n" + "-".repeat(50))
	print("Total: %d passed, %d failed" % [test_results["passed"], test_results["failed"]])
	print("=".repeat(50) + "\n")
