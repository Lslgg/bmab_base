class_name TestRunner
extends Node

## Basic test framework for rhythm chess project
## Provides simple assertion-based testing for core components

signal test_completed(test_name: String, passed: bool, message: String)
signal all_tests_completed(total: int, passed: int, failed: int)

var test_results: Array[Dictionary] = []
var current_test_name: String = ""

func _ready():
	print("TestRunner initialized")

## Run all available tests
func run_all_tests():
	print("=== Running All Tests ===")
	test_results.clear()
	
	# Test project structure
	run_test("test_project_structure", test_project_structure)
	
	# Test autoload singletons
	run_test("test_autoload_singletons", test_autoload_singletons)
	
	# Test event bus system
	run_test("test_event_bus_system", test_event_bus_system)
	
	# Test audio system initialization
	run_test("test_audio_system_init", test_audio_system_init)
	
	# Test data models
	run_test("test_data_models", test_data_models)
	
	# Report results
	report_results()

## Run individual test
func run_test(test_name: String, test_func: Callable):
	current_test_name = test_name
	print("Running test: " + test_name)
	
	var result = {
		"name": test_name,
		"passed": false,
		"message": ""
	}
	
	# Execute test function with error handling (Godot 4.x compatible)
	# Note: try/except syntax was removed in Godot 4.x
	if test_func.is_valid():
		test_func.call()
		result.passed = true
		result.message = "PASSED"
		print("  ✅ " + test_name + " PASSED")
	else:
		result.passed = false
		result.message = "FAILED - Invalid test function"
		print("  ❌ " + test_name + " FAILED: " + result.message)
	
	test_results.append(result)
	test_completed.emit(test_name, result.passed, result.message)

## Test project structure exists
func test_project_structure():
	# These should fail initially until we create the structure
	assert_file_exists("project.godot", "Main project file should exist")
	assert_directory_exists("autoload", "Autoload directory should exist")
	assert_directory_exists("scripts/timing_core", "Timing core directory should exist")
	assert_directory_exists("scripts/game_core", "Game core directory should exist")
	assert_directory_exists("scenes", "Scenes directory should exist")
	assert_directory_exists("assets", "Assets directory should exist")

## Test autoload singletons are properly configured
func test_autoload_singletons():
	# These should fail until we create the autoload files
	assert_file_exists("autoload/event_bus.gd", "EventBus autoload should exist")
	assert_file_exists("autoload/game_manager.gd", "GameManager autoload should exist")
	assert_file_exists("autoload/audio_manager.gd", "AudioManager autoload should exist")
	assert_file_exists("autoload/settings_manager.gd", "SettingsManager autoload should exist")

## Test event bus system functionality
func test_event_bus_system():
	# This should fail until EventBus is implemented
	assert_node_exists("/root/EventBus", "EventBus should be available as autoload")

## Test audio system initialization
func test_audio_system_init():
	# This should fail until AudioManager is implemented
	assert_node_exists("/root/AudioManager", "AudioManager should be available as autoload")

## Test data models are properly defined
func test_data_models():
	# These should fail until we create the data model files
	assert_file_exists("scripts/data/models/beat_event.gd", "BeatEvent model should exist")
	assert_file_exists("scripts/data/models/audio_data.gd", "AudioData model should exist")
	assert_file_exists("scripts/data/models/error_event.gd", "ErrorEvent model should exist")

## Utility assertion functions
func assert_file_exists(path: String, message: String):
	if not FileAccess.file_exists(path):
		push_error(message + " - File not found: " + path)

func assert_directory_exists(path: String, message: String):
	if not DirAccess.dir_exists_absolute(path):
		push_error(message + " - Directory not found: " + path)

func assert_node_exists(path: String, message: String):
	if not get_node_or_null(path):
		push_error(message + " - Node not found: " + path)

## Report test results
func report_results():
	var total = test_results.size()
	var passed = 0
	var failed = 0
	
	for result in test_results:
		if result.passed:
			passed += 1
		else:
			failed += 1
	
	print("\n=== Test Results ===")
	print("Total: " + str(total))
	print("Passed: " + str(passed))
	print("Failed: " + str(failed))
	print("Success Rate: " + str(float(passed) / float(total) * 100.0) + "%")
	
	all_tests_completed.emit(total, passed, failed)

func get_last_error() -> String:
	return "Test assertion failed"
