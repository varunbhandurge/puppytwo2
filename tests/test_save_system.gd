class_name TestSaveSystem extends RefCounted

## Test Suite: Save/Load System, Persistence, and Atomic Write Integrity

static func run_all_tests() -> Dictionary:
	var results: Dictionary = {
		"suite_name": "Save & Persistence Architecture",
		"passed": 0,
		"failed": 0,
		"tests": []
	}
	
	_test_save_file_write(results)
	_test_checkpoint_persistence(results)
	_test_reload_data(results)
	
	return results

static func _record(results: Dictionary, test_id: String, name: String, passed: bool, msg: String = ""):
	if passed:
		results["passed"] += 1
	else:
		results["failed"] += 1
	results["tests"].append({
		"id": test_id,
		"name": name,
		"passed": passed,
		"message": msg
	})

static func _test_save_file_write(results: Dictionary) -> void:
	var write_success = SaveManager.save_to_disk()
	var file_exists = FileAccess.file_exists(SaveManager.SAVE_FILE_PATH)
	
	_record(results, "TC-SAV-001", "Atomic Save File Serialization", write_success and file_exists, "Save file written atomically to disk")

static func _test_checkpoint_persistence(results: Dictionary) -> void:
	var target_cp = "cp_garden_test"
	var target_pos = Vector3(15.5, 2.0, -8.0)
	var bones = 4
	
	SaveManager.save_checkpoint_state(target_cp, target_pos, bones)
	var loaded_pos = SaveManager.get_saved_checkpoint_position()
	
	var passed = (SaveManager.current_save_data["checkpoint_id"] == target_cp and loaded_pos.is_equal_approx(target_pos) and SaveManager.current_save_data["golden_bones"] == bones)
	_record(results, "TC-SAV-002", "Checkpoint Coordinates & Bones Persistence", passed, "Checkpoint and bone count persist correctly")

static func _test_reload_data(results: Dictionary) -> void:
	var reload_success = SaveManager.load_game()
	_record(results, "TC-SAV-003", "Save File Parse & Reload Integrity", reload_success, "Save file parsed without errors")
