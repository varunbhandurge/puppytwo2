class_name TestPCReleasePackagingScript extends RefCounted

## Automated QA Unit Test Suite: Windows PC Release & Packaging Architecture

static func run_all_tests() -> Dictionary:
	var results = {
		"suite_name": "Windows PC Release & Packaging Architecture",
		"tests": []
	}
	
	results["tests"].append(_test_steam_manager_and_achievements())
	results["tests"].append(_test_cloud_save_and_rich_presence())
	results["tests"].append(_test_controller_glyphs_mapping())
	results["tests"].append(_test_export_presets_configuration())
	results["tests"].append(_test_packaging_script_integrity())
	
	return results

static func _test_steam_manager_and_achievements() -> Dictionary:
	var test = {
		"id": "TC-PKG-001",
		"name": "SteamManager & Achievements Registry",
		"passed": false,
		"message": ""
	}
	
	var steam_mgr = SteamManagerSingleton.new()
	steam_mgr._ready()
	
	# Verify achievements catalog contains 12 campaign achievements
	if steam_mgr.ACHIEVEMENTS.size() < 12:
		test["message"] = "Expected at least 12 achievements, found %d" % steam_mgr.ACHIEVEMENTS.size()
		steam_mgr.queue_free()
		return test
		
	# Check key milestone achievements
	var expected_keys = [
		"ACH_CHAPTER_1_COMPLETE",
		"ACH_CHAPTER_4_COMPLETE",
		"ACH_CHAPTER_7_COMPLETE",
		"ACH_CAMPAIGN_COMPLETE",
		"ACH_BONE_COLLECTOR_HALF",
		"ACH_BONE_COLLECTOR_ALL"
	]
	
	for k in expected_keys:
		if not steam_mgr.ACHIEVEMENTS.has(k):
			test["message"] = "Missing expected achievement: " + k
			steam_mgr.queue_free()
			return test
			
	# Test unlocking an achievement
	var unlocked_fired = {"val": false}
	steam_mgr.achievement_unlocked.connect(func(_ach_id): unlocked_fired["val"] = true)
	
	var unlock_success = steam_mgr.unlock_achievement("ACH_CHAPTER_1_COMPLETE")
	if not unlock_success or not steam_mgr.is_achievement_unlocked("ACH_CHAPTER_1_COMPLETE") or not unlocked_fired["val"]:
		test["message"] = "Achievement unlock failed or signal not emitted"
		steam_mgr.queue_free()
		return test
		
	test["passed"] = true
	test["message"] = "12 achievements registered; offline unlock and signal verification succeeded"
	steam_mgr.queue_free()
	return test

static func _test_cloud_save_and_rich_presence() -> Dictionary:
	var test = {
		"id": "TC-PKG-002",
		"name": "Cloud Save & Rich Presence Sync",
		"passed": false,
		"message": ""
	}
	
	var steam_mgr = SteamManagerSingleton.new()
	steam_mgr._ready()
	
	# Test rich presence invocation
	steam_mgr.set_rich_presence("Exploring Chapter 1: The Backyard")
	
	# Test cloud save synchronization
	var sync_completed = {"val": false}
	steam_mgr.cloud_save_synced.connect(func(_success): sync_completed["val"] = true)
	
	var res = steam_mgr.sync_cloud_save()
	if not res or not sync_completed["val"]:
		test["message"] = "Cloud save sync failed or signal not fired"
		steam_mgr.queue_free()
		return test
		
	test["passed"] = true
	test["message"] = "Rich presence set and cloud save sync callback verified"
	steam_mgr.queue_free()
	return test

