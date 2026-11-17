class_name TestFullCampaign extends RefCounted

## Master Test Suite: Full 8-Chapter Campaign, Bosses, Collectibles & Progression Flow

const Ch2Scene = preload("res://src/chapters/chapter_2_forgotten_garden/chapter_2_forgotten_garden.tscn")
const Ch3Scene = preload("res://src/chapters/chapter_3_giant_kitchen/chapter_3_giant_kitchen.tscn")
const Ch4Scene = preload("res://src/chapters/chapter_4_forest_of_giants/chapter_4_forest_of_giants.tscn")
const Ch5Scene = preload("res://src/chapters/chapter_5_riverlands/chapter_5_riverlands.tscn")
const Ch6Scene = preload("res://src/chapters/chapter_6_toy_factory/chapter_6_toy_factory.tscn")
const Ch7Scene = preload("res://src/chapters/chapter_7_dark_underground/chapter_7_dark_underground.tscn")
const Ch8Scene = preload("res://src/chapters/chapter_8_mountain_of_bones/chapter_8_mountain_of_bones.tscn")
const MenuScene = preload("res://src/ui/chapter_select_menu.tscn")

static func run_all_tests() -> Dictionary:
	var results: Dictionary = {
		"suite_name": "Full 8-Chapter Campaign Production & Progression",
		"passed": 0,
		"failed": 0,
		"tests": []
	}
	
	_test_campaign_metadata(results)
	_test_chapter_unlock_progression(results)
	_test_chapters_instantiation_and_beats(results)
	_test_all_8_bosses_resolution(results)
	_test_golden_bones_distribution_64(results)
	_test_chapter_select_menu_ui(results)
	
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

static func _test_campaign_metadata(results: Dictionary) -> void:
	var chapters = ChapterProgression.get_all_chapters()
	var pass_count = (chapters.size() == 9) # index 0..8
	var all_scenes_exist = true
	
	for ch in chapters:
		if not ResourceLoader.exists(ch["scene_path"]):
			all_scenes_exist = false
			break
			
	_record(results, "TC-CMP-001", "Campaign Metadata & Scene Integrity", pass_count and all_scenes_exist, "All 8 chapters + lab testbed exist and have valid scenes")

static func _test_chapter_unlock_progression(results: Dictionary) -> void:
	# Chapter 0 and 1 are unlocked by default
	var pass_default = ChapterProgression.is_chapter_unlocked(1)
	ChapterProgression.unlock_chapter(2)
	var pass_unlock_2 = ChapterProgression.is_chapter_unlocked(2)
	ChapterProgression.unlock_chapter(8)
	var pass_unlock_8 = ChapterProgression.is_chapter_unlocked(8)
	
	_record(results, "TC-CMP-002", "Chapter Progression Unlocks", pass_default and pass_unlock_2 and pass_unlock_8, "Chapters unlock dynamically and persist")

