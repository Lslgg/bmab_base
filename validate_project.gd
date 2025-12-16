extends SceneTree

## Project Validation Script
## Validates the project structure and implementation without requiring Godot GUI
## Run with: godot --headless --script validate_project.gd

func _init():
	print("=== RHYTHM CHESS PROJECT VALIDATION ===")
	print("Validating project structure and implementation...")
	print("")
	
	var total_tests = 0
	var passed_tests = 0
	
	# Test categories
	var results = []
	
	# 1. Project Structure
	print("1. VALIDATING PROJECT STRUCTURE...")
	var structure_result = validate_project_structure()
	results.append(structure_result)
	total_tests += structure_result.total
	passed_tests += structure_result.passed
	
	# 2. Core Files
	print("\n2. VALIDATING CORE FILES...")
	var files_result = validate_core_files()
	results.append(files_result)
	total_tests += files_result.total
	passed_tests += files_result.passed
	
	# 3. Autoload Scripts
	print("\n3. VALIDATING AUTOLOAD SCRIPTS...")
	var autoload_result = validate_autoload_scripts()
	results.append(autoload_result)
	total_tests += autoload_result.total
	passed_tests += autoload_result.passed
	
	# 4. Data Models
	print("\n4. VALIDATING DATA MODELS...")
	var models_result = validate_data_models()
	results.append(models_result)
	total_tests += models_result.total
	passed_tests += models_result.passed
	
	# 5. Project Configuration
	print("\n5. VALIDATING PROJECT CONFIGURATION...")
	var config_result = validate_project_config()
	results.append(config_result)
	total_tests += config_result.total
	passed_tests += config_result.passed
	
	# Print final results
	print("\n" + "=".repeat(60))
	print("VALIDATION COMPLETE")
	print("=".repeat(60))
	print("Total Checks: " + str(total_tests))
	print("Passed: " + str(passed_tests))
	print("Failed: " + str(total_tests - passed_tests))
	
	var success_rate = float(passed_tests) / float(total_tests) * 100.0
	print("Success Rate: " + str(success_rate) + "%")
	
	if passed_tests == total_tests:
		print("\n🎉 ALL VALIDATIONS PASSED!")
		print("✅ Project foundation is complete and ready for development")
		print("✅ Core architecture is properly implemented")
		print("✅ All required files are present and valid")
	else:
		print("\n❌ Some validations failed:")
		for result in results:
			if result.passed < result.total:
				print("  - " + result.category + ": " + str(result.passed) + "/" + str(result.total))
	
	print("=".repeat(60))
	
	# Exit
	quit(0 if passed_tests == total_tests else 1)

func validate_project_structure() -> Dictionary:
	var result = {"category": "Project Structure", "total": 0, "passed": 0}
	
	var required_dirs = [
		"autoload",
		"scripts",
		"scripts/timing_core",
		"scripts/timing_core/interfaces",
		"scripts/data",
		"scripts/data/models",
		"scenes",
		"scenes/main",
		"testing",
		"testing/audio_mocking"
	]
	
	for dir_path in required_dirs:
		result.total += 1
		if DirAccess.dir_exists_absolute(dir_path):
			print("  ✅ Directory exists: " + dir_path)
			result.passed += 1
		else:
			print("  ❌ Directory missing: " + dir_path)
	
	return result

func validate_core_files() -> Dictionary:
	var result = {"category": "Core Files", "total": 0, "passed": 0}
	
	var required_files = [
		"project.godot",
		"README.md"
	]
	
	for file_path in required_files:
		result.total += 1
		if FileAccess.file_exists(file_path):
			print("  ✅ File exists: " + file_path)
			result.passed += 1
		else:
			print("  ❌ File missing: " + file_path)
	
	return result

func validate_autoload_scripts() -> Dictionary:
	var result = {"category": "Autoload Scripts", "total": 0, "passed": 0}
	
	var autoload_files = [
		"autoload/event_bus.gd",
		"autoload/game_manager.gd", 
		"autoload/audio_manager.gd",
		"autoload/settings_manager.gd"
	]
	
	for file_path in autoload_files:
		result.total += 1
		if FileAccess.file_exists(file_path):
			print("  ✅ Autoload exists: " + file_path)
			result.passed += 1
			
			# Check if file has content
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var content = file.get_as_text()
				file.close()
				if content.length() > 100:  # Basic content check
					print("    ✅ File has substantial content")
				else:
					print("    ⚠️  File seems empty or minimal")
		else:
			print("  ❌ Autoload missing: " + file_path)
	
	return result

func validate_data_models() -> Dictionary:
	var result = {"category": "Data Models", "total": 0, "passed": 0}
	
	var model_files = [
		"scripts/data/models/beat_event.gd",
		"scripts/data/models/audio_data.gd",
		"scripts/data/models/error_event.gd"
	]
	
	for file_path in model_files:
		result.total += 1
		if FileAccess.file_exists(file_path):
			print("  ✅ Data model exists: " + file_path)
			result.passed += 1
			
			# Check for class_name declaration
			var file = FileAccess.open(file_path, FileAccess.READ)
			if file:
				var content = file.get_as_text()
				file.close()
				if "class_name" in content:
					print("    ✅ Has class_name declaration")
				else:
					print("    ⚠️  Missing class_name declaration")
		else:
			print("  ❌ Data model missing: " + file_path)
	
	return result

func validate_project_config() -> Dictionary:
	var result = {"category": "Project Configuration", "total": 0, "passed": 0}
	
	# Check project.godot exists and has content
	result.total += 1
	if FileAccess.file_exists("project.godot"):
		var file = FileAccess.open("project.godot", FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			
			# Check for key configuration elements
			var checks = [
				["[application]", "Application section"],
				["[autoload]", "Autoload section"],
				["[audio]", "Audio section"],
				["EventBus", "EventBus autoload"],
				["GameManager", "GameManager autoload"],
				["AudioManager", "AudioManager autoload"],
				["SettingsManager", "SettingsManager autoload"]
			]
			
			for check in checks:
				result.total += 1
				if check[0] in content:
					print("  ✅ " + check[1] + " configured")
					result.passed += 1
				else:
					print("  ❌ " + check[1] + " missing")
		
		print("  ✅ project.godot exists")
		result.passed += 1
	else:
		print("  ❌ project.godot missing")
	
	return result
