class_name ChapterProgression extends RefCounted

## Chapter Progression Manager
## Coordinates campaign progress across all 8 chapters, level paths, unlocks, and transitions.

const CHAPTERS: Array[Dictionary] = [
	{
		"index": 0,
		"id": "ch0_testbed",
		"title": "Puppy Co-op Lab",
		"subtitle": "Vertical Slice & Movement Testbed",
		"scene_path": "res://src/testbed/puppy_coop_lab.tscn",
		"boss": "Whiskers the Menace",
		"bones_count": 8
	},
	{
		"index": 1,
		"id": "ch1_backyard",
		"title": "Chapter 1: The Backyard",
		"subtitle": "Waking Up & Sandbox Excavation",
		"scene_path": "res://src/chapters/chapter_1_backyard/chapter_1_backyard.tscn",
		"boss": "Mechanical Sprinkler",
		"bones_count": 8
	},
	{
		"index": 2,
		"id": "ch2_garden",
		"title": "Chapter 2: The Forgotten Garden",
		"subtitle": "Overgrown Briars & The Ancient Greenhouse",
		"scene_path": "res://src/chapters/chapter_2_forgotten_garden/chapter_2_forgotten_garden.tscn",
		"boss": "Whiskers the Menace",
		"bones_count": 8
	},
	{
		"index": 3,
		"id": "ch3_kitchen",
		"title": "Chapter 3: The Giant Kitchen",
		"subtitle": "Linoleum Valleys & Towering Counters",
		"scene_path": "res://src/chapters/chapter_3_giant_kitchen/chapter_3_giant_kitchen.tscn",
		"boss": "Appliance Golem",
		"bones_count": 8
	},
	{
		"index": 4,
		"id": "ch4_forest",
		"title": "Chapter 4: The Forest of Giants",
		"subtitle": "Mossy Redwoods & High Canopy Ropes",
		"scene_path": "res://src/chapters/chapter_4_forest_of_giants/chapter_4_forest_of_giants.tscn",
		"boss": "Corvus the Crow King",
		"bones_count": 8
	},
	{
		"index": 5,
		"id": "ch5_riverlands",
		"title": "Chapter 5: The Riverlands",
		"subtitle": "Beaver Dam Sluice & Whitewater Rapids",
		"scene_path": "res://src/chapters/chapter_5_riverlands/chapter_5_riverlands.tscn",
		"boss": "Grand River Bullfrog",
		"bones_count": 8
	},
	{
		"index": 6,
		"id": "ch6_toy_factory",
		"title": "Chapter 6: The Toy Factory",
		"subtitle": "Conveyor Belts & Clockwork Contraptions",
		"scene_path": "res://src/chapters/chapter_6_toy_factory/chapter_6_toy_factory.tscn",
		"boss": "Clockwork Titan",
		"bones_count": 8
	},
	{
		"index": 7,
		"id": "ch7_dark_underground",
		"title": "Chapter 7: The Dark Underground",
		"subtitle": "Bioluminescent Caverns & Minecart Shafts",
		"scene_path": "res://src/chapters/chapter_7_dark_underground/chapter_7_dark_underground.tscn",
		"boss": "The Mole King",
		"bones_count": 8
	},
	{
		"index": 8,
		"id": "ch8_mountain_of_bones",
		"title": "Chapter 8: The Mountain of Bones",
		"subtitle": "Frozen Summit & The Legendary Aura Bone",
		"scene_path": "res://src/chapters/chapter_8_mountain_of_bones/chapter_8_mountain_of_bones.tscn",
		"boss": "The Mountain Guardian",
		"bones_count": 8
	}
]

static func get_all_chapters() -> Array[Dictionary]:
	return CHAPTERS

static func get_chapter_metadata(index: int) -> Dictionary:
	for ch in CHAPTERS:
		if ch["index"] == index:
			return ch
	return {}

static func is_chapter_unlocked(index: int) -> bool:
	if index <= 1:
		return true # Chapter 0 and 1 always unlocked
	var unlocked: Array = SaveManager.current_save_data.get("unlocked_chapters", [0, 1])
	return index in unlocked

static func unlock_chapter(index: int) -> void:
	var unlocked: Array = SaveManager.current_save_data.get("unlocked_chapters", [0, 1])
	if not (index in unlocked):
		unlocked.append(index)
		SaveManager.current_save_data["unlocked_chapters"] = unlocked
		SaveManager.save_to_disk()
		EventBus.notification_displayed.emit("NEW CHAPTER UNLOCKED!", get_chapter_metadata(index).get("title", "Chapter %d" % index), 4.0)

static func load_chapter(tree: SceneTree, index: int) -> bool:
	var meta = get_chapter_metadata(index)
	if meta.is_empty():
		push_error("Invalid chapter index requested: %d" % index)
		return false
	
	var path: String = meta["scene_path"]
	if not ResourceLoader.exists(path):
		push_error("Chapter scene not found at path: %s" % path)
		return false
	
	GameManager.current_chapter_index = index
	SaveManager.current_save_data["chapter_index"] = index
	SaveManager.save_to_disk()
	
	if tree:
		var err = tree.change_scene_to_file(path)
		return err == OK
	return true

static func advance_to_next_chapter(tree: SceneTree) -> bool:
	var next_index = GameManager.current_chapter_index + 1
	if next_index > 8:
		# Campaign complete
		return false
	unlock_chapter(next_index)
	return load_chapter(tree, next_index)