static func _test_chapters_instantiation_and_beats(results: Dictionary) -> void:
	var ch2 = Ch2Scene.instantiate() as Chapter2ForgottenGarden
	ch2._ready()
	ch2.advance_to_beat(Chapter2ForgottenGarden.ChapterBeat.BEAT_3_FERTILIZER_SCENT)
	var pass_ch2 = (ch2.current_beat == Chapter2ForgottenGarden.ChapterBeat.BEAT_3_FERTILIZER_SCENT)
	ch2.free()
	
	var ch3 = Ch3Scene.instantiate() as Chapter3GiantKitchen
	ch3._ready()
	ch3.advance_to_beat(Chapter3GiantKitchen.ChapterBeat.BEAT_4_REFRIGERATOR_ASCENT)
	var pass_ch3 = (ch3.current_beat == Chapter3GiantKitchen.ChapterBeat.BEAT_4_REFRIGERATOR_ASCENT)
	ch3.free()
	
	var ch4 = Ch4Scene.instantiate() as Chapter4ForestOfGiants
	ch4._ready()
	ch4.advance_to_beat(Chapter4ForestOfGiants.ChapterBeat.BEAT_4_FIREFLY_HOLLOW)
	var pass_ch4 = (ch4.current_beat == Chapter4ForestOfGiants.ChapterBeat.BEAT_4_FIREFLY_HOLLOW)
	ch4.free()
	
	var ch5 = Ch5Scene.instantiate() as Chapter5Riverlands
	ch5._ready()
	ch5.advance_to_beat(Chapter5Riverlands.ChapterBeat.BEAT_2_WHITEWATER_RAFT_RUN)
	var pass_ch5 = (ch5.current_beat == Chapter5Riverlands.ChapterBeat.BEAT_2_WHITEWATER_RAFT_RUN)
	ch5.free()
	
	var ch6 = Ch6Scene.instantiate() as Chapter6ToyFactory
	ch6._ready()
	ch6.advance_to_beat(Chapter6ToyFactory.ChapterBeat.BEAT_3_CLOCKWORK_TRAIN)
	var pass_ch6 = (ch6.current_beat == Chapter6ToyFactory.ChapterBeat.BEAT_3_CLOCKWORK_TRAIN)
	ch6.free()
	
	var ch7 = Ch7Scene.instantiate() as Chapter7DarkUnderground
	ch7._ready()
	ch7.advance_to_beat(Chapter7DarkUnderground.ChapterBeat.BEAT_2_CRYSTAL_CHIMES)
	var pass_ch7 = (ch7.current_beat == Chapter7DarkUnderground.ChapterBeat.BEAT_2_CRYSTAL_CHIMES)
	ch7.free()
	
	var ch8 = Ch8Scene.instantiate() as Chapter8MountainOfBones
	ch8._ready()
	ch8.advance_to_beat(Chapter8MountainOfBones.ChapterBeat.BEAT_6_REVELATION_AND_EPILOGUE)
	var pass_ch8 = (ch8.current_beat == Chapter8MountainOfBones.ChapterBeat.CHAPTER_COMPLETED)
	ch8.free()
	
	_record(results, "TC-CMP-003", "Chapters 2-8 Instantiation & Beat Advancement", pass_ch2 and pass_ch3 and pass_ch4 and pass_ch5 and pass_ch6 and pass_ch7 and pass_ch8, "All campaign chapter scenes instantiate and step through beats")

