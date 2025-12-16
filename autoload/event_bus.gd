class_name EventBusManager
extends Node

## Global Event Bus for Rhythm Chess
## Provides centralized communication between all game components
## Following architecture requirement: ALL inter-component communication via EventBus

# Audio and Timing Events
signal beat_detected(beat_event: BeatEvent)
signal audio_input_received(audio_data: AudioData)
signal timing_sync_lost()
signal timing_sync_restored()
signal latency_measured(latency_ms: float)

# Game State Events
signal game_state_changed(new_state: String)
signal board_state_updated(board_state: BoardState)
signal piece_moved(from_pos: Vector2i, to_pos: Vector2i, piece_type: String)
signal game_over(winner: String, reason: String)

# UI and User Experience Events
signal ui_element_focused(element_name: String)
signal settings_changed(setting_name: String, new_value: Variant)
signal calibration_started()
signal calibration_completed(calibration_data: Dictionary)

# Error and System Events
signal error_occurred(error_event: ErrorEvent)
signal warning_issued(message: String, component: String)
signal system_performance_warning(fps: float, memory_mb: float)

# Audio System Events
signal audio_backend_changed(backend_name: String)
signal audio_device_changed(device_name: String)
signal spectrum_analysis_updated(spectrum_data: PackedFloat32Array)

# Chess Engine Events
signal move_validated(move_data: Dictionary, is_valid: bool)
signal check_detected(player: String)
signal checkmate_detected(winner: String)

# Rhythm System Events
signal energy_accumulated(piece_id: String, energy_amount: float)
signal skill_activated(piece_id: String, skill_name: String)
signal combo_triggered(combo_type: String, multiplier: float)

# AI Events
signal ai_move_calculated(move_data: Dictionary, difficulty: String)
signal ai_thinking_started(estimated_time: float)
signal ai_thinking_completed()

func _ready():
	print("EventBus initialized - Global communication system ready")
	
	# Connect to error handling
	error_occurred.connect(_on_error_occurred)
	warning_issued.connect(_on_warning_issued)

## Emit error event with standardized error handling
func emit_error(component: String, error_type: String, message: String, technical_details: String = ""):
	var error_event: ErrorEvent

	# Convert string to proper ErrorEvent type
	match error_type.to_lower():
		"warning":
			error_event = ErrorEvent.create_warning(component, message, technical_details)
		"fatal":
			error_event = ErrorEvent.create_fatal(component, message, technical_details)
		_:
			error_event = ErrorEvent.create_error(component, message, technical_details)
	
	error_occurred.emit(error_event)

## Emit warning with component context
func emit_warning(component: String, message: String):
	warning_issued.emit(message, component)

## Handle error events centrally
func _on_error_occurred(error_event: ErrorEvent):
	match error_event.type:
		ErrorEvent.ErrorType.WARNING:
			print_rich("[color=yellow]⚠️  WARNING [" + error_event.component + "]: " + error_event.message + "[/color]")
		ErrorEvent.ErrorType.ERROR:
			print_rich("[color=red]❌ ERROR [" + error_event.component + "]: " + error_event.message + "[/color]")
		ErrorEvent.ErrorType.FATAL:
			print_rich("[color=purple]💀 FATAL [" + error_event.component + "]: " + error_event.message + "[/color]")
			# Could trigger crash report or emergency save here
	
	if error_event.technical_details != "":
		print("   Technical details: " + error_event.technical_details)

## Handle warning events
func _on_warning_issued(message: String, component: String):
	print_rich("[color=yellow]⚠️  [" + component + "]: " + message + "[/color]")

## Utility function to check if a signal exists
func has_signal_connection(signal_name: String) -> bool:
	return get_signal_list().any(func(sig): return sig.name == signal_name)

## Debug function to list all connected signals
func debug_list_connections():
	print("=== EventBus Signal Connections ===")
	for signal_info in get_signal_list():
		var connections = get_signal_connection_list(signal_info.name)
		if connections.size() > 0:
			print(signal_info.name + " -> " + str(connections.size()) + " connections")
		else:
			print(signal_info.name + " -> No connections")
