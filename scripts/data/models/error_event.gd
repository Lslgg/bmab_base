class_name ErrorEvent
extends RefCounted

## Error Event data model for rhythm chess system
## Standardized error reporting and handling across all components
## Supports the unified error handling architecture via EventBus

enum ErrorType {
	WARNING,    # Non-critical issues that don't affect functionality
	ERROR,      # Significant issues that may affect functionality
	FATAL       # Critical issues that require immediate attention
}

enum ErrorCategory {
	AUDIO,      # Audio system related errors
	TIMING,     # Timing and synchronization errors
	GAME,       # Game logic and state errors
	UI,         # User interface errors
	SYSTEM,     # System and performance errors
	NETWORK,    # Network and connectivity errors (future)
	DATA        # Data persistence and validation errors
}

# Core error information
var type: ErrorType = ErrorType.ERROR
var category: ErrorCategory = ErrorCategory.SYSTEM
var component: String = ""  # Name of the component that generated the error
var message: String = ""  # User-friendly error message
var technical_details: String = ""  # Technical details for debugging

# Context information
var timestamp: float = 0.0  # When the error occurred
var stack_trace: Array[String] = []  # Call stack if available
var user_action: String = ""  # What the user was doing when error occurred
var game_state: String = ""  # Current game state when error occurred

# Error handling metadata
var is_recoverable: bool = true  # Whether the error can be recovered from
var suggested_action: String = ""  # Suggested action for the user
var error_code: String = ""  # Unique error code for tracking
var occurrence_count: int = 1  # How many times this error has occurred

# System context
var fps_at_error: float = 0.0  # FPS when error occurred
var memory_usage_mb: float = 0.0  # Memory usage when error occurred
var audio_latency_ms: float = 0.0  # Audio latency when error occurred

func _init(error_type: ErrorType = ErrorType.ERROR, error_component: String = "", error_message: String = ""):
	type = error_type
	component = error_component
	message = error_message
	timestamp = Time.get_unix_time_from_system()
	
	# Capture system context
	fps_at_error = Engine.get_frames_per_second()
	# Use available memory info in Godot 4.x
	memory_usage_mb = OS.get_static_memory_usage() / 1024.0 / 1024.0

## Create a warning error event
static func create_warning(component: String, message: String, details: String = "") -> ErrorEvent:
	var error_event = ErrorEvent.new(ErrorType.WARNING, component, message)
	error_event.technical_details = details
	error_event.is_recoverable = true
	return error_event

## Create a standard error event
static func create_error(component: String, message: String, details: String = "") -> ErrorEvent:
	var error_event = ErrorEvent.new(ErrorType.ERROR, component, message)
	error_event.technical_details = details
	error_event.is_recoverable = true
	return error_event

## Create a fatal error event
static func create_fatal(component: String, message: String, details: String = "") -> ErrorEvent:
	var error_event = ErrorEvent.new(ErrorType.FATAL, component, message)
	error_event.technical_details = details
	error_event.is_recoverable = false
	return error_event

## Create an audio-related error
static func create_audio_error(component: String, message: String, latency_ms: float = 0.0) -> ErrorEvent:
	var error_event = ErrorEvent.create_error(component, message)
	error_event.category = ErrorCategory.AUDIO
	error_event.audio_latency_ms = latency_ms
	error_event.error_code = "AUDIO_" + str(Time.get_unix_time_from_system())
	return error_event

## Create a timing-related error
static func create_timing_error(component: String, message: String, timing_details: String = "") -> ErrorEvent:
	var error_event = ErrorEvent.create_error(component, message)
	error_event.category = ErrorCategory.TIMING
	error_event.technical_details = timing_details
	error_event.error_code = "TIMING_" + str(Time.get_unix_time_from_system())
	return error_event

## Set the error category
func set_category(error_category: ErrorCategory) -> ErrorEvent:
	category = error_category
	return self

## Set user context information
func set_user_context(action: String, state: String) -> ErrorEvent:
	user_action = action
	game_state = state
	return self

## Set suggested recovery action
func set_suggested_action(action: String) -> ErrorEvent:
	suggested_action = action
	return self

## Set error code for tracking
func set_error_code(code: String) -> ErrorEvent:
	error_code = code
	return self

## Mark as non-recoverable
func mark_non_recoverable() -> ErrorEvent:
	is_recoverable = false
	return self

## Add stack trace information
func add_stack_trace(trace: Array[String]) -> ErrorEvent:
	stack_trace = trace.duplicate()
	return self

## Increment occurrence count
func increment_occurrence():
	occurrence_count += 1
	timestamp = Time.get_unix_time_from_system()  # Update to latest occurrence

## Get error severity as string
func get_severity_string() -> String:
	match type:
		ErrorType.WARNING:
			return "WARNING"
		ErrorType.ERROR:
			return "ERROR"
		ErrorType.FATAL:
			return "FATAL"
		_:
			return "UNKNOWN"

## Get error category as string
func get_category_string() -> String:
	match category:
		ErrorCategory.AUDIO:
			return "AUDIO"
		ErrorCategory.TIMING:
			return "TIMING"
		ErrorCategory.GAME:
			return "GAME"
		ErrorCategory.UI:
			return "UI"
		ErrorCategory.SYSTEM:
			return "SYSTEM"
		ErrorCategory.NETWORK:
			return "NETWORK"
		ErrorCategory.DATA:
			return "DATA"
		_:
			return "UNKNOWN"

## Get formatted error message for display
func get_formatted_message() -> String:
	var severity_icon = "⚠️" if type == ErrorType.WARNING else ("❌" if type == ErrorType.ERROR else "💀")
	return severity_icon + " [" + component + "] " + message

## Get detailed error report
func get_detailed_report() -> String:
	var report = "=== ERROR REPORT ===\n"
	report += "Severity: " + get_severity_string() + "\n"
	report += "Category: " + get_category_string() + "\n"
	report += "Component: " + component + "\n"
	report += "Message: " + message + "\n"
	report += "Timestamp: " + str(timestamp) + "\n"
	
	if technical_details != "":
		report += "Technical Details: " + technical_details + "\n"
	
	if error_code != "":
		report += "Error Code: " + error_code + "\n"
	
	if occurrence_count > 1:
		report += "Occurrences: " + str(occurrence_count) + "\n"
	
	report += "Recoverable: " + str(is_recoverable) + "\n"
	
	if suggested_action != "":
		report += "Suggested Action: " + suggested_action + "\n"
	
	report += "System Context:\n"
	report += "  FPS: " + str(fps_at_error) + "\n"
	report += "  Memory: " + str(memory_usage_mb) + " MB\n"
	
	if audio_latency_ms > 0.0:
		report += "  Audio Latency: " + str(audio_latency_ms) + " ms\n"
	
	if user_action != "":
		report += "User Context:\n"
		report += "  Action: " + user_action + "\n"
		report += "  Game State: " + game_state + "\n"
	
	return report

## Convert to dictionary for serialization
func to_dict() -> Dictionary:
	return {
		"type": type,
		"category": category,
		"component": component,
		"message": message,
		"technical_details": technical_details,
		"timestamp": timestamp,
		"stack_trace": stack_trace,
		"user_action": user_action,
		"game_state": game_state,
		"is_recoverable": is_recoverable,
		"suggested_action": suggested_action,
		"error_code": error_code,
		"occurrence_count": occurrence_count,
		"fps_at_error": fps_at_error,
		"memory_usage_mb": memory_usage_mb,
		"audio_latency_ms": audio_latency_ms
	}
