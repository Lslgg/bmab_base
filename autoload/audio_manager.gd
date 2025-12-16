class_name AudioManagerSingleton
extends Node

## Audio Manager for Rhythm Chess
## Coordinates audio system, latency management, and spectrum analysis
## Implements the revolutionary delay standardization architecture

const TARGET_LATENCY_MS: float = 50.0  # Standardized latency target
const BUFFER_SIZE: int = 512  # AudioServer buffer size
const SAMPLE_RATE: int = 44100  # Standard sample rate

var audio_backend: String = "godot_native"
var measured_latency_ms: float = 0.0
var compensation_delay_ms: float = 0.0
var spectrum_analyzer: AudioEffectSpectrumAnalyzer
var audio_bus_index: int = 0

# Audio system state
var is_initialized: bool = false
var is_calibrating: bool = false
var calibration_data: Dictionary = {}

func _ready():
	print("AudioManager initializing...")
	
	# Connect to EventBus signals
	EventBus.calibration_started.connect(_on_calibration_started)
	EventBus.audio_device_changed.connect(_on_audio_device_changed)
	
	# Initialize audio system
	_initialize_audio_system()

## Initialize the audio system with proper configuration
func _initialize_audio_system():
	print("Configuring AudioServer...")
	
	# Configure AudioServer settings
	# Note: Some settings may require restart to take effect
	AudioServer.set_bus_count(3)  # Master, Music, SFX
	AudioServer.set_bus_name(0, "Master")
	AudioServer.set_bus_name(1, "Music") 
	AudioServer.set_bus_name(2, "SFX")
	
	# Set up spectrum analyzer on the Master bus
	_setup_spectrum_analyzer()
	
	# Measure initial latency
	_measure_audio_latency()
	
	is_initialized = true
	print("AudioManager initialized successfully")
	EventBus.emit_warning("AudioManager", "Audio system ready - Target latency: " + str(TARGET_LATENCY_MS) + "ms")

## Set up spectrum analyzer for real-time audio analysis
func _setup_spectrum_analyzer():
	# Create spectrum analyzer effect
	spectrum_analyzer = AudioEffectSpectrumAnalyzer.new()
	spectrum_analyzer.buffer_length = 2.0  # 2 second buffer for stability
	spectrum_analyzer.fft_size = AudioEffectSpectrumAnalyzer.FFT_SIZE_1024  # Balance of latency vs accuracy
	
	# Add to Master bus
	audio_bus_index = AudioServer.get_bus_index("Master")
	AudioServer.add_bus_effect(audio_bus_index, spectrum_analyzer)
	
	print("Spectrum analyzer configured: FFT_SIZE_1024, 2.0s buffer")

## Measure current audio latency
func _measure_audio_latency():
	# Use Godot's built-in latency measurement
	var output_latency = AudioServer.get_output_latency()
	measured_latency_ms = output_latency * 1000.0
	
	# Calculate compensation delay for standardization
	if measured_latency_ms < TARGET_LATENCY_MS:
		compensation_delay_ms = TARGET_LATENCY_MS - measured_latency_ms
	else:
		compensation_delay_ms = 0.0
	
	print("Audio latency measured: " + str(measured_latency_ms) + "ms")
	print("Compensation delay: " + str(compensation_delay_ms) + "ms")
	
	EventBus.latency_measured.emit(measured_latency_ms)

## Get real-time spectrum data
func get_spectrum_data() -> PackedFloat32Array:
	if not spectrum_analyzer:
		return PackedFloat32Array()
	
	var spectrum_data = PackedFloat32Array()
	var magnitude_average = 0.0
	
	# Sample key frequency ranges using proper Godot 4.x AudioEffectSpectrumAnalyzer API
	# Use get_magnitude_for_frequency_range with correct parameters
	# Note: We need to get the spectrum analyzer instance from the bus effect

	# Get the spectrum analyzer instance from the bus
	var spectrum_instance = AudioServer.get_bus_effect_instance(audio_bus_index, 0) as AudioEffectSpectrumAnalyzerInstance
	if not spectrum_instance:
		return PackedFloat32Array()

	# Low frequencies (bass) - 20-250 Hz
	var low_freq_mag = spectrum_instance.get_magnitude_for_frequency_range(20.0, 250.0, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX).length()

	# Mid frequencies - 250-4000 Hz
	var mid_freq_mag = spectrum_instance.get_magnitude_for_frequency_range(250.0, 4000.0, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX).length()

	# High frequencies (treble) - 4000-20000 Hz
	var high_freq_mag = spectrum_instance.get_magnitude_for_frequency_range(4000.0, 20000.0, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX).length()
	
	spectrum_data.append(low_freq_mag)
	spectrum_data.append(mid_freq_mag) 
	spectrum_data.append(high_freq_mag)
	
	return spectrum_data

## Apply latency normalization to audio events
func normalize_audio_timing(timestamp: float) -> float:
	# Apply compensation delay to standardize latency
	return timestamp + (compensation_delay_ms / 1000.0)

## Start audio calibration process
func start_calibration():
	if is_calibrating:
		EventBus.emit_warning("AudioManager", "Calibration already in progress")
		return
	
	is_calibrating = true
	calibration_data.clear()
	
	print("Starting audio calibration...")
	EventBus.calibration_started.emit()

## Complete audio calibration
func complete_calibration(user_calibration_data: Dictionary):
	if not is_calibrating:
		EventBus.emit_warning("AudioManager", "No calibration in progress")
		return
	
	calibration_data = user_calibration_data.duplicate()
	is_calibrating = false
	
	# Apply user calibration adjustments
	if calibration_data.has("user_delay_adjustment"):
		compensation_delay_ms += calibration_data["user_delay_adjustment"]
	
	print("Audio calibration completed")
	EventBus.calibration_completed.emit(calibration_data)

## Get current audio system status
func get_audio_status() -> Dictionary:
	return {
		"backend": audio_backend,
		"initialized": is_initialized,
		"measured_latency_ms": measured_latency_ms,
		"compensation_delay_ms": compensation_delay_ms,
		"target_latency_ms": TARGET_LATENCY_MS,
		"calibrating": is_calibrating,
		"sample_rate": SAMPLE_RATE,
		"buffer_size": BUFFER_SIZE
	}

## Handle calibration start event
func _on_calibration_started():
	start_calibration()

## Handle audio device change
func _on_audio_device_changed(device_name: String):
	print("Audio device changed to: " + device_name)
	# Re-measure latency with new device
	_measure_audio_latency()

## Process function for continuous spectrum analysis
func _process(_delta):
	if is_initialized and spectrum_analyzer:
		var spectrum_data = get_spectrum_data()
		if spectrum_data.size() > 0:
			EventBus.spectrum_analysis_updated.emit(spectrum_data)
