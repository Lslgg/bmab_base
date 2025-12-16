class_name LatencyNormalizer
extends Node

## Latency Normalizer - Core component of the revolutionary delay standardization architecture
## Instead of minimizing latency, this system standardizes all latency to a consistent target
## Provides predictable, consistent timing experience across all platforms and hardware

const TARGET_LATENCY_MS: float = 50.0  # Standard latency target for all platforms
const MEASUREMENT_SAMPLES: int = 10  # Number of samples for latency measurement
const CALIBRATION_TOLERANCE_MS: float = 5.0  # Acceptable variance in latency measurements

var measured_latency_ms: float = 0.0
var compensation_delay_ms: float = 0.0
var is_calibrated: bool = false
var measurement_history: Array[float] = []
var timing_source: ITimingSource

# Calibration state
var calibration_in_progress: bool = false
var calibration_samples: Array[float] = []
var user_calibration_offset: float = 0.0

func _ready():
	print("LatencyNormalizer initializing...")
	
	# Connect to EventBus signals
	EventBus.calibration_started.connect(_on_calibration_started)
	EventBus.audio_device_changed.connect(_on_audio_device_changed)
	
	# Start initial latency measurement
	_measure_system_latency()

## Measure the current system audio latency
func _measure_system_latency():
	print("Measuring system audio latency...")
	
	# Use Godot's built-in latency measurement
	var output_latency = AudioServer.get_output_latency()
	measured_latency_ms = output_latency * 1000.0
	
	# Add to measurement history
	measurement_history.append(measured_latency_ms)
	if measurement_history.size() > MEASUREMENT_SAMPLES:
		measurement_history.pop_front()
	
	# Calculate average latency from recent measurements
	var average_latency = measurement_history.reduce(func(a, b): return a + b, 0.0) / measurement_history.size()
	
	# Calculate compensation delay to reach target
	_calculate_compensation_delay(average_latency)
	
	print("Measured latency: " + str(measured_latency_ms) + "ms")
	print("Average latency: " + str(average_latency) + "ms")
	print("Compensation delay: " + str(compensation_delay_ms) + "ms")
	
	# Emit latency measurement event
	EventBus.latency_measured.emit(measured_latency_ms)

## Calculate the compensation delay needed to reach target latency
func _calculate_compensation_delay(current_latency_ms: float):
	if current_latency_ms < TARGET_LATENCY_MS:
		# Add delay to reach target
		compensation_delay_ms = TARGET_LATENCY_MS - current_latency_ms
	else:
		# System latency already exceeds target - no additional delay needed
		compensation_delay_ms = 0.0
		
		# Warn if system latency is significantly higher than target
		if current_latency_ms > TARGET_LATENCY_MS + 20.0:
			EventBus.emit_warning("LatencyNormalizer", 
				"System latency (" + str(current_latency_ms) + "ms) exceeds target (" + str(TARGET_LATENCY_MS) + "ms)")
	
	# Apply user calibration offset
	compensation_delay_ms += user_calibration_offset
	
	# Update timing source if available
	if timing_source:
		timing_source.set_latency_compensation(compensation_delay_ms / 1000.0)

## Normalize an audio event timestamp to the standard latency
func normalize_timing(timestamp: float) -> float:
	return timestamp + (compensation_delay_ms / 1000.0)

## Apply latency normalization to a BeatEvent
func normalize_beat_event(beat_event: BeatEvent) -> BeatEvent:
	beat_event.apply_latency_compensation(compensation_delay_ms / 1000.0)
	return beat_event

## Start calibration process with user interaction
func start_user_calibration():
	if calibration_in_progress:
		EventBus.emit_warning("LatencyNormalizer", "Calibration already in progress")
		return
	
	calibration_in_progress = true
	calibration_samples.clear()
	
	print("Starting user calibration process...")
	EventBus.calibration_started.emit()

## Record a user calibration sample (called when user taps to beat)
func record_calibration_sample(user_tap_time: float, actual_beat_time: float):
	if not calibration_in_progress:
		EventBus.emit_warning("LatencyNormalizer", "No calibration in progress")
		return
	
	var timing_difference = user_tap_time - actual_beat_time
	calibration_samples.append(timing_difference)
	
	print("Calibration sample recorded: " + str(timing_difference * 1000.0) + "ms difference")
	
	# Check if we have enough samples
	if calibration_samples.size() >= 5:
		_complete_user_calibration()

## Complete the user calibration process
func _complete_user_calibration():
	if calibration_samples.size() == 0:
		EventBus.emit_error("LatencyNormalizer", "error", "No calibration samples recorded")
		return
	
	# Calculate average user timing offset
	var average_offset = calibration_samples.reduce(func(a, b): return a + b, 0.0) / calibration_samples.size()
	user_calibration_offset = average_offset * 1000.0  # Convert to milliseconds
	
	# Recalculate compensation delay with user offset
	var average_latency = measurement_history.reduce(func(a, b): return a + b, 0.0) / measurement_history.size()
	_calculate_compensation_delay(average_latency)
	
	calibration_in_progress = false
	is_calibrated = true
	
	print("User calibration completed:")
	print("  User timing offset: " + str(user_calibration_offset) + "ms")
	print("  Final compensation delay: " + str(compensation_delay_ms) + "ms")
	
	# Emit calibration completion event
	var calibration_data = {
		"user_offset_ms": user_calibration_offset,
		"compensation_delay_ms": compensation_delay_ms,
		"target_latency_ms": TARGET_LATENCY_MS,
		"measured_latency_ms": measured_latency_ms,
		"sample_count": calibration_samples.size()
	}
	
	EventBus.calibration_completed.emit(calibration_data)

## Get current latency normalization status
func get_status() -> Dictionary:
	return {
		"target_latency_ms": TARGET_LATENCY_MS,
		"measured_latency_ms": measured_latency_ms,
		"compensation_delay_ms": compensation_delay_ms,
		"user_calibration_offset_ms": user_calibration_offset,
		"is_calibrated": is_calibrated,
		"calibration_in_progress": calibration_in_progress,
		"measurement_samples": measurement_history.size()
	}

## Set a custom timing source
func set_timing_source(source: ITimingSource):
	timing_source = source
	if timing_source:
		timing_source.set_latency_compensation(compensation_delay_ms / 1000.0)

## Handle calibration start event
func _on_calibration_started():
	start_user_calibration()

## Handle audio device change - remeasure latency
func _on_audio_device_changed(device_name: String):
	print("Audio device changed to: " + device_name + " - remeasuring latency")
	measurement_history.clear()
	is_calibrated = false
	_measure_system_latency()

## Continuous latency monitoring
func _process(_delta):
	# Periodically remeasure latency to detect changes
	if randf() < 0.01:  # 1% chance per frame (roughly every 1-2 seconds at 60fps)
		_measure_system_latency()

## Reset calibration data
func reset_calibration():
	user_calibration_offset = 0.0
	is_calibrated = false
	calibration_samples.clear()
	measurement_history.clear()
	_measure_system_latency()
	print("Latency calibration reset")
