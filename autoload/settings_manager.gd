class_name SettingsManagerSingleton
extends Node

## Settings Manager for Rhythm Chess
## Handles configuration persistence, user preferences, and system settings
## Uses Godot ConfigFile for reliable cross-platform settings storage

const SETTINGS_FILE_PATH: String = "user://settings.cfg"
const USER_DATA_FILE_PATH: String = "user://user_data.json"

var config: ConfigFile
var user_data: Dictionary = {}
var default_settings: Dictionary = {}

# Settings categories
var audio_settings: Dictionary = {}
var video_settings: Dictionary = {}
var gameplay_settings: Dictionary = {}
var accessibility_settings: Dictionary = {}

func _ready():
	print("SettingsManager initializing...")
	
	# Initialize ConfigFile
	config = ConfigFile.new()
	
	# Set up default settings
	_setup_default_settings()
	
	# Load existing settings
	_load_settings()
	_load_user_data()
	
	# Connect to EventBus
	EventBus.settings_changed.connect(_on_settings_changed)
	EventBus.calibration_completed.connect(_on_calibration_completed)
	
	print("SettingsManager initialized")

## Set up default settings for all categories
func _setup_default_settings():
	# Audio settings
	audio_settings = {
		"master_volume": 0.8,
		"music_volume": 0.7,
		"sfx_volume": 0.8,
		"audio_latency_compensation": 0.0,
		"enable_audio_feedback": true,
		"audio_device": "default"
	}
	
	# Video settings  
	video_settings = {
		"window_width": 1280,
		"window_height": 720,
		"fullscreen": false,
		"vsync": true,
		"msaa": 2,
		"screen_space_aa": 1,
		"target_fps": 60
	}
	
	# Gameplay settings
	gameplay_settings = {
		"difficulty": "medium",
		"show_move_hints": true,
		"auto_save": true,
		"beat_tolerance_ms": 120,
		"enable_skills": true,
		"camera_sensitivity": 1.0
	}
	
	# Accessibility settings
	accessibility_settings = {
		"colorblind_mode": "none",  # none, protanopia, deuteranopia, tritanopia
		"high_contrast": false,
		"large_ui": false,
		"audio_cues": true,
		"visual_beat_indicator": true,
		"ui_scale": 1.0
	}
	
	# Combine all default settings
	default_settings = {
		"audio": audio_settings,
		"video": video_settings,
		"gameplay": gameplay_settings,
		"accessibility": accessibility_settings
	}

## Load settings from file
func _load_settings():
	var error = config.load(SETTINGS_FILE_PATH)
	
	if error != OK:
		print("No existing settings file found, using defaults")
		_apply_default_settings()
		save_settings()
		return
	
	print("Loading settings from: " + SETTINGS_FILE_PATH)
	
	# Load each category with fallback to defaults
	for category in default_settings.keys():
		for setting_key in default_settings[category].keys():
			var value = config.get_value(category, setting_key, default_settings[category][setting_key])
			set_setting(category, setting_key, value, false)  # Don't save immediately

## Apply default settings
func _apply_default_settings():
	for category in default_settings.keys():
		for setting_key in default_settings[category].keys():
			set_setting(category, setting_key, default_settings[category][setting_key], false)

## Load user data (calibration, progress, etc.)
func _load_user_data():
	var file = FileAccess.open(USER_DATA_FILE_PATH, FileAccess.READ)
	if file == null:
		print("No user data file found, starting fresh")
		user_data = {
			"calibration_data": {},
			"game_progress": {},
			"statistics": {}
		}
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Error parsing user data, using defaults")
		user_data = {}
	else:
		user_data = json.data
		print("User data loaded successfully")

## Set a setting value
func set_setting(category: String, key: String, value: Variant, save_immediately: bool = true):
	if not default_settings.has(category):
		EventBus.emit_error("SettingsManager", "error", "Unknown settings category: " + category)
		return
	
	# Update the appropriate settings dictionary
	match category:
		"audio":
			audio_settings[key] = value
		"video":
			video_settings[key] = value
		"gameplay":
			gameplay_settings[key] = value
		"accessibility":
			accessibility_settings[key] = value
	
	# Update config file
	config.set_value(category, key, value)
	
	# Save if requested
	if save_immediately:
		save_settings()
	
	# Emit change event
	EventBus.settings_changed.emit(category + "." + key, value)

## Get a setting value
func get_setting(category: String, key: String) -> Variant:
	return config.get_value(category, key, null)

## Save settings to file
func save_settings():
	var error = config.save(SETTINGS_FILE_PATH)
	if error != OK:
		EventBus.emit_error("SettingsManager", "error", "Failed to save settings: " + str(error))
	else:
		print("Settings saved successfully")

## Save user data to file
func save_user_data():
	var file = FileAccess.open(USER_DATA_FILE_PATH, FileAccess.WRITE)
	if file == null:
		EventBus.emit_error("SettingsManager", "error", "Failed to open user data file for writing")
		return
	
	var json_string = JSON.stringify(user_data)
	file.store_string(json_string)
	file.close()
	print("User data saved successfully")

## Get all settings for a category
func get_category_settings(category: String) -> Dictionary:
	match category:
		"audio":
			return audio_settings.duplicate()
		"video":
			return video_settings.duplicate()
		"gameplay":
			return gameplay_settings.duplicate()
		"accessibility":
			return accessibility_settings.duplicate()
		_:
			return {}

## Handle settings change events
func _on_settings_changed(setting_name: String, new_value: Variant):
	print("Setting changed: " + setting_name + " = " + str(new_value))

## Handle calibration completion
func _on_calibration_completed(calibration_data: Dictionary):
	user_data["calibration_data"] = calibration_data
	save_user_data()
	print("Calibration data saved to user data")
