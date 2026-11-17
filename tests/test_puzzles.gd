class_name TestPuzzles extends RefCounted

## Test Suite: Cooperative Puzzles, Stage Progressions, and State Integrity

static func run_all_tests() -> Dictionary:
	var results: Dictionary = {
		"suite_name": "Cooperative Puzzle Framework",
		"passed": 0,
		"failed": 0,
		"tests": []
	}
	
	_test_puzzle_base_lifecycle(results)
	_test_puzzle_1_sunken_crate(results)
	_test_puzzle_2_scent_maze(results)
	_test_puzzle_3_sprinkler_timing(results)
	
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

static func _test_puzzle_base_lifecycle(results: Dictionary) -> void:
	var puz = PuzzleBase.new()
	puz.puzzle_id = "test_puz"
	puz.total_stages = 2
	puz._ready()
	
	var pass_init = (puz.current_state == PuzzleBase.PuzzleState.ACTIVE and puz.current_stage == 0)
	
	puz.complete_stage(1)
	var pass_stage1 = (puz.current_stage == 1)
	
	puz.complete_stage(2)
	var pass_solved = (puz.current_state == PuzzleBase.PuzzleState.SOLVED and puz.current_stage == 2)
	
	_record(results, "TC-PUZ-001", "Puzzle State Machine Stage Progression", pass_init and pass_stage1 and pass_solved, "Transitions from ACTIVE to STAGE_SUCCESS to SOLVED")
	puz.free()

static func _test_puzzle_1_sunken_crate(results: Dictionary) -> void:
	var puz1 = Puzzle1SunkenCrate.new()
	puz1._ready()
	
	# Simulate Stage 1: Dig completed
	puz1.complete_stage(1)
	# Simulate Stage 2: Seesaw counterweight
	puz1.complete_stage(2)
	# Simulate Stage 3: Milo unlatches lid
	puz1.complete_stage(3)
	
	var passed = (puz1.current_state == PuzzleBase.PuzzleState.SOLVED)
	_record(results, "TC-PUZ-002", "Puzzle 1 (Sunken Crate) Full Resolution", passed, "Sunken crate completes all 3 stages successfully")
	puz1.free()

static func _test_puzzle_2_scent_maze(results: Dictionary) -> void:
	var puz2 = Puzzle2ScentMaze.new()
	puz2._ready()
	
	# Simulate Stage 1: Scent activated
	puz2.complete_stage(1)
	# Simulate Stage 2: Crawl tunnel
	puz2.complete_stage(2)
	# Simulate Stage 3: Lever
	puz2.complete_stage(3)
	
	var passed = (puz2.current_state == PuzzleBase.PuzzleState.SOLVED)
	_record(results, "TC-PUZ-003", "Puzzle 2 (Scent Maze) Full Resolution", passed, "Bramble maze resolved through scent and crawl sequence")
	puz2.free()

static func _test_puzzle_3_sprinkler_timing(results: Dictionary) -> void:
	var puz3 = Puzzle3SprinklerBridge.new()
	puz3._ready()
	
	# Step on pedal
	puz3.open_timing_window()
	var pass_window = puz3.is_window_open
	
	# Simulate timeout
	puz3._on_window_timeout()
	var pass_reset = (puz3.is_window_open == false and puz3.current_stage == 0)
	
	_record(results, "TC-PUZ-004", "Puzzle 3 Timing Window & Failure Reset", pass_window and pass_reset, "Window opens then resets on timeout safely")
	puz3.free()
