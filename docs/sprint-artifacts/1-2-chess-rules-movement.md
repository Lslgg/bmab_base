# Story 1.2: chess-rules-movement

Status: ready-for-dev

## Story

As a **game developer**,
I want **to implement the complete Chinese chess rules engine with all piece movement mechanics, validation, and game state management**,
so that **the rhythm chess game has a solid, rule-compliant foundation for all chess logic and can properly validate all player moves**.

## Acceptance Criteria

1. **Complete Piece Movement**: Implement movement rules for all 14 piece types (帅/将, 车, 马, 炮, 相, 象, 士, 卒/兵)
2. **Move Validation**: Validate all moves for legality, including boundary checks and piece-specific constraints
3. **Capture Mechanics**: Implement piece capture (吃子) with proper removal and state updates
4. **Game State Management**: Track board state, piece positions, and game history
5. **Check/Checkmate Detection**: Detect check (将军), checkmate (将死), and draw conditions
6. **Board Representation**: Create efficient board data structure for 9x10 standard Chinese chess board
7. **Move Generation**: Generate all legal moves for any board position for AI and validation
8. **Testing Infrastructure**: Comprehensive unit tests for all movement rules and edge cases

## Tasks / Subtasks

- [ ] **Board Data Structure and Initialization** (AC: 6)
  - [ ] Create BoardState class representing 9x10 board with 3D layer support
  - [ ] Implement piece placement and initialization for standard chess setup
  - [ ] Create Position class for board coordinates (x, y, z for 3D layers)
  - [ ] Implement board state copying and history tracking

- [ ] **Piece Movement Rules Implementation** (AC: 1, 2)
  - [ ] **帅/将 (King)**: Single step in palace (3x3 area), cannot leave palace
  - [ ] **车 (Rook)**: Straight lines horizontally/vertically, any distance, cannot jump
  - [ ] **马 (Knight)**: L-shaped moves (2+1), cannot jump over pieces
  - [ ] **炮 (Cannon)**: Straight lines like rook, but captures by jumping over exactly one piece
  - [ ] **相/象 (Elephant)**: Diagonal moves within own half, cannot jump, cannot cross river
  - [ ] **士 (Advisor)**: Diagonal moves within palace (3x3 area)
  - [ ] **卒/兵 (Pawn)**: Forward moves, can move sideways after crossing river, cannot move backward

- [ ] **Move Validation System** (AC: 2)
  - [ ] Create MoveValidator class with comprehensive validation logic
  - [ ] Implement boundary checking for all piece types
  - [ ] Implement piece-specific movement constraints
  - [ ] Validate move legality based on current board state
  - [ ] Prevent moves that leave own king in check

- [ ] **Capture and State Update Mechanics** (AC: 3)
  - [ ] Implement capture logic with proper piece removal
  - [ ] Update board state after each move
  - [ ] Track captured pieces for potential future features
  - [ ] Implement move history recording for undo/replay functionality

- [ ] **Check and Checkmate Detection** (AC: 5)
  - [ ] Implement check detection (king under attack)
  - [ ] Implement checkmate detection (no legal moves while in check)
  - [ ] Implement stalemate detection (no legal moves, not in check)
  - [ ] Implement draw conditions (repetition, insufficient material)

- [ ] **Move Generation** (AC: 7)
  - [ ] Create move generator that produces all legal moves for a position
  - [ ] Optimize move generation for AI performance
  - [ ] Support filtering moves by piece type or target square
  - [ ] Generate capture-only moves for tactical analysis

- [ ] **Comprehensive Testing** (AC: 8)
  - [ ] Create unit tests for each piece type's movement
  - [ ] Test boundary conditions and edge cases
  - [ ] Test capture mechanics and state updates
  - [ ] Test check/checkmate detection with known positions
  - [ ] Test move validation with invalid moves
  - [ ] Create test suite for known chess positions and solutions

## Dev Notes

### Critical Architecture Requirements

**🔥 MANDATORY TECHNICAL STACK:**
- **Language**: GDScript (primary implementation)
- **Data Structures**: Custom classes for Position, Move, BoardState, ChessPiece
- **Architecture Pattern**: Functional-first with clear separation of concerns
- **Performance**: Move generation must complete in <10ms for AI responsiveness

**🏗️ BOARD REPRESENTATION (EXACT IMPLEMENTATION REQUIRED):**

```
Standard Chinese Chess Board:
- Dimensions: 9 columns (a-i) × 10 rows (0-9)
- Palace (宫): 3×3 area in center of each side (columns 3-5, rows 0-2 for red, rows 7-9 for black)
- River (河): Horizontal line between rows 4 and 5
- Piece Count: 16 pieces per side (1 king, 2 rooks, 2 knights, 2 cannons, 2 elephants, 2 advisors, 5 pawns)

3D Layer Support (for Rhythm Chess):
- Layer 0: Ground layer (地面层)
- Layer 1: Standard layer (标准层) - default chess board
- Layer 2: Sky layer (天空层)
- Vertical movement between layers requires rhythm energy
```

