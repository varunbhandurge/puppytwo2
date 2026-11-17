class_name TestBoss extends RefCounted

## Test Suite: Boss AI Architecture, Telegraphing, and Multi-Phase Transitions

static func run_all_tests() -> Dictionary:
	var results: Dictionary = {
		"suite_name": "Boss AI & Combat Framework",
		"passed": 0,
		"failed": 0,
		"tests": []
	}
	
	_test_boss_initialization(results)
	_test_boss_bark_vulnerability(results)
	_test_boss_phase_progression(results)
	
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

static func _test_boss_initialization(results: Dictionary) -> void:
	var boss = BossGardenCat.new()
	boss._ready()
	
	var passed = (boss.current_phase == BossGardenCat.BossPhase.PHASE_1_POUNCE and boss.current_health == 3)
	_record(results, "TC-BOS-001", "Boss Initialization & Phase 1 Health", passed, "Whiskers initializes in Phase 1 with 3 health")
	boss.free()

static func _test_boss_bark_vulnerability(results: Dictionary) -> void:
	var boss = BossGardenCat.new()
	boss._ready()
	
	boss.trigger_vulnerability()
	var pass_vuln = boss.is_vulnerable
	
	_record(results, "TC-BOS-002", "Bark Counter Vulnerability State", pass_vuln, "Whiskers becomes vulnerable after bark deflection")
	boss.free()

static func _test_boss_phase_progression(results: Dictionary) -> void:
	var boss = BossGardenCat.new()
	boss._ready()
	
	# Hit 1 -> Phase 2
	boss.apply_coop_hit()
	var pass_p2 = (boss.current_phase == BossGardenCat.BossPhase.PHASE_2_RAFTERS and boss.current_health == 2)
	
	# Hit 2 -> Phase 3
	boss.apply_coop_hit()
	var pass_p3 = (boss.current_phase == BossGardenCat.BossPhase.PHASE_3_YARN_CHASE and boss.current_health == 1)
	
	# Hit 3 -> Defeated
	boss.apply_coop_hit()
	var pass_defeated = (boss.current_phase == BossGardenCat.BossPhase.DEFEATED and boss.current_health == 0)
	
	_record(results, "TC-BOS-003", "3-Phase Boss Transition to Defeat", pass_p2 and pass_p3 and pass_defeated, "All 3 boss phases and defeat resolved correctly")
	boss.free()
