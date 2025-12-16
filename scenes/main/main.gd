extends Node

## Main scene controller for Rhythm Chess
## Entry point for the application, handles initialization and scene management

func _ready():
	print("=== Rhythm Chess Starting ===")
	print("Godot version: " + Engine.get_version_info().string)
	print("Platform: " + OS.get_name())
	
	# Initialize core systems
	_initialize_systems()
	
	# Set initial game state
	GameManager.change_state(GameManager.GameState.MENU)
	
	print("Main scene initialized successfully")

## Initialize all core systems
func _initialize_systems():
	print("Initializing core systems...")
	
	# Verify autoload singletons are available
	_verify_autoloads()
	
	# Initialize audio system
	_initialize_audio()
	
	# Set up error handling
	_setup_error_handling()
	
	# Initialize settings
	_initialize_settings()

## Verify that all required autoload singletons are available
func _verify_autoloads():
	var required_autoloads = ["EventBus", "GameManager", "AudioManager", "SettingsManager"]
	
	for autoload_name in required_autoloads:
		var autoload_node = get_node_or_null("/root/" + autoload_name)
		if autoload_node == null:
			push_error("Required autoload not found: " + autoload_name)
			EventBus.emit_error("MainScene", "fatal", "Missing required autoload: " + autoload_name)
		else:
			print("✅ " + autoload_name + " autoload verified")

## Initialize audio system
func _initialize_audio():
	print("Initializing audio system...")
	
	# Connect to audio events
	EventBus.latency_measured.connect(_on_latency_measured)
	EventBus.calibration_completed.connect(_on_calibration_completed)
	
	# Create and add latency normalizer
	var latency_normalizer = LatencyNormalizer.new()
	latency_normalizer.name = "LatencyNormalizer"
	add_child(latency_normalizer)
	
	print("Audio system initialization complete")

## Set up error handling
func _setup_error_handling():
	# Connect to error events
	EventBus.error_occurred.connect(_on_error_occurred)
	EventBus.system_performance_warning.connect(_on_performance_warning)
	
	print("Error handling system initialized")

## Initialize settings system
func _initialize_settings():
	# Apply initial settings
	var video_settings = SettingsManager.get_category_settings("video")
	_apply_video_settings(video_settings)
	
	var audio_settings = SettingsManager.get_category_settings("audio")
	_apply_audio_settings(audio_settings)
	
	print("Settings system initialized")

## Apply video settings
func _apply_video_settings(settings: Dictionary):
	if settings.has("window_width") and settings.has("window_height"):
		get_window().size = Vector2i(settings.window_width, settings.window_height)
	
	if settings.has("fullscreen"):
		if settings.fullscreen:
			get_window().mode = Window.MODE_FULLSCREEN
		else:
			get_window().mode = Window.MODE_WINDOWED
	
	if settings.has("vsync"):
		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_ENABLED if settings.vsync else DisplayServer.VSYNC_DISABLED
		)

## Apply audio settings
func _apply_audio_settings(settings: Dictionary):
	if settings.has("master_volume"):
		AudioServer.set_bus_volume_db(0, linear_to_db(settings.master_volume))
	
	if settings.has("music_volume"):
		var music_bus = AudioServer.get_bus_index("Music")
		if music_bus != -1:
			AudioServer.set_bus_volume_db(music_bus, linear_to_db(settings.music_volume))
	
	if settings.has("sfx_volume"):
		var sfx_bus = AudioServer.get_bus_index("SFX")
		if sfx_bus != -1:
			AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(settings.sfx_volume))

## Handle latency measurement events
func _on_latency_measured(latency_ms: float):
	print("Audio latency measured: " + str(latency_ms) + "ms")

## Handle calibration completion
func _on_calibration_completed(calibration_data: Dictionary):
	print("Audio calibration completed:")
	for key in calibration_data.keys():
		print("  " + key + ": " + str(calibration_data[key]))

## Handle error events
func _on_error_occurred(error_event: ErrorEvent):
	print("Error occurred: " + error_event.get_formatted_message())
	
	# Handle fatal errors
	if error_event.type == ErrorEvent.ErrorType.FATAL:
		print("FATAL ERROR - Initiating emergency shutdown")
		_emergency_shutdown()

## Handle performance warnings
func _on_performance_warning(fps: float, memory_mb: float):
	print("Performance warning - FPS: " + str(fps) + ", Memory: " + str(memory_mb) + "MB")

## Emergency shutdown procedure
func _emergency_shutdown():
	print("=== EMERGENCY SHUTDOWN ===")
	
	# Save critical data
	SettingsManager.save_settings()
	SettingsManager.save_user_data()
	
	# Clean up resources (Godot 4.x compatible)
	# Note: AudioServer.stop() doesn't exist in Godot 4.x
	# Audio cleanup is handled automatically by the engine
	
	# Exit application
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(1)

## Handle application exit
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Application closing...")
		
		# Save settings and user data
		SettingsManager.save_settings()
		SettingsManager.save_user_data()
		
		# Clean shutdown
		get_tree().quit()

## Debug function to test systems
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				# Test error system
				EventBus.emit_error("MainScene", "warning", "Test warning message")
			KEY_F2:
				# Test calibration
				EventBus.calibration_started.emit()
			KEY_F3:
				# Debug EventBus connections
				EventBus.debug_list_connections()
			KEY_F4:
				# Print system status
				_print_system_status()

## Print current system status for debugging
func _print_system_status():
	print("=== SYSTEM STATUS ===")
	print("Game State: " + GameManager.get_current_state_string())
	print("Performance: " + str(GameManager.get_performance_metrics()))
	print("Audio Status: " + str(AudioManager.get_audio_status()))
	
	var latency_normalizer = get_node_or_null("LatencyNormalizer")
	if latency_normalizer:
		print("Latency Status: " + str(latency_normalizer.get_status()))