**Piece Movement Rules Summary:**

```gdscript
# 帅/将 (King): 1 step in palace
- Move: ±1 in any direction within palace
- Palace: 3×3 area (columns 3-5, rows 0-2 for red or 7-9 for black)
- Constraint: Cannot leave palace, cannot face each other across river

# 车 (Rook): Straight lines, unlimited distance
- Move: Any distance horizontally or vertically
- Constraint: Cannot jump over pieces

# 马 (Knight): L-shaped moves
- Move: 2 squares in one direction + 1 square perpendicular
- Constraint: Cannot jump over pieces (blocks the path)

# 炮 (Cannon): Straight lines with special capture
- Move: Any distance horizontally or vertically (like rook)
- Capture: Must jump over exactly one piece to capture
- Constraint: Cannot capture without jumping

# 相/象 (Elephant): Diagonal moves within own half
- Move: 2 squares diagonally
- Constraint: Cannot cross river, cannot jump, cannot move backward

# 士 (Advisor): Diagonal moves in palace
- Move: 1 square diagonally within palace
- Constraint: Cannot leave palace

# 卒/兵 (Pawn): Forward moves, sideways after river
- Move: 1 square forward (before river), 1 square in any direction (after river)
- Constraint: Cannot move backward, cannot move sideways before river
```

### Latest Technical Information (2024)

**GDScript Best Practices for Chess Engine:**
- Use `class_name` for all custom classes for proper scoping
- Implement `_to_string()` for debugging board positions
- Use typed arrays for performance: `Array[ChessPiece]`
- Leverage GDScript's built-in `hash()` for position hashing (for move history)
- Use `RefCounted` for automatic memory management

**Performance Optimization Strategies:**
- Pre-calculate move masks for each piece type
- Use bitboards or array-based board representation (array is simpler for GDScript)
- Cache legal move lists to avoid recalculation
- Implement move ordering for AI (captures first, then checks, then quiet moves)

### Architecture Compliance Requirements

**🚨 MANDATORY PATTERNS:**
- **Naming Convention**: PascalCase classes, snake_case files/variables, SCREAMING_SNAKE_CASE constants
- **Communication**: All state changes through EventBus signals (move_executed, piece_captured, check_detected)
- **Data Models**: Custom RefCounted classes for Position, Move, BoardState, ChessPiece
- **Error Handling**: Unified error events through EventBus for invalid moves
- **File Organization**: chess_engine/ folder with clear module separation

**Core Classes Required:**

```gdscript
# Position: Represents a square on the board
class_name Position
extends RefCounted

var x: int  # Column (0-8)
var y: int  # Row (0-9)
var z: int  # Layer (0-2 for 3D)

func _to_string() -> String:
    return "(%d,%d,%d)" % [x, y, z]
```

```gdscript
# ChessPiece: Represents a piece on the board
class_name ChessPiece
extends RefCounted

var type: String      # "king", "rook", "knight", "cannon", "elephant", "advisor", "pawn"
var side: int         # 0 for red, 1 for black
var position: Position
var captured: bool = false
```

```gdscript
# Move: Represents a chess move
class_name Move
extends RefCounted

var from: Position
var to: Position
var piece: ChessPiece
var captured_piece: ChessPiece = null
var is_check: bool = false
var is_checkmate: bool = false
```

```gdscript
# BoardState: Represents complete board state
class_name BoardState
extends RefCounted

var pieces: Array[ChessPiece]
var board: Array  # 9x10x3 3D array for piece lookup
var current_player: int  # 0 for red, 1 for black
var move_history: Array[Move]
var captured_pieces: Array[ChessPiece]
```

### File Structure Requirements

**Core Chess Engine Files:**
1. `chess_rules.gd` - Rule definitions and constants
2. `board_manager.gd` - Board state management and initialization
3. `piece_controller.gd` - Individual piece behavior and properties
4. `move_validator.gd` - Move legality validation
5. `move_generator.gd` - Legal move generation for all positions
6. `game_state.gd` - Overall game state and win/loss conditions
7. `move.gd` - Move data model
8. `position.gd` - Position data model
9. `chess_piece.gd` - Piece data model
10. `board_state.gd` - Board state data model

**Test Files:**
- `chess_rules_test.gd` - Unit tests for all piece movements
- `move_validator_test.gd` - Validation logic tests
- `game_state_test.gd` - Check/checkmate detection tests
- `move_generator_test.gd` - Move generation tests

### Testing Requirements

