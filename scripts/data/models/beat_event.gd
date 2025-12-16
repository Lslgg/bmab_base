class_name BeatEvent
extends RefCounted

## Beat Event data model for rhythm chess system
## Represents a single beat detection or prediction event
## Core data structure for the Time Prophet architecture

# Timing information
var timestamp: float = 0.0  # Exact time of the beat in seconds
var compensated_timestamp: float = 0.0  # Timestamp with latency compensation applied
var beat_index: int = 0  # Sequential beat number in the current song
var measure_index: int = 0  # Which measure this beat belongs to
var beat_in_measure: int = 0  # Position within the measure (1-4 for 4/4 time)

# Beat characteristics
var bpm: float = 120.0  # Beats per minute at this point
var confidence: float = 0.0  # Confidence level (0.0 to 1.0)
var intensity: float = 0.0  # Beat intensity/strength (0.0 to 1.0)
var is_predicted: bool = false  # True if this is a predicted beat, false if detected

# Audio analysis data
var frequency_data: PackedFloat32Array = PackedFloat32Array()  # Spectrum data at beat time
var low_freq_magnitude: float = 0.0  # Bass/low frequency strength
var mid_freq_magnitude: float = 0.0  # Mid frequency strength  
var high_freq_magnitude: float = 0.0  # Treble/high frequency strength

# Color matching data (derived from frequency analysis)
var dominant_color: Color = Color.WHITE  # Primary color based on frequency analysis
var color_components: Vector3 = Vector3.ZERO  # RGB components (low=R, mid=G, high=B)

# Prediction metadata
var prediction_source: String = ""  # Name of the predictor that generated this event
var prediction_accuracy: float = 0.0  # Historical accuracy of predictions from this source
var time_to_beat: float = 0.0  # Time remaining until this beat (for predicted beats)

# Game state context
var game_phase: String = ""  # Current game phase when beat occurred
var player_action_window: bool = false  # True if player can act on this beat

func _init(beat_timestamp: float = 0.0, beat_bpm: float = 120.0):
	timestamp = beat_timestamp
	bpm = beat_bpm
	compensated_timestamp = timestamp  # Will be updated by timing system

## Create a beat event from audio analysis
static func from_audio_analysis(audio_data: AudioData, detected_bpm: float, beat_time: float) -> BeatEvent:
	var beat_event = BeatEvent.new(beat_time, detected_bpm)
	beat_event.is_predicted = false
	beat_event.frequency_data = audio_data.spectrum_data.duplicate()
	beat_event._calculate_frequency_magnitudes()
	beat_event._calculate_color_data()
	return beat_event

## Create a predicted beat event
static func create_predicted(predicted_time: float, predicted_bpm: float, predictor_name: String) -> BeatEvent:
	var beat_event = BeatEvent.new(predicted_time, predicted_bpm)
	beat_event.is_predicted = true
	beat_event.prediction_source = predictor_name
	beat_event.time_to_beat = predicted_time - Time.get_unix_time_from_system()
	return beat_event

## Calculate frequency magnitude values from spectrum data
func _calculate_frequency_magnitudes():
	if frequency_data.size() >= 3:
		low_freq_magnitude = frequency_data[0]
		mid_freq_magnitude = frequency_data[1] 
		high_freq_magnitude = frequency_data[2]

## Calculate color data based on frequency analysis
func _calculate_color_data():
	# Map frequency magnitudes to RGB color components
	# Low frequencies -> Red, Mid frequencies -> Green, High frequencies -> Blue
	var max_magnitude = max(low_freq_magnitude, max(mid_freq_magnitude, high_freq_magnitude))
	
	if max_magnitude > 0.0:
		color_components.x = low_freq_magnitude / max_magnitude  # Red component
		color_components.y = mid_freq_magnitude / max_magnitude  # Green component
		color_components.z = high_freq_magnitude / max_magnitude  # Blue component
	else:
		color_components = Vector3(0.5, 0.5, 0.5)  # Neutral gray
	
	# Create the dominant color
	dominant_color = Color(color_components.x, color_components.y, color_components.z, 1.0)

## Apply latency compensation to timestamps
func apply_latency_compensation(compensation_seconds: float):
	compensated_timestamp = timestamp + compensation_seconds

## Check if this beat is within the player action window
func is_actionable(current_time: float, tolerance_ms: float = 120.0) -> bool:
	var tolerance_seconds = tolerance_ms / 1000.0
	var time_diff = abs(compensated_timestamp - current_time)
	return time_diff <= tolerance_seconds

## Get time until this beat occurs (negative if beat has passed)
func get_time_to_beat(current_time: float) -> float:
	return compensated_timestamp - current_time

## Convert to dictionary for serialization
func to_dict() -> Dictionary:
	return {
		"timestamp": timestamp,
		"compensated_timestamp": compensated_timestamp,
		"beat_index": beat_index,
		"measure_index": measure_index,
		"beat_in_measure": beat_in_measure,
		"bpm": bpm,
		"confidence": confidence,
		"intensity": intensity,
		"is_predicted": is_predicted,
		"low_freq_magnitude": low_freq_magnitude,
		"mid_freq_magnitude": mid_freq_magnitude,
		"high_freq_magnitude": high_freq_magnitude,
		"dominant_color": {
			"r": dominant_color.r,
			"g": dominant_color.g,
			"b": dominant_color.b,
			"a": dominant_color.a
		},
		"prediction_source": prediction_source,
		"prediction_accuracy": prediction_accuracy,
		"game_phase": game_phase,
		"player_action_window": player_action_window
	}

## Create from dictionary (deserialization)
static func from_dict(data: Dictionary) -> BeatEvent:
	var beat_event = BeatEvent.new(data.get("timestamp", 0.0), data.get("bpm", 120.0))
	
	beat_event.compensated_timestamp = data.get("compensated_timestamp", beat_event.timestamp)
	beat_event.beat_index = data.get("beat_index", 0)
	beat_event.measure_index = data.get("measure_index", 0)
	beat_event.beat_in_measure = data.get("beat_in_measure", 0)
	beat_event.confidence = data.get("confidence", 0.0)
	beat_event.intensity = data.get("intensity", 0.0)
	beat_event.is_predicted = data.get("is_predicted", false)
	beat_event.low_freq_magnitude = data.get("low_freq_magnitude", 0.0)
	beat_event.mid_freq_magnitude = data.get("mid_freq_magnitude", 0.0)
	beat_event.high_freq_magnitude = data.get("high_freq_magnitude", 0.0)
	beat_event.prediction_source = data.get("prediction_source", "")
	beat_event.prediction_accuracy = data.get("prediction_accuracy", 0.0)
	beat_event.game_phase = data.get("game_phase", "")
	beat_event.player_action_window = data.get("player_action_window", false)
	
	# Reconstruct color data
	var color_data = data.get("dominant_color", {})
	if color_data.has("r"):
		beat_event.dominant_color = Color(color_data.r, color_data.g, color_data.b, color_data.a)
		beat_event.color_components = Vector3(color_data.r, color_data.g, color_data.b)
	
	return beat_event
