extends Node

## Main Scene Builder - Creates the main scene programmatically
## This is a temporary solution until proper .tscn files can be created in Godot editor

func _ready():
	print("Building main scene programmatically...")
	_build_main_scene()

func _build_main_scene():
	# Create main scene structure
	var main_scene = Node.new()
	main_scene.name = "Main"
	main_scene.set_script(load("res://scenes/main/main.gd"))
	
	# Create UI layer
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	main_scene.add_child(ui_layer)
	
	# Create temporary main menu
	var main_menu = _create_main_menu()
	ui_layer.add_child(main_menu)
	
	# Create 3D viewport for future game content
	var viewport_3d = SubViewport.new()
	viewport_3d.name = "GameViewport3D"
	viewport_3d.size = Vector2i(1280, 720)
	viewport_3d.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	main_scene.add_child(viewport_3d)
	
	# Create 3D scene root
	var scene_3d = Node3D.new()
	scene_3d.name = "GameScene3D"
	viewport_3d.add_child(scene_3d)
	
	# Add basic camera
	var camera = Camera3D.new()
	camera.name = "MainCamera"
	camera.position = Vector3(0, 5, 10)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	scene_3d.add_child(camera)
	
	# Add basic lighting
	var light = DirectionalLight3D.new()
	light.name = "MainLight"
	light.position = Vector3(5, 10, 5)
	light.look_at(Vector3.ZERO, Vector3.UP)
	scene_3d.add_child(light)
	
	print("Main scene structure created programmatically")

func _create_main_menu() -> Control:
	var menu = Control.new()
	menu.name = "MainMenu"
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Background
	var background = ColorRect.new()
	background.name = "Background"
	background.color = Color(0.1, 0.1, 0.2, 1.0)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(background)
	
	# Title
	var title = Label.new()
	title.name = "Title"
	title.text = "Rhythm Chess (节奏象棋)"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	title.position.y = 100
	title.size = Vector2(800, 100)
	menu.add_child(title)
	
	# Subtitle
	var subtitle = Label.new()
	subtitle.name = "Subtitle"
	subtitle.text = "Revolutionary 3D Rhythm-Based Chess Game"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	subtitle.position.y = 200
	subtitle.size = Vector2(800, 50)
	menu.add_child(subtitle)
	
	# Status info
	var status = Label.new()
	status.name = "Status"
	status.text = "Foundation Setup Complete - Press F1-F4 for debug functions"
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 16)
	status.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	status.position.y = 100
	status.size = Vector2(800, 30)
	menu.add_child(status)
	
	# System info
	var system_info = Label.new()
	system_info.name = "SystemInfo"
	system_info.text = "Godot " + Engine.get_version_info().string + " | " + OS.get_name()
	system_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	system_info.add_theme_font_size_override("font_size", 14)
	system_info.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	system_info.position.y = -50
	system_info.size = Vector2(400, 30)
	menu.add_child(system_info)
	
	return menu