**Mandatory Test Coverage:**
- **Piece Movement Tests**: Each piece type with valid and invalid moves
- **Boundary Tests**: Edge cases at board boundaries and palace boundaries
- **Capture Tests**: All capture scenarios including cannon special case
- **Check Detection Tests**: Known positions that result in check
- **Checkmate Tests**: Classic checkmate patterns in Chinese chess
- **Move Validation Tests**: Invalid moves properly rejected
- **State Consistency Tests**: Board state remains consistent after moves

**Test Data:**
- Starting position validation
- Known chess problems and their solutions
- Edge cases: pieces at board edges, palace boundaries, river crossing
- Stalemate and draw scenarios

### Project Context Reference

**Source Documents:**
- [PRD: docs/prd.md - Lines 109-120: Chess rules engine requirements]
- [GDD: docs/GDD.md - Lines 183-213: Game mechanics including chess rules]
- [Architecture: docs/architecture.md - Lines 953-959: Chess engine module structure]

**Key Requirements from PRD:**
- 100% accurate Chinese chess rule implementation
- All 14 piece types with correct movement rules
- Proper check/checkmate/draw detection
- Support for 3D multi-layer board system (future enhancement)

**Architecture Decisions:**
- Functional-first architecture with clear separation of concerns
- EventBus-based communication for move execution and state changes
- Efficient board representation for AI move generation
- Comprehensive testing infrastructure for rule verification

### Previous Story Intelligence

**Story 1.1 Completion Notes:**
- ✅ Godot project initialized with Forward+ renderer
- ✅ Core autoload singletons created (EventBus, GameManager, AudioManager, SettingsManager)
- ✅ Basic project structure established
- ✅ Testing infrastructure foundation created

**Relevant Code from Story 1.1:**
- EventBus singleton available for move_executed, piece_captured signals
- GameManager available for game state coordination
- Testing framework (test_runner.gd) ready for chess engine tests
- Data model classes (BeatEvent, AudioData, ErrorEvent) provide pattern reference

**Integration Points:**
- Use EventBus.emit_signal("move_executed", move) for move notifications
- Use GameManager for overall game state coordination
- Follow established naming conventions and data model patterns
- Integrate with existing testing framework

## Dev Agent Record

### Context Reference

**Primary Architecture Source**: `.bmad/bmm/workflows/4-implementation/create-story/workflow.yaml`
**Story Context Engine**: Ultimate BMad Method comprehensive analysis completed

### Agent Model Used

Claude Sonnet 4 (Augment Agent) - 2025-12-16

### Completion Notes List

**✅ COMPREHENSIVE CHESS RULES ANALYSIS COMPLETED:**
- Complete PRD analysis - Chess rules engine requirements and acceptance standards
- Full GDD analysis - Game mechanics and chess system specifications
- Architecture analysis - Chess engine module structure and integration points
- Previous story context - Story 1.1 completion and integration points

**🎯 DEVELOPER GUARDRAILS ESTABLISHED:**
- All 14 piece types with exact movement rules documented
- Board representation (9x10 standard + 3D layer support) specified
- Move validation requirements clearly defined
- Check/checkmate detection algorithms outlined
- Testing requirements with specific test cases identified

**🔬 EXHAUSTIVE ANALYSIS PERFORMED:**
- Integration with Story 1.1 components (EventBus, GameManager, testing framework)
- Performance requirements for AI move generation (<10ms)
- Architecture compliance with established patterns
- Complete file structure and class hierarchy defined

### File List

**Files to be created in this story:**
- ✅ `scripts/game_core/chess_engine/position.gd` - Position data model
- ✅ `scripts/game_core/chess_engine/chess_piece.gd` - Piece data model
- ✅ `scripts/game_core/chess_engine/move.gd` - Move data model
- ✅ `scripts/game_core/chess_engine/board_state.gd` - Board state data model
- ✅ `scripts/game_core/chess_engine/chess_rules.gd` - Rule definitions and constants
- ✅ `scripts/game_core/chess_engine/board_manager.gd` - Board initialization and state management
- ✅ `scripts/game_core/chess_engine/piece_controller.gd` - Piece behavior and properties
- ✅ `scripts/game_core/chess_engine/move_validator.gd` - Move legality validation
- ✅ `scripts/game_core/chess_engine/move_generator.gd` - Legal move generation
- ✅ `scripts/game_core/chess_engine/game_state.gd` - Game state and win conditions
- ✅ `testing/chess_engine/chess_rules_test.gd` - Piece movement tests
- ✅ `testing/chess_engine/move_validator_test.gd` - Validation tests
- ✅ `testing/chess_engine/game_state_test.gd` - Check/checkmate tests
- ✅ `testing/chess_engine/move_generator_test.gd` - Move generation tests

**Story Status**: Ready for implementation - All acceptance criteria clearly defined, comprehensive developer context established, integration points identified with Story 1.1 components.

