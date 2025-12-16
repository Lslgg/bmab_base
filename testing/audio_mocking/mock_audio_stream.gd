class_name MockAudioStream
extends RefCounted

## Mock Audio Stream for testing rhythm chess audio systems
## Provides predictable audio data for unit testing and development
## Simulates various audio conditions and beat patterns

enum MockAudioType {
	SILENCE,        # No audio signal
	SINE_WAVE,      # Pure sine wave at specified frequency
	METRONOME,      # Regular metronome beats
	MUSIC_TRACK,    # Simulated music with beats
	NOISE,          # Random noise
	MIXED           # Combination of signals
}

var audio_type: MockAudioType = MockAudioType.METRONOME
var sample_rate: int = 44100
var duration: float = 10.0  # Duration in seconds
var bpm: float = 120.0  # Beats per minute for rhythm patterns

# Audio generation parameters
var frequency: float = 440.0  # Base frequency for sine waves
var amplitude: float = 0.5  # Signal amplitude (0.0 to 1.0)
var beat_strength: float = 0.8  # Strength of beat markers
var noise_level: float = 0.1  # Background noise level

# Generated data
var audio_buffer: PackedFloat32Array = PackedFloat32Array()
var beat_timestamps: Array[float] = []
var spectrum_data_timeline: Array[PackedFloat32Array] = []

func _init(mock_type: MockAudioType = MockAudioType.METRONOME, mock_bpm: float = 120.0):
	audio_type = mock_type
	bpm = mock_bpm

## Generate mock audio data based on the specified type
func generate_audio_data() -> PackedFloat32Array:
	var total_samples = int(duration * sample_rate)
	audio_buffer.resize(total_samples)
	beat_timestamps.clear()
	spectrum_data_timeline.clear()
	
	match audio_type:
		MockAudioType.SILENCE:
			_generate_silence()
		MockAudioType.SINE_WAVE:
			_generate_sine_wave()
		MockAudioType.METRONOME:
			_generate_metronome()
		MockAudioType.MUSIC_TRACK:
			_generate_music_track()
		MockAudioType.NOISE:
			_generate_noise()
		MockAudioType.MIXED:
			_generate_mixed_signal()
	
	# Generate corresponding spectrum data
	_generate_spectrum_timeline()
	
	print("Generated mock audio: " + str(audio_buffer.size()) + " samples, " + str(beat_timestamps.size()) + " beats")
	return audio_buffer

## Generate silence
func _generate_silence():
	for i in range(audio_buffer.size()):
		audio_buffer[i] = 0.0

## Generate pure sine wave
func _generate_sine_wave():
	for i in range(audio_buffer.size()):
		var time = float(i) / sample_rate
		audio_buffer[i] = amplitude * sin(2.0 * PI * frequency * time)

## Generate metronome pattern with clear beats
func _generate_metronome():
	var beat_interval = 60.0 / bpm  # Time between beats in seconds
	var beat_duration = 0.1  # Duration of each beat sound
	
	for i in range(audio_buffer.size()):
		var time = float(i) / sample_rate
		var beat_phase = fmod(time, beat_interval)
		
		# Check if we're at a beat
		if beat_phase < beat_duration:
			# Generate beat sound (short sine wave burst)
			var beat_progress = beat_phase / beat_duration
			var envelope = sin(PI * beat_progress)  # Smooth envelope
			audio_buffer[i] = amplitude * beat_strength * envelope * sin(2.0 * PI * 800.0 * time)
			
			# Record beat timestamp (only once per beat)
			if beat_phase < (1.0 / sample_rate):  # First sample of beat
				beat_timestamps.append(time)
		else:
			# Silence between beats
			audio_buffer[i] = 0.0
		
		# Add small amount of background noise
		audio_buffer[i] += (randf() - 0.5) * noise_level * 0.1

## Generate simulated music track with rhythm
func _generate_music_track():
	var beat_interval = 60.0 / bpm
	var measure_length = beat_interval * 4  # 4/4 time signature
	
	for i in range(audio_buffer.size()):
		var time = float(i) / sample_rate
		var signal2 = 0.0
		
		# Base rhythm track (kick drum simulation)
		var beat_phase = fmod(time, beat_interval)
		if beat_phase < 0.1:
			var envelope = exp(-beat_phase * 20.0)  # Exponential decay
			signal2 += amplitude * 0.8 * envelope * sin(2.0 * PI * 60.0 * time)
			
			# Record beat timestamp
			if beat_phase < (1.0 / sample_rate):
				beat_timestamps.append(time)
		
		# Harmonic content (simulated melody)
		signal2 += amplitude * 0.3 * sin(2.0 * PI * 220.0 * time)  # A3
		signal2 += amplitude * 0.2 * sin(2.0 * PI * 330.0 * time)  # E4
		signal2 += amplitude * 0.15 * sin(2.0 * PI * 440.0 * time)  # A4
		
		# Add some variation based on measure position
		var measure_phase = fmod(time, measure_length) / measure_length
		signal2 *= (0.7 + 0.3 * sin(2.0 * PI * measure_phase))
		
		# Background noise
		signal2 += (randf() - 0.5) * noise_level
		
		audio_buffer[i] = clamp(signal2, -1.0, 1.0)

