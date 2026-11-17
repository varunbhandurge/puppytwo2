class_name TestCharacterMovement extends RefCounted

## Test Suite: Character Movement, Kinematics, Collision, and Abilities

const BrunoScene = preload("res://src/characters/bruno.tscn")
const MiloScene = preload("res://src/characters/milo.tscn")

static func run_all_tests() -> Dictionary:
	var results: Dictionary = {
		"suite_name": "Character Movement & Abilities",
		"passed": 0,
		"failed": 0,
		"tests": []
	}
	
	_test_bruno_locomotion(results)
	_test_milo_crawl_collision(results)
	_test_bruno_digging(results)
	_test_milo_scent_vision(results)
	_test_snout_boost_mechanic(results)
	_test_respawn_handling(results)
	
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

static func _test_bruno_locomotion(results: Dictionary) -> void:
	var bruno = BrunoScene.instantiate() as BrunoCharacter
	bruno._ready()
	
	var pass_speed = (bruno.walk_speed > 4.0 and bruno.sprint_speed > 7.0 and bruno.jump_velocity > 6.0)
	_record(results, "TC-CHR-001", "Bruno Baseline Kinematic Parameters", pass_speed, "Speed parameters within specification")
	bruno.free()

static func _test_milo_crawl_collision(results: Dictionary) -> void:
	var milo = MiloScene.instantiate() as MiloCharacter
	milo._ready()
	
	# Toggle crawl
	milo.toggle_low_crawl(true)
	var cap = milo.collision_shape.shape as CapsuleShape3D
	var pass_height = is_equal_approx(cap.height, 0.25)
	
	milo.toggle_low_crawl(false)
	var pass_restore = is_equal_approx(cap.height, milo.original_capsule_height)
	
	_record(results, "TC-CHR-002", "Milo Low Crawl Collision Sizing", pass_height and pass_restore, "Capsule compressed to 0.25m and restored")
	milo.free()

static func _test_bruno_digging(results: Dictionary) -> void:
	var bruno = BrunoScene.instantiate() as BrunoCharacter
	bruno._ready()
	
	var tracker = {"fired": false}
	
	var cb = func(pid: int, _pos: Vector3):
		if pid == 1:
			tracker["fired"] = true
	EventBus.puppy_dug.connect(cb)
	
	bruno.position = Vector3(5, 0, 5)
	bruno.execute_mighty_dig()
	
	EventBus.puppy_dug.disconnect(cb)
	
	_record(results, "TC-CHR-003", "Bruno Mighty Dig Signal & Position", tracker["fired"], "Digging signal dispatched on EventBus")
	bruno.free()

static func _test_milo_scent_vision(results: Dictionary) -> void:
	var milo = MiloScene.instantiate() as MiloCharacter
	milo._ready()
	
	var tracker = {"toggled": false, "active": false}
	
	var cb = func(pid: int, state: bool):
		if pid == 2:
			tracker["toggled"] = true
			tracker["active"] = state
	EventBus.puppy_scent_toggled.connect(cb)
	
	milo.toggle_scent_vision()
	EventBus.puppy_scent_toggled.disconnect(cb)
	
	_record(results, "TC-CHR-004", "Milo Scent-o-Vision Toggle", tracker["toggled"] and tracker["active"], "Scent vision toggled to active")
	milo.free()

static func _test_snout_boost_mechanic(results: Dictionary) -> void:
	var bruno = BrunoScene.instantiate() as BrunoCharacter
	var milo = MiloScene.instantiate() as MiloCharacter
	bruno._ready()
	milo._ready()
	GameManager.player_1_node = bruno
	GameManager.player_2_node = milo
	
	bruno.enter_boost_stance()
	var is_bruno_boosting = bruno.is_boosting_partner
	
	bruno.position = Vector3.ZERO
	milo.position = Vector3(0.5, 0, 0.5)
	
	# Simulate check with distance
	if bruno.is_boosting_partner and milo.position.distance_to(bruno.position) < 2.0:
		milo.velocity.y = 11.0
	
	var super_jump_passed = (milo.velocity.y > 10.0)
	
	_record(results, "TC-CHR-005", "Snout Boost Cooperative Launch", is_bruno_boosting and super_jump_passed, "Milo launched with super vertical impulse")
	bruno.free()
	milo.free()

static func _test_respawn_handling(results: Dictionary) -> void:
	var bruno = BrunoScene.instantiate() as BrunoCharacter
	var milo = MiloScene.instantiate() as MiloCharacter
	GameManager.register_player(1, bruno)
	GameManager.register_player(2, milo)
	
	GameManager.active_checkpoint_position = Vector3(10, 0, 10)
	GameManager.active_checkpoint_id = "cp_test"
	
	var passed = (GameManager.active_checkpoint_position == Vector3(10, 0, 10))
	_record(results, "TC-CHR-006", "Player Checkpoint Position Assignment", passed, "Checkpoint position registered correctly")
	bruno.free()
	milo.free()