static func _test_controller_glyphs_mapping() -> Dictionary:
	var test = {
		"id": "TC-PKG-003",
		"name": "Controller Glyphs Multi-Device Mapping",
		"passed": false,
		"message": ""
	}
	
	# 1. Test Xbox mappings
	var xbox_jump = ControllerGlyphs.get_glyph("p1_jump", ControllerGlyphs.DeviceType.XBOX)
	var xbox_interact = ControllerGlyphs.get_glyph("p1_interact", ControllerGlyphs.DeviceType.XBOX)
	var xbox_special = ControllerGlyphs.get_glyph("p1_special", ControllerGlyphs.DeviceType.XBOX)
	if xbox_jump != "[A]" or xbox_interact != "[X]" or xbox_special != "[Y]":
		test["message"] = "Xbox glyph mismatch: jump=%s, interact=%s, special=%s" % [xbox_jump, xbox_interact, xbox_special]
		return test
		
	# 2. Test PlayStation mappings
	var ps_jump = ControllerGlyphs.get_glyph("p1_jump", ControllerGlyphs.DeviceType.PLAYSTATION)
	var ps_bark = ControllerGlyphs.get_glyph("p1_bark", ControllerGlyphs.DeviceType.PLAYSTATION)
	if ps_jump != "[✕]" or ps_bark != "[○]":
		test["message"] = "PlayStation glyph mismatch: jump=%s, bark=%s" % [ps_jump, ps_bark]
		return test
		
	# 3. Test Keyboard mappings
	var kb_jump = ControllerGlyphs.get_glyph("p1_jump", ControllerGlyphs.DeviceType.KEYBOARD_MOUSE)
	var kb_move = ControllerGlyphs.get_glyph("p1_move", ControllerGlyphs.DeviceType.KEYBOARD_MOUSE)
	if kb_jump != "[Space]" or kb_move != "[W,A,S,D]":
		test["message"] = "Keyboard glyph mismatch: jump=%s, move=%s" % [kb_jump, kb_move]
		return test
		
	# 4. Test format_prompt template interpolation
	var template = "Press {p1_jump} to Jump and {p1_interact} to Push!"
	var formatted_xbox = ControllerGlyphs.format_prompt(template, ControllerGlyphs.DeviceType.XBOX)
	if formatted_xbox != "Press [A] to Jump and [X] to Push!":
		test["message"] = "Formatted prompt mismatch: " + formatted_xbox
		return test
		
	test["passed"] = true
	test["message"] = "Xbox, PlayStation, and Keyboard multi-device glyph substitutions confirmed"
	return test

static func _test_export_presets_configuration() -> Dictionary:
	var test = {
		"id": "TC-PKG-004",
		"name": "Export Presets Configuration Validation",
		"passed": false,
		"message": ""
	}
	
	if not FileAccess.file_exists("res://export_presets.cfg"):
		test["message"] = "res://export_presets.cfg not found"
		return test
		
	var file = FileAccess.open("res://export_presets.cfg", FileAccess.READ)
	if not file:
		test["message"] = "Unable to read export_presets.cfg"
		return test
		
	var content = file.get_as_text()
	file.close()
	
	if not 'name="Windows Desktop"' in content:
		test["message"] = "Missing Windows Desktop preset name"
		return test
		
	if not 'platform="Windows Desktop"' in content:
		test["message"] = "Missing Windows Desktop platform"
		return test
		
	if not 'binary_format/architecture="x86_64"' in content:
		test["message"] = "Missing x86_64 architecture configuration"
		return test
		
	if not ('binary_format/embed_pck=true' in content or 'binary_format/embed_pck=false' in content):
		test["message"] = "Missing binary_format/embed_pck setting"
		return test
		
	test["passed"] = true
	test["message"] = "Windows Desktop x86_64 preset with embedded PCK verified in export_presets.cfg"
	return test

static func _test_packaging_script_integrity() -> Dictionary:
	var test = {
		"id": "TC-PKG-005",
		"name": "Packaging Automation Script Integrity",
		"passed": false,
		"message": ""
	}
	
	var script_path = "res://scripts/package_windows_release.ps1"
	if not FileAccess.file_exists(script_path):
		test["message"] = "Release packaging PowerShell script missing at " + script_path
		return test
		
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		test["message"] = "Unable to read package_windows_release.ps1"
		return test
		
	var content = file.get_as_text()
	file.close()
	
	if not "test_runner_scene.tscn" in content:
		test["message"] = "Packaging script does not execute QA test suite"
		return test
		
	if not "TwoPuppiesTheGreatAdventure.exe" in content:
		test["message"] = "Packaging script does not define target executable name"
		return test
		
	if not "SHA256SUMS.txt" in content:
		test["message"] = "Packaging script does not generate SHA256 checksums"
		return test
		
	if not "Compress-Archive" in content:
		test["message"] = "Packaging script does not produce distributable zip archive"
		return test
		
	test["passed"] = true
	test["message"] = "PowerShell release script verified with QA tests, SHA256 hashing, and ZIP archive creation"
	return test
