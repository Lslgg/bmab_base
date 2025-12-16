extends SceneTree

## Comprehensive syntax and dependency test
## Run with: godot --headless --script test_syntax.gd

func _init():
	print("=== COMPREHENSIVE SYNTAX AND DEPENDENCY TEST ===")

	var errors = []
	var warnings = []

	# Test 1: Check if autoload scripts can be loaded
	print("1. Testing autoload script loading...")

	var test_files = [
		"autoload/event_bus.gd",
		"autoload/game_manager.gd",
		"autoload/audio_manager.gd",
		"autoload/settings_manager.gd"
	]

	for file_path in test_files:
		var script = load(file_path)
		if script == null:
			errors.append("Failed to load: " + file_path)
			print("❌ Failed to load: " + file_path)
		else:
			print("✅ Loaded: " + file_path)

	# Test 2: Check data model loading
	print("\n2. Testing data model loading...")

	var model_files = [
		"scripts/data/models/beat_event.gd",
		"scripts/data/models/audio_data.gd",
		"scripts/data/models/error_event.gd",
		"scripts/data/models/board_state.gd"
	]

	for file_path in model_files:
		var script = load(file_path)
		if script == null:
			errors.append("Failed to load: " + file_path)
			print("❌ Failed to load: " + file_path)
		else:
			print("✅ Loaded: " + file_path)

	# Test 3: Check timing core loading
	print("\n3. Testing timing core loading...")

	var timing_files = [
		"scripts/timing_core/interfaces/i_timing_source.gd",
		"scripts/timing_core/interfaces/i_beat_predictor.gd",
		"scripts/timing_core/latency_normalizer.gd"
	]

	for file_path in timing_files:
		var script = load(file_path)
		if script == null:
			errors.append("Failed to load: " + file_path)
			print("❌ Failed to load: " + file_path)
		else:
			print("✅ Loaded: " + file_path)

	# Test 4: Check scene and testing files
	print("\n4. Testing scene and testing files...")

	var other_files = [
		"scenes/main/main.gd",
		"scenes/main/main_scene_builder.gd",
		"testing/test_runner.gd",
		"testing/test_scene.gd",
		"testing/audio_mocking/mock_audio_stream.gd"
	]

	for file_path in other_files:
		var script = load(file_path)
		if script == null:
			errors.append("Failed to load: " + file_path)
			print("❌ Failed to load: " + file_path)
		else:
			print("✅ Loaded: " + file_path)

	# Test 5: Try to instantiate data models
	print("\n5. Testing data model instantiation...")

	# Test BeatEvent
	var beat_event = BeatEvent.new()
	if beat_event != null:
		print("✅ BeatEvent instantiated successfully")
	else:
		errors.append("Failed to instantiate BeatEvent")
		print("❌ Failed to instantiate BeatEvent")

	# Test AudioData
	var audio_data = AudioData.new()
	if audio_data != null:
		print("✅ AudioData instantiated successfully")
	else:
		errors.append("Failed to instantiate AudioData")
		print("❌ Failed to instantiate AudioData")

	# Test ErrorEvent
	var error_event = ErrorEvent.new()
	if error_event != null:
		print("✅ ErrorEvent instantiated successfully")
	else:
		errors.append("Failed to instantiate ErrorEvent")
		print("❌ Failed to instantiate ErrorEvent")

	# Test BoardState
	var board_state = BoardState.new()
	if board_state != null:
		print("✅ BoardState instantiated successfully")
	else:
		errors.append("Failed to instantiate BoardState")
		print("❌ Failed to instantiate BoardState")

	# Test 6: Check scene file existence
	print("\n6. Testing scene file existence...")
	if not FileAccess.file_exists("scenes/main/main.tscn"):
		errors.append("Missing main scene file: scenes/main/main.tscn")
		print("❌ Missing main scene file: scenes/main/main.tscn")
	else:
		print("✅ Main scene file exists")

	# Test 7: Test basic functionality
	print("\n7. Testing basic functionality...")

	# Test ErrorEvent creation methods
	var warning_event = ErrorEvent.create_warning("TestComponent", "Test warning")
	if warning_event != null and warning_event.type == ErrorEvent.ErrorType.WARNING:
		print("✅ ErrorEvent.create_warning() works")
	else:
		errors.append("ErrorEvent.create_warning() failed")
		print("❌ ErrorEvent.create_warning() failed")

	# Test BeatEvent creation
	var predicted_beat = BeatEvent.create_predicted(1.0, 120.0, "TestPredictor")
	if predicted_beat != null and predicted_beat.is_predicted:
		print("✅ BeatEvent.create_predicted() works")
	else:
		errors.append("BeatEvent.create_predicted() failed")
		print("❌ BeatEvent.create_predicted() failed")

	# Test BoardState basic operations
	if board_state.set_piece(0, 0, 0, {"type": "test"}):
		var piece = board_state.get_piece(0, 0, 0)
		if piece != null and piece.has("type"):
			print("✅ BoardState piece operations work")
		else:
			errors.append("BoardState get_piece() failed")
			print("❌ BoardState get_piece() failed")
	else:
		errors.append("BoardState set_piece() failed")
		print("❌ BoardState set_piece() failed")

	# Final results
	print("\n" + "=".repeat(60))
	print("COMPREHENSIVE TEST RESULTS:")
	print("Total Errors: " + str(errors.size()))
	print("Total Warnings: " + str(warnings.size()))

	if errors.size() == 0:
		print("🎉 ALL CRITICAL TESTS PASSED!")
		print("✅ Project foundation is syntactically correct")
		print("✅ All core classes can be instantiated")
		print("✅ Basic functionality works as expected")
		if warnings.size() > 0:
			print("\n⚠️  WARNINGS:")
			for warning in warnings:
				print("  - " + warning)
		quit(0)
	else:
		print("❌ FOUND " + str(errors.size()) + " CRITICAL ERRORS:")
		for error in errors:
			print("  - " + error)
		print("\n🔧 These errors must be fixed before the project can run properly.")
		quit(1)
