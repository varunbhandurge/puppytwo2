class_name SaveManagerSingleton extends Node

## Robust Save & Persistence Manager with Atomic Write Safety, Multi-Slot Support,
## Character Customization & Video/Audio Settings Persistence

const SAVE_DIR: String = "user://saves"
const SAVE_FILE_PATH: String = "user://saves/savegame.dat"
const TMP_FILE_PATH: String = "user://saves/savegame.dat.tmp"

var current_save_data: Dictionary = {
	"version": "1.0.0",
	"chapter_index": 1,
	"checkpoint_id": "cp_ch1_doghouse",
	"checkpoint_pos": [0.0, 0.5, 9.0],
	"golden_bones": 0,
	"unlocked_chapters": [1],
	"customization": {
		"p1_name": "Bruno",
		"p1_collar_color": [0.88, 0.22, 0.18, 1.0],
		"p1_tag_type": "Golden Bone",
		"p1_fur_tone": "Honey Gold",
		"p2_name": "Milo",
		"p2_collar_color": [0.18, 0.44, 0.88, 1.0],
		"p2_tag_type": "Brass Bell",
		"p2_fur_tone": "Classic Tricolor"
	},
	"settings": {
		"split_vertical": true,
		"resolution_w": 1920,
		"resolution_h": 1080,
		"window_mode": 0, # 0 = Windowed, 1 = Borderless, 2 = Fullscreen
		"vsync": true,
		"sound_enabled": true,
		"master_volume": 1.0,
		"bgm_volume": 0.8,
		"sfx_volume": 0.9,
		"subtitles": true
	}
}

func _ready() -> void:
	ensure_save_directory()
	load_game()

func ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

# ------------------------------------------------------------------------------
# Checkpoint & General Autosave API
# ------------------------------------------------------------------------------

func save_checkpoint_state(cp_id: String, safe_pos: Vector3, bones_count: int) -> bool:
	current_save_data["checkpoint_id"] = cp_id
	current_save_data["checkpoint_pos"] = [safe_pos.x, safe_pos.y, safe_pos.z]
	current_save_data["golden_bones"] = bones_count
	current_save_data["timestamp"] = Time.get_unix_time_from_system()
	return save_to_disk()

func save_to_disk(target_path: String = SAVE_FILE_PATH) -> bool:
	ensure_save_directory()
	var json_str = JSON.stringify(current_save_data, "\t")
	var tmp_path = target_path + ".tmp"
	
	# Atomic write pattern: Write to .tmp first, then rename
	var tmp_file = FileAccess.open(tmp_path, FileAccess.WRITE)
	if not tmp_file:
		push_error("Failed to open temporary save file for writing: " + tmp_path)
		return false
	
	tmp_file.store_string(json_str)
	tmp_file.close()
	
	if FileAccess.file_exists(target_path):
		DirAccess.remove_absolute(target_path)
	var err = DirAccess.rename_absolute(tmp_path, target_path)
	return err == OK

func load_game(source_path: String = SAVE_FILE_PATH) -> bool:
	if not FileAccess.file_exists(source_path):
		return false
	
	var file = FileAccess.open(source_path, FileAccess.READ)
	if not file:
		push_warning("Could not open save file for reading: " + source_path)
		return false
	
	var content = file.get_as_text()
	file.close()
	
	var test_json_conv = JSON.new()
	var parse_err = test_json_conv.parse(content)
	if parse_err != OK:
		push_error("JSON Parse Error in save file: " + test_json_conv.get_error_message())
		return false
	
	var parsed_dict = test_json_conv.get_data()
	if typeof(parsed_dict) == TYPE_DICTIONARY:
		current_save_data.merge(parsed_dict, true)
		return true
	return false

func get_saved_checkpoint_position() -> Vector3:
	var arr = current_save_data.get("checkpoint_pos", [0.0, 1.0, 0.0])
	if arr.size() >= 3:
		return Vector3(arr[0], arr[1], arr[2])
	return Vector3.ZERO

# ------------------------------------------------------------------------------
# Multi-Slot Manual Save/Load System (Slots 1, 2, 3)
# ------------------------------------------------------------------------------

func get_slot_path(slot_index: int) -> String:
	return "%s/slot_%d.dat" % [SAVE_DIR, slot_index]

func save_slot(slot_index: int) -> bool:
	current_save_data["timestamp"] = Time.get_unix_time_from_system()
	current_save_data["slot_index"] = slot_index
	current_save_data["chapter_index"] = GameManager.current_chapter_index
	current_save_data["golden_bones"] = GameManager.golden_bones_collected
	var path = get_slot_path(slot_index)
	var ok = save_to_disk(path)
	if ok:
		save_to_disk(SAVE_FILE_PATH) # Also mirror to active save
	return ok

func load_slot(slot_index: int) -> bool:
	var path = get_slot_path(slot_index)
	var ok = load_game(path)
	if ok:
		GameManager.current_chapter_index = current_save_data.get("chapter_index", 1)
		GameManager.golden_bones_collected = current_save_data.get("golden_bones", 0)
	return ok

func get_slot_summary(slot_index: int) -> Dictionary:
	var path = get_slot_path(slot_index)
	if not FileAccess.file_exists(path):
		return {"exists": false, "name": "Empty Slot %d" % slot_index}
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {"exists": false, "name": "Empty Slot %d" % slot_index}
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(content) != OK:
		return {"exists": false, "name": "Corrupt Slot %d" % slot_index}
		
	var data = json.get_data()
	var time_str = ""
	if data.has("timestamp"):
		var dt = Time.get_datetime_dict_from_unix_time(int(data["timestamp"]))
		time_str = "%02d/%02d/%04d %02d:%02d" % [dt.day, dt.month, dt.year, dt.hour, dt.minute]
		
	var ch_idx = data.get("chapter_index", 1)
	var bones = data.get("golden_bones", 0)
	var p1_name = "Bruno"
	var p2_name = "Milo"
	if data.has("customization"):
		p1_name = data["customization"].get("p1_name", "Bruno")
		p2_name = data["customization"].get("p2_name", "Milo")
		
	return {
		"exists": true,
		"slot_index": slot_index,
		"chapter_index": ch_idx,
		"chapter_title": "Chapter %d" % ch_idx,
		"golden_bones": bones,
		"time_str": time_str,
		"p1_name": p1_name,
		"p2_name": p2_name
	}

# ------------------------------------------------------------------------------
# Character Customization Persistence
# ------------------------------------------------------------------------------

func save_customization(custom_data: Dictionary) -> void:
	if not current_save_data.has("customization"):
		current_save_data["customization"] = {}
	current_save_data["customization"].merge(custom_data, true)
	save_to_disk()

func get_customization() -> Dictionary:
	if not current_save_data.has("customization"):
		current_save_data["customization"] = {
			"p1_name": "Bruno",
			"p1_collar_color": [0.88, 0.22, 0.18, 1.0],
			"p1_tag_type": "Golden Bone",
			"p1_fur_tone": "Honey Gold",
			"p2_name": "Milo",
			"p2_collar_color": [0.18, 0.44, 0.88, 1.0],
			"p2_tag_type": "Brass Bell",
			"p2_fur_tone": "Classic Tricolor"
		}
	return current_save_data["customization"]