static func _test_all_8_bosses_resolution(results: Dictionary) -> void:
	# Boss 1: Sprinkler
	var b1 = BossMechanicalSprinkler.new()
	b1._ready()
	b1.set_deflector_plate(true)
	b1.unbolt_intake()
	b1._on_puppy_scent_toggled(2, true)
	b1._on_puppy_dug(1, Vector3.ZERO)
	b1.set_handle_state(1, true)
	b1.set_handle_state(2, true)
	var p1_pass = (b1.current_phase == BossMechanicalSprinkler.SprinklerPhase.DEFEATED)
	b1.free()
	
	# Boss 2: Garden Cat
	var b2 = BossGardenCat.new()
	b2._ready()
	b2._on_puppy_barked(1, Vector3.ZERO, 5.0)
	b2.hit_cat()
	b2._on_puppy_barked(1, Vector3.ZERO, 5.0)
	b2.hit_cat()
	b2._on_puppy_barked(1, Vector3.ZERO, 5.0)
	b2.hit_cat()
	var p2_pass = (b2.current_phase == BossGardenCat.BossPhase.DEFEATED)
	b2.free()
	
	# Boss 3: Appliance Golem
	var b3 = BossApplianceGolem.new()
	b3._ready()
	b3.brace_frying_pan(true)
	b3.vault_power_button()
	b3.unplug_cord()
	b3.push_into_soap()
	b3.place_wet_sponge()
	var p3_pass = (b3.current_phase == BossApplianceGolem.GolemPhase.DEFEATED)
	b3.free()
	
	# Boss 4: Corvus Crow
	var b4 = BossCorvusCrow.new()
	b4._ready()
	b4.return_pinecone()
	b4.return_pinecone()
	b4.anchor_root_tether()
	b4._on_puppy_barked(1, Vector3.ZERO, 5.0)
	var p4_pass = (b4.current_phase == BossCorvusCrow.CrowPhase.DEFEATED)
	b4.free()
	
	# Boss 5: River Bullfrog
	var b5 = BossRiverBullfrog.new()
	b5._ready()
	b5.bite_extended_tongue()
	b5.clear_tidal_wave()
	b5.clear_tidal_wave()
	b5.crank_sluice(1)
	b5.crank_sluice(2)
	var p5_pass = (b5.current_phase == BossRiverBullfrog.FrogPhase.DEFEATED)
	b5.free()
	
	# Boss 6: Clockwork Titan
	var b6 = BossClockworkTitan.new()
	b6._ready()
	b6.lure_hammer_to_conveyor()
	b6._on_puppy_barked(1, Vector3.ZERO, 5.0)
	b6.disarm_leg_joint()
	b6.jam_drive_girder()
	b6.pull_head_key()
	var p6_pass = (b6.current_phase == BossClockworkTitan.TitanPhase.DEFEATED)
	b6.free()
	
	# Boss 7: Mole King
	var b7 = BossMoleKing.new()
	b7._ready()
	b7._on_puppy_scent_toggled(2, true)
	b7._on_puppy_dug(1, Vector3.ZERO)
	b7.survive_stalactite_tremor()
	b7.survive_stalactite_tremor()
	b7._on_puppy_barked(1, Vector3.ZERO, 5.0)
	b7.knock_bronze_crown()
	var p7_pass = (b7.current_phase == BossMoleKing.MolePhase.DEFEATED)
	b7.free()
	
	# Boss 8: Mountain Guardian
	var b8 = BossMountainGuardian.new()
	b8._ready()
	b8.huddle_together(true)
	b8.stabilize_pillar()
	b8.stabilize_pillar()
	b8.offer_wish_to_partner(1)
	b8.offer_wish_to_partner(2)
	var p8_pass = (b8.current_phase == BossMountainGuardian.GuardianPhase.DEFEATED)
	b8.free()
	
	var all_bosses_pass = p1_pass and p2_pass and p3_pass and p4_pass and p5_pass and p6_pass and p7_pass and p8_pass
	_record(results, "TC-CMP-004", "All 8 Boss Encounters Full Resolution", all_bosses_pass, "All 8 unique bosses progress through 3 cooperative phases to defeat")

static func _test_golden_bones_distribution_64(results: Dictionary) -> void:
	var scenes = [
		preload("res://src/chapters/chapter_1_backyard/chapter_1_backyard.tscn"),
		Ch2Scene, Ch3Scene, Ch4Scene, Ch5Scene, Ch6Scene, Ch7Scene, Ch8Scene
	]
	
	var total_bones = 0
	var all_have_8 = true
	
	for s in scenes:
		var node = s.instantiate()
		var bones_node = node.get_node_or_null("World/GoldenBones")
		if bones_node:
			var cnt = bones_node.get_child_count()
			if cnt != 8:
				all_have_8 = false
			total_bones += cnt
		else:
			all_have_8 = false
		node.free()
		
	var pass_64 = (total_bones == 64 and all_have_8)
	_record(results, "TC-CMP-005", "64 Golden Bones Allocation (8 per Chapter)", pass_64, "All 8 chapters contain exactly 8 Golden Bone pickups totaling 64")

static func _test_chapter_select_menu_ui(results: Dictionary) -> void:
	var menu = MenuScene.instantiate() as ChapterSelectMenu
	menu._ready()
	
	var list = menu.get_node_or_null("MarginContainer/VBoxContainer/ScrollContainer/ChapterList")
	var pass_buttons = (list != null and list.get_child_count() == 9)
	
	var prev_vertical = GameManager.split_is_vertical
	menu._on_split_toggle_pressed()
	var pass_toggle = (GameManager.split_is_vertical != prev_vertical)
	# Restore
	menu._on_split_toggle_pressed()
	
	_record(results, "TC-CMP-006", "Chapter Select Menu UI & Interaction", pass_buttons and pass_toggle, "Chapter Select lists all chapters with interactive split-screen controls")
	menu.free()
