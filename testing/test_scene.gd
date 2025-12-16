extends Node

## Test scene controller for running project setup tests
## This will initially fail until we implement the required components

func _ready():
	print("Starting project setup tests...")
	
	# Create and run test runner
	var test_runner = TestRunner.new()
	add_child(test_runner)
	
	# Connect to test completion signals
	test_runner.test_completed.connect(_on_test_completed)
	test_runner.all_tests_completed.connect(_on_all_tests_completed)
	
	# Run tests after a brief delay to ensure everything is initialized
	await get_tree().process_frame
	test_runner.run_all_tests()

func _on_test_completed(test_name: String, passed: bool, message: String):
	if passed:
		print("✅ " + test_name + ": " + message)
	else:
		print("❌ " + test_name + ": " + message)

func _on_all_tests_completed(total: int, passed: int, failed: int):
	print("\n🎯 Test Summary:")
	print("   Total tests: " + str(total))
	print("   Passed: " + str(passed))
	print("   Failed: " + str(failed))
	
	if failed == 0:
		print("🎉 All tests passed!")
	else:
		print("⚠️  " + str(failed) + " tests failed - implementation needed")
	
	# Exit after showing results
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
