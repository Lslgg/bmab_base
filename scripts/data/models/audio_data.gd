class_name AudioData
extends RefCounted

## Audio Data model for rhythm chess system
## Represents audio analysis data and spectrum information
## Used for beat detection, color matching, and audio visualization

# Raw audio information
var timestamp: float = 0.0  # When this audio data was captured
var sample_rate: int = 44100  # Audio sample rate
var buffer_size: int = 512  # Audio buffer size used
var duration: float = 0.0  # Duration of the audio sample in seconds

# Spectrum analysis data
var spectrum_data: PackedFloat32Array = PackedFloat32Array()  # Full spectrum data
var fft_size: int = 1024  # FFT size used for analysis
var frequency_resolution: float = 0.0  # Hz per bin

# Frequency band magnitudes (for color matching system)
var low_freq_magnitude: float = 0.0  # Bass frequencies (20-250 Hz)
var mid_freq_magnitude: float = 0.0  # Mid frequencies (250-4000 Hz)
var high_freq_magnitude: float = 0.0  # Treble frequencies (4000-20000 Hz)

# Beat detection data
var beat_detected: bool = false  # Whether a beat was detected in this sample
var beat_strength: float = 0.0  # Strength of detected beat (0.0 to 1.0)
var tempo_estimate: float = 0.0  # Estimated BPM from this sample

# Audio quality metrics
var signal_level: float = 0.0  # Overall signal level (0.0 to 1.0)
var noise_level: float = 0.0  # Estimated noise level
var signal_to_noise_ratio: float = 0.0  # SNR in dB
var clipping_detected: bool = false  # Whether audio clipping was detected

# Processing metadata
var processing_latency: float = 0.0  # Time taken to process this audio data
var source: String = ""  # Source of the audio data (microphone, file, etc.)
var is_real_time: bool = true  # Whether this is real-time or pre-recorded data

func _init(capture_timestamp: float = 0.0):
	timestamp = capture_timestamp
	frequency_resolution = float(sample_rate) / float(fft_size)

## Create AudioData from spectrum analyzer
static func from_spectrum_analyzer(analyzer: AudioEffectSpectrumAnalyzer, capture_time: float) -> AudioData:
	var audio_data = AudioData.new(capture_time)
	
	# Get spectrum data from analyzer
	var spectrum = PackedFloat32Array()
	var magnitude_average = 0.0
	
	# Sample key frequency ranges using correct Godot 4.x API
	# Note: analyzer parameter should be AudioEffectSpectrumAnalyzerInstance
	audio_data.low_freq_magnitude = analyzer.get_magnitude_for_frequency_range(20.0, 250.0, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX).length()
	audio_data.mid_freq_magnitude = analyzer.get_magnitude_for_frequency_range(250.0, 4000.0, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX).length()
	audio_data.high_freq_magnitude = analyzer.get_magnitude_for_frequency_range(4000.0, 20000.0, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX).length()
	
	# Store the frequency band data as spectrum
	spectrum.append(audio_data.low_freq_magnitude)
	spectrum.append(audio_data.mid_freq_magnitude)
	spectrum.append(audio_data.high_freq_magnitude)
	
	audio_data.spectrum_data = spectrum
	audio_data.source = "spectrum_analyzer"
	
	# Calculate overall signal level
	audio_data.signal_level = (audio_data.low_freq_magnitude + audio_data.mid_freq_magnitude + audio_data.high_freq_magnitude) / 3.0
	
	return audio_data

## Create AudioData from raw audio buffer
static func from_audio_buffer(buffer: PackedFloat32Array, capture_time: float, sample_rate: int = 44100) -> AudioData:
	var audio_data = AudioData.new(capture_time)
	audio_data.sample_rate = sample_rate
	audio_data.buffer_size = buffer.size()
	audio_data.duration = float(buffer.size()) / float(sample_rate)
	audio_data.source = "audio_buffer"
	
	# Calculate basic audio metrics
	audio_data._calculate_audio_metrics(buffer)
	
	return audio_data

## Calculate audio quality metrics from raw buffer
func _calculate_audio_metrics(buffer: PackedFloat32Array):
	if buffer.size() == 0:
		return
	
	var sum_squares = 0.0
	var max_amplitude = 0.0
	var clipping_threshold = 0.95
	
	for sample in buffer:
		var abs_sample = abs(sample)
		sum_squares += sample * sample
		max_amplitude = max(max_amplitude, abs_sample)
		
		if abs_sample >= clipping_threshold:
			clipping_detected = true
	
	# Calculate RMS level
	signal_level = sqrt(sum_squares / buffer.size())
	
	# Estimate noise level (simplified - would need more sophisticated analysis in practice)
	noise_level = signal_level * 0.1  # Rough estimate
	
	# Calculate SNR
	if noise_level > 0.0:
		signal_to_noise_ratio = 20.0 * log(signal_level / noise_level) / log(10.0)
	else:
		signal_to_noise_ratio = 60.0  # Assume good SNR if no noise detected

