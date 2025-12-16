class_name IBeatPredictor
extends RefCounted

## Abstract interface for beat prediction systems
## Defines the contract for the revolutionary "Time Prophet" architecture
## Enables predictive timeline generation instead of reactive beat detection

## Predict future beats based on current analysis
func predict_future_beats(current_time: float, bpm: float, prediction_duration: float) -> Array[BeatEvent]:
	push_error("predict_future_beats() must be implemented by subclass")
	return []

## Analyze audio data to determine BPM and beat pattern
func analyze_audio_pattern(audio_data: AudioData) -> Dictionary:
	push_error("analyze_audio_pattern() must be implemented by subclass")
	return {}

## Get confidence level for current beat predictions (0.0 to 1.0)
func get_prediction_confidence() -> float:
	push_error("get_prediction_confidence() must be implemented by subclass")
	return 0.0

## Update prediction model with new audio data
func update_prediction_model(audio_data: AudioData):
	push_error("update_prediction_model() must be implemented by subclass")

## Get the currently detected BPM
func get_current_bpm() -> float:
	push_error("get_current_bpm() must be implemented by subclass")
	return 0.0

## Check if the predictor has enough data to make reliable predictions
func is_ready_for_prediction() -> bool:
	push_error("is_ready_for_prediction() must be implemented by subclass")
	return false

## Reset the prediction model (for new songs or major tempo changes)
func reset_prediction_model():
	push_error("reset_prediction_model() must be implemented by subclass")

## Get the next predicted beat event
func get_next_beat(current_time: float) -> BeatEvent:
	push_error("get_next_beat() must be implemented by subclass")
	return null

## Get prediction accuracy statistics
func get_prediction_stats() -> Dictionary:
	push_error("get_prediction_stats() must be implemented by subclass")
	return {}

## Set prediction parameters (sensitivity, lookahead time, etc.)
func set_prediction_parameters(parameters: Dictionary):
	push_error("set_prediction_parameters() must be implemented by subclass")

## Get the name/type of this beat predictor
func get_predictor_name() -> String:
	push_error("get_predictor_name() must be implemented by subclass")
	return "unknown"