## Generate random noise
func _generate_noise():
	for i in range(audio_buffer.size()):
		audio_buffer[i] = (randf() - 0.5) * amplitude

## Generate mixed signal (combination of patterns)
func _generate_mixed_signal():
	# Start with metronome base
	_generate_metronome()
	
	# Add harmonic content
	for i in range(audio_buffer.size()):
		var time = float(i) / sample_rate
		audio_buffer[i] += amplitude * 0.2 * sin(2.0 * PI * 220.0 * time)
		audio_buffer[i] += amplitude * 0.1 * sin(2.0 * PI * 330.0 * time)

## Generate spectrum data timeline for testing spectrum analysis
func _generate_spectrum_timeline():
	var samples_per_analysis = sample_rate / 60  # 60 analyses per second
	var analysis_count = int(duration * 60)
	
	for analysis_index in range(analysis_count):
		var time = float(analysis_index) / 60.0
		var spectrum = PackedFloat32Array()
		
		# Simulate frequency analysis based on audio content
		match audio_type:
			MockAudioType.METRONOME:
				# Strong high frequency content during beats
				var beat_phase = fmod(time, 60.0 / bpm)
				if beat_phase < 0.1:
					spectrum.append(0.2)  # Low freq
					spectrum.append(0.3)  # Mid freq  
					spectrum.append(0.8)  # High freq (beat)
				else:
					spectrum.append(0.1)  # Low freq
					spectrum.append(0.1)  # Mid freq
					spectrum.append(0.1)  # High freq
			
			MockAudioType.MUSIC_TRACK:
				# Balanced frequency content with beat emphasis
				var beat_phase = fmod(time, 60.0 / bpm)
				var base_low = 0.6 + 0.3 * sin(2.0 * PI * time * 0.5)
				var base_mid = 0.4 + 0.2 * sin(2.0 * PI * time * 0.3)
				var base_high = 0.3 + 0.2 * sin(2.0 * PI * time * 0.7)
				
				if beat_phase < 0.1:
					base_low *= 1.5  # Emphasize bass on beats
				
				spectrum.append(base_low)
				spectrum.append(base_mid)
				spectrum.append(base_high)
			
			_:
				# Default spectrum
				spectrum.append(0.3)
				spectrum.append(0.3)
				spectrum.append(0.3)
		
		spectrum_data_timeline.append(spectrum)

## Get spectrum data at a specific time
func get_spectrum_at_time(time: float) -> PackedFloat32Array:
	var index = int(time * 60.0)  # 60 analyses per second
	if index >= 0 and index < spectrum_data_timeline.size():
		return spectrum_data_timeline[index]
	else:
		return PackedFloat32Array([0.0, 0.0, 0.0])

## Get all beat timestamps
func get_beat_timestamps() -> Array[float]:
	return beat_timestamps.duplicate()

## Create AudioData object from mock stream at specific time
func create_audio_data_at_time(time: float) -> AudioData:
	var audio_data = AudioData.new(time)
	audio_data.spectrum_data = get_spectrum_at_time(time)
	audio_data.sample_rate = sample_rate
	audio_data.source = "mock_audio_stream"
	audio_data.is_real_time = false
	
	# Set frequency magnitudes
	if audio_data.spectrum_data.size() >= 3:
		audio_data.low_freq_magnitude = audio_data.spectrum_data[0]
		audio_data.mid_freq_magnitude = audio_data.spectrum_data[1]
		audio_data.high_freq_magnitude = audio_data.spectrum_data[2]
	
	return audio_data

## Get mock audio configuration
func get_configuration() -> Dictionary:
	return {
		"type": audio_type,
		"sample_rate": sample_rate,
		"duration": duration,
		"bpm": bpm,
		"frequency": frequency,
		"amplitude": amplitude,
		"beat_count": beat_timestamps.size()
	}