## Get the dominant frequency band
func get_dominant_frequency_band() -> String:
	var max_magnitude = max(low_freq_magnitude, max(mid_freq_magnitude, high_freq_magnitude))
	
	if max_magnitude == low_freq_magnitude:
		return "low"
	elif max_magnitude == mid_freq_magnitude:
		return "mid"
	else:
		return "high"

## Get color representation based on frequency content
func get_frequency_color() -> Color:
	var max_magnitude = max(low_freq_magnitude, max(mid_freq_magnitude, high_freq_magnitude))
	
	if max_magnitude <= 0.0:
		return Color.GRAY
	
	var red = low_freq_magnitude / max_magnitude
	var green = mid_freq_magnitude / max_magnitude
	var blue = high_freq_magnitude / max_magnitude
	
	return Color(red, green, blue, 1.0)

## Check if audio data is suitable for beat detection
func is_suitable_for_beat_detection() -> bool:
	return signal_level > 0.1 and not clipping_detected and signal_to_noise_ratio > 10.0

## Get audio quality assessment
func get_quality_assessment() -> String:
	if clipping_detected:
		return "poor_clipping"
	elif signal_level < 0.05:
		return "poor_low_signal"
	elif signal_to_noise_ratio < 10.0:
		return "poor_noisy"
	elif signal_level > 0.3 and signal_to_noise_ratio > 20.0:
		return "excellent"
	elif signal_level > 0.1 and signal_to_noise_ratio > 15.0:
		return "good"
	else:
		return "fair"

## Convert to dictionary for serialization
func to_dict() -> Dictionary:
	return {
		"timestamp": timestamp,
		"sample_rate": sample_rate,
		"buffer_size": buffer_size,
		"duration": duration,
		"spectrum_data": spectrum_data,
		"fft_size": fft_size,
		"frequency_resolution": frequency_resolution,
		"low_freq_magnitude": low_freq_magnitude,
		"mid_freq_magnitude": mid_freq_magnitude,
		"high_freq_magnitude": high_freq_magnitude,
		"beat_detected": beat_detected,
		"beat_strength": beat_strength,
		"tempo_estimate": tempo_estimate,
		"signal_level": signal_level,
		"noise_level": noise_level,
		"signal_to_noise_ratio": signal_to_noise_ratio,
		"clipping_detected": clipping_detected,
		"processing_latency": processing_latency,
		"source": source,
		"is_real_time": is_real_time
	}

## Create from dictionary (deserialization)
static func from_dict(data: Dictionary) -> AudioData:
	var audio_data = AudioData.new(data.get("timestamp", 0.0))
	
	audio_data.sample_rate = data.get("sample_rate", 44100)
	audio_data.buffer_size = data.get("buffer_size", 512)
	audio_data.duration = data.get("duration", 0.0)
	audio_data.spectrum_data = data.get("spectrum_data", PackedFloat32Array())
	audio_data.fft_size = data.get("fft_size", 1024)
	audio_data.frequency_resolution = data.get("frequency_resolution", 0.0)
	audio_data.low_freq_magnitude = data.get("low_freq_magnitude", 0.0)
	audio_data.mid_freq_magnitude = data.get("mid_freq_magnitude", 0.0)
	audio_data.high_freq_magnitude = data.get("high_freq_magnitude", 0.0)
	audio_data.beat_detected = data.get("beat_detected", false)
	audio_data.beat_strength = data.get("beat_strength", 0.0)
	audio_data.tempo_estimate = data.get("tempo_estimate", 0.0)
	audio_data.signal_level = data.get("signal_level", 0.0)
	audio_data.noise_level = data.get("noise_level", 0.0)
	audio_data.signal_to_noise_ratio = data.get("signal_to_noise_ratio", 0.0)
	audio_data.clipping_detected = data.get("clipping_detected", false)
	audio_data.processing_latency = data.get("processing_latency", 0.0)
	audio_data.source = data.get("source", "")
	audio_data.is_real_time = data.get("is_real_time", true)
	
	return audio_data
