class_name GameManagerSingleton
extends Node

## Core Game Manager for Rhythm Chess
## Manages game state, lifecycle, and coordination between systems
## Central authority for game flow and state transitions

enum GameState {
	MENU,
	CALIBRATION,
	GAME_SETUP,
	PLAYING,
	PAUSED,
	GAME_OVER,
	SETTINGS
}

var current_state: GameState = GameState.MENU
var game_session_data: Dictionary = {}
var performance_metrics: Dictionary = {}

# Game session tracking
var session_start_time: float
var current_fps: float = 60.0
var memory_usage_mb: float = 0.0

func _ready():
	print("GameManager initialized - Core game state management ready")
	
	# Connect to EventBus signals
	EventBus.game_state_changed.connect(_on_game_state_changed)
	EventBus.error_occurred.connect(_on_error_occurred)
	
	# Initialize performance monitoring
	session_start_time = Time.get_unix_time_from_system()
	
	# Start performance monitoring timer
	var performance_timer = Timer.new()
	performance_timer.wait_time = 1.0  # Check every second
	performance_timer.timeout.connect(_update_performance_metrics)
	performance_timer.autostart = true
	add_child(performance_timer)

func _process(_delta):
	# Update FPS tracking
	current_fps = Engine.get_frames_per_second()

## Change game state with validation and event emission
func change_state(new_state: GameState):
	if new_state == current_state:
		return  # No change needed
	
	var old_state = current_state
	
	# Validate state transition
	if not _is_valid_state_transition(old_state, new_state):
		EventBus.emit_error("GameManager", "error", 
			"Invalid state transition from " + GameState.keys()[old_state] + " to " + GameState.keys()[new_state])
		return
	
	# Perform state exit cleanup
	_exit_state(old_state)
	
	# Update state
	current_state = new_state
	
	# Perform state entry setup
	_enter_state(new_state)
	
	# Emit state change event
	EventBus.game_state_changed.emit(GameState.keys()[new_state])
	
	print("Game state changed: " + GameState.keys()[old_state] + " -> " + GameState.keys()[new_state])

## Validate if state transition is allowed
func _is_valid_state_transition(from_state: GameState, to_state: GameState) -> bool:
	# Define valid transitions
	var valid_transitions = {
		GameState.MENU: [GameState.CALIBRATION, GameState.GAME_SETUP, GameState.SETTINGS],
		GameState.CALIBRATION: [GameState.MENU, GameState.GAME_SETUP],
		GameState.GAME_SETUP: [GameState.PLAYING, GameState.MENU],
		GameState.PLAYING: [GameState.PAUSED, GameState.GAME_OVER, GameState.MENU],
		GameState.PAUSED: [GameState.PLAYING, GameState.MENU, GameState.SETTINGS],
		GameState.GAME_OVER: [GameState.MENU, GameState.GAME_SETUP],
		GameState.SETTINGS: [GameState.MENU, GameState.PAUSED]
	}
	
	return to_state in valid_transitions.get(from_state, [])

## Handle state exit cleanup
func _exit_state(state: GameState):
	match state:
		GameState.PLAYING:
			# Pause any active game systems
			pass
		GameState.CALIBRATION:
			# Clean up calibration resources
			pass

## Handle state entry setup
func _enter_state(state: GameState):
	match state:
		GameState.MENU:
			# Reset game session data
			game_session_data.clear()
		GameState.CALIBRATION:
			# Initialize calibration systems
			EventBus.calibration_started.emit()
		GameState.PLAYING:
			# Start game session tracking
			game_session_data["start_time"] = Time.get_unix_time_from_system()
		GameState.GAME_OVER:
			# Record game session end
			game_session_data["end_time"] = Time.get_unix_time_from_system()

## Update performance metrics
func _update_performance_metrics():
	# Update memory usage (using available Godot 4.x API)
	memory_usage_mb = OS.get_static_memory_usage() / 1024.0 / 1024.0
	
	# Store metrics
	performance_metrics = {
		"fps": current_fps,
		"memory_mb": memory_usage_mb,
		"session_duration": Time.get_unix_time_from_system() - session_start_time
	}
	
	# Check for performance warnings
	if current_fps < 45.0:  # Below acceptable threshold
		EventBus.system_performance_warning.emit(current_fps, memory_usage_mb)
	
	if memory_usage_mb > 1800.0:  # Approaching 2GB limit
		EventBus.emit_warning("GameManager", "High memory usage: " + str(memory_usage_mb) + "MB")

## Get current game state as string
func get_current_state_string() -> String:
	return GameState.keys()[current_state]

## Get performance metrics
func get_performance_metrics() -> Dictionary:
	return performance_metrics.duplicate()

## Handle game state change events
func _on_game_state_changed(new_state: String):
	print("Game state confirmed: " + new_state)

## Handle error events
func _on_error_occurred(error_event: ErrorEvent):
	if error_event.type == ErrorEvent.ErrorType.FATAL:
		# Handle fatal errors by transitioning to safe state
		if current_state == GameState.PLAYING:
			change_state(GameState.MENU)

## Emergency shutdown procedure
func emergency_shutdown():
	EventBus.emit_error("GameManager", "fatal", "Emergency shutdown initiated")
	# Save any critical data
	# Clean up resources
	get_tree().quit()
