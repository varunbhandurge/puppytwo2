class_name TestChapter1Backyard extends RefCounted

## Test Suite: Chapter 1 (The Backyard) Level Flow, Narrative Beats, Boss, and Collectibles

const Chapter1Scene = preload("res://src/chapters/chapter_1_backyard/chapter_1_backyard.tscn")

static func run_all_tests() -> Dictionary:
	var results: Dictionary = {
		"suite_name": "Chapter 1 (The Backyard) Full Production Flow",
		"passed": 0,
		"failed": 0,
		"tests": []
	}
	
	_test_chapter_initialization(results)
	_test_beat_progression(results)
	_test_fetch_minigame(results)
	_test_sprinkler_boss_mechanics(results)
	_test_back_gate_and_completion(results)
	_test_golden_bones_placements(results)
	_test_checkpoints_presence(results)
	
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

static func _test_chapter_initialization(results: Dictionary) -> void:
	var ch1 = Chapter1Scene.instantiate() as Chapter1Backyard
	ch1._ready()
	
	var pass_init = (ch1.current_beat == Chapter1Backyard.ChapterBeat.BEAT_1_DOGHOUSE_AWAKENING or ch1.current_beat == Chapter1Backyard.ChapterBeat.BEAT_2_SANDBOX_TRENCH)
	_record(results, "TC-CH1-001", "Chapter 1 Boot & Beat 1 Awakening", pass_init, "Chapter initializes in Doghouse Awakening beat")
	ch1.free()

static func _test_beat_progression(results: Dictionary) -> void:
	var ch1 = Chapter1Scene.instantiate() as Chapter1Backyard
	ch1._ready()
	
	ch1.advance_to_beat(Chapter1Backyard.ChapterBeat.BEAT_2_SANDBOX_TRENCH)
	var pass_b2 = (ch1.current_beat == Chapter1Backyard.ChapterBeat.BEAT_2_SANDBOX_TRENCH)
	
	ch1.advance_to_beat(Chapter1Backyard.ChapterBeat.BEAT_3_HOSE_LABYRINTH)
	var pass_b3 = (ch1.current_beat == Chapter1Backyard.ChapterBeat.BEAT_3_HOSE_LABYRINTH)
	
	ch1.advance_to_beat(Chapter1Backyard.ChapterBeat.BEAT_4_PICNIC_TABLE_ASCENT)
	var pass_b4 = (ch1.current_beat == Chapter1Backyard.ChapterBeat.BEAT_4_PICNIC_TABLE_ASCENT)
	
	_record(results, "TC-CH1-002", "Story Beats 2-4 Progression", pass_b2 and pass_b3 and pass_b4, "Transitions through Sandbox, Hose, and Picnic Table beats")
	ch1.free()

static func _test_fetch_minigame(results: Dictionary) -> void:
	var fetch = SqueakyBallFetchMiniGame.new()
	fetch._ready()
	
	fetch.start_minigame()
	var pass_start = fetch.is_active
	
	# Deposit 5 balls
	for i in range(5):
		fetch.deposit_ball()
		
	var pass_completed = (fetch.is_completed and not fetch.is_active and fetch.balls_deposited_count >= 5)
	_record(results, "TC-CH1-003", "Beat 5: Squeaky Ball Fetch Mini-Game", pass_start and pass_completed, "Fetch mini-game tracks ball deposits and completes")
	fetch.free()

static func _test_sprinkler_boss_mechanics(results: Dictionary) -> void:
	var sprinkler = BossMechanicalSprinkler.new()
	sprinkler._ready()
	
	var pass_p1_init = (sprinkler.current_phase == BossMechanicalSprinkler.SprinklerPhase.PHASE_1_ROTATING_JETS)
	
	# Phase 1: Deflector down & intake unbolted
	sprinkler.set_deflector_plate(true)
	sprinkler.unbolt_intake()
	var pass_p2 = (sprinkler.current_phase == BossMechanicalSprinkler.SprinklerPhase.PHASE_2_HYDRO_MORTAR)
	
	# Phase 2: Scented & dug
	sprinkler._on_puppy_scent_toggled(2, true)
	sprinkler._on_puppy_dug(1, Vector3.ZERO)
	var pass_p3 = (sprinkler.current_phase == BossMechanicalSprinkler.SprinklerPhase.PHASE_3_OVERCHARGED_SPIN)
	
	# Phase 3: Dual handles pulled
	sprinkler.set_handle_state(1, true)
	sprinkler.set_handle_state(2, true)
	var pass_defeat = (sprinkler.current_phase == BossMechanicalSprinkler.SprinklerPhase.DEFEATED)
	
	_record(results, "TC-CH1-004", "Beat 6: Sprinkler Boss 3-Phase Resolution", pass_p1_init and pass_p2 and pass_p3 and pass_defeat, "Sprinkler transitions across all 3 phases to defeat")
	sprinkler.free()

static func _test_back_gate_and_completion(results: Dictionary) -> void:
	var ch1 = Chapter1Scene.instantiate() as Chapter1Backyard
	ch1._ready()
	
	var tracker = {"completed": false}
	ch1.chapter_completed.connect(func():
		tracker["completed"] = true
	)
	
	ch1.advance_to_beat(Chapter1Backyard.ChapterBeat.BEAT_7_BACK_GATE_ESCAPE)
	
	var passed = (ch1.current_beat == Chapter1Backyard.ChapterBeat.CHAPTER_COMPLETED and tracker["completed"])
	_record(results, "TC-CH1-005", "Beat 7: Back Gate Unlock & Chapter Completion", passed, "Back gate opens and chapter completed signal emitted")
	ch1.free()

static func _test_golden_bones_placements(results: Dictionary) -> void:
	var ch1 = Chapter1Scene.instantiate() as Chapter1Backyard
	var bones_node = ch1.get_node_or_null("World/GoldenBones")
	var bone_count = 0
	if bones_node:
		bone_count = bones_node.get_child_count()
	
	_record(results, "TC-CH1-006", "Chapter 1 Golden Bones Allocation", bone_count == 8, "All 8 Golden Bone artifacts placed in Chapter 1")
	ch1.free()

static func _test_checkpoints_presence(results: Dictionary) -> void:
	var ch1 = Chapter1Scene.instantiate() as Chapter1Backyard
	var cps_node = ch1.get_node_or_null("World/Checkpoints")
	var cp_count = 0
	if cps_node:
		cp_count = cps_node.get_child_count()
		
	_record(results, "TC-CH1-007", "Chapter 1 Checkpoint Zones Distribution", cp_count == 4, "4 Checkpoints distributed across Chapter 1 beats")
	ch1.free()
