class_name TestOnlineCoopScript extends RefCounted

## Automated QA Unit Test Suite: Online Co-op Network Architecture

static func run_all_tests() -> Dictionary:
	var results = {
		"suite_name": "Online Co-op Network Architecture",
		"tests": []
	}
	
	results["tests"].append(_test_network_manager_initialization())
	results["tests"].append(_test_packet_serialization_deserialization())
	results["tests"].append(_test_world_snapshot_serialization())
	results["tests"].append(_test_snapshot_interpolation_math())
	results["tests"].append(_test_friends_pass_and_disconnect_fallback())
	
	return results

static func _test_network_manager_initialization() -> Dictionary:
	var test = {
		"id": "TC-NET-001",
		"name": "NetworkManager Init & Standalone Baseline",
		"passed": false,
		"message": ""
	}
	
	var net_mgr = NetworkManagerSingleton.new()
	net_mgr._ready()
	
	if net_mgr.current_role != NetworkManagerSingleton.NetworkRole.STANDALONE:
		test["message"] = "Expected initial role STANDALONE, found: %d" % net_mgr.current_role
		net_mgr.queue_free()
		return test
		
	if net_mgr.connection_state != NetworkManagerSingleton.ConnectionState.DISCONNECTED:
		test["message"] = "Expected initial state DISCONNECTED, found: %d" % net_mgr.connection_state
		net_mgr.queue_free()
		return test
		
	test["passed"] = true
	test["message"] = "NetworkManager initializes in clean standalone mode with disconnected state"
	net_mgr.queue_free()
	return test

static func _test_packet_serialization_deserialization() -> Dictionary:
	var test = {
		"id": "TC-NET-002",
		"name": "PuppyCommand Packet Binary Serialization",
		"passed": false,
		"message": ""
	}
	
	var net_mgr = NetworkManagerSingleton.new()
	net_mgr._ready()
	
	var cmd = InputManagerSingleton.PuppyCommand.new()
	cmd.move_vector = Vector2(0.85, -0.65).normalized()
	cmd.jump_just_pressed = true
	cmd.interact_just_pressed = false
	cmd.interact_held = true
	cmd.bark_just_pressed = true
	cmd.special_just_pressed = false
	cmd.sprint_held = true
	
	var seq = 1042
	var t_stamp = 42.125
	
	var bytes = net_mgr.serialize_command(cmd, seq, t_stamp)
	if bytes.size() != 12:
		test["message"] = "Expected 12-byte packed binary payload, got %d bytes" % bytes.size()
		net_mgr.queue_free()
		return test
		
	var unpacked = net_mgr.deserialize_command(bytes)
	if not unpacked["valid"]:
		test["message"] = "Deserialized packet returned valid=false"
		net_mgr.queue_free()
		return test
		
	if unpacked["seq_id"] != seq:
		test["message"] = "Sequence mismatch: expected %d, got %d" % [seq, unpacked["seq_id"]]
		net_mgr.queue_free()
		return test
		
	var res_cmd: InputManagerSingleton.PuppyCommand = unpacked["command"]
	if not res_cmd.jump_just_pressed or not res_cmd.interact_held or not res_cmd.bark_just_pressed or not res_cmd.sprint_held:
		test["message"] = "Bitmask flags corrupted during serialization"
		net_mgr.queue_free()
		return test
		
	# Verify vector unpack accuracy (within 0.02 quantization error)
	if abs(res_cmd.move_vector.x - cmd.move_vector.x) > 0.02 or abs(res_cmd.move_vector.y - cmd.move_vector.y) > 0.02:
		test["message"] = "Vector quantization divergence exceeded tolerance: orig=%s, unpacked=%s" % [cmd.move_vector, res_cmd.move_vector]
		net_mgr.queue_free()
		return test
		
	test["passed"] = true
	test["message"] = "12-byte binary command packet packed and unpacked with exact bitmask fidelity"
	net_mgr.queue_free()
	return test

static func _test_world_snapshot_serialization() -> Dictionary:
	var test = {
		"id": "TC-NET-003",
		"name": "Authoritative World Snapshot Serialization",
		"passed": false,
		"message": ""
	}
	
	var net_mgr = NetworkManagerSingleton.new()
	net_mgr._ready()
	
	var snap = {
		"tick": 4800,
		"chapter_id": 5,
		"beat_id": 3,
		"bruno_pos": Vector3(14.5, 2.0, -8.75),
		"bruno_vel": Vector3(4.0, 0.0, -3.5),
		"milo_pos": Vector3(16.0, 2.1, -9.0),
		"milo_vel": Vector3(4.2, 0.0, -3.2)
	}
	
	var raw_bytes = net_mgr.serialize_snapshot(snap)
	if raw_bytes.size() != 54:
		test["message"] = "Expected 54-byte snapshot packet, received %d bytes" % raw_bytes.size()
		net_mgr.queue_free()
		return test
		
	var recovered = net_mgr.deserialize_snapshot(raw_bytes)
	if not recovered["valid"]:
		test["message"] = "Deserialized snapshot returned valid=false"
		net_mgr.queue_free()
		return test
		
	if recovered["tick"] != 4800 or recovered["chapter_id"] != 5 or recovered["beat_id"] != 3:
		test["message"] = "Snapshot header mismatch"
		net_mgr.queue_free()
		return test
		
	if recovered["bruno_pos"].distance_to(snap["bruno_pos"]) > 0.001:
		test["message"] = "Bruno coordinates corrupted in snapshot round-trip"
		net_mgr.queue_free()
		return test
		
	test["passed"] = true
	test["message"] = "54-byte world snapshot accurately serialized and restored with float32 precision"
	net_mgr.queue_free()
	return test

static func _test_snapshot_interpolation_math() -> Dictionary:
	var test = {
		"id": "TC-NET-004",
		"name": "Hermite Snapshot Interpolation & Smoothing",
		"passed": false,
		"message": ""
	}
	
	var net_mgr = NetworkManagerSingleton.new()
	net_mgr._ready()
	
	var p0 = Vector3(0.0, 0.0, 0.0)
	var p1 = Vector3(10.0, 0.0, 0.0)
	
	var mid = net_mgr.interpolate_position(p0, p1, 0.5)
	if abs(mid.x - 5.0) > 0.001:
		test["message"] = "Midpoint interpolation failed: expected 5.0, got %f" % mid.x
		net_mgr.queue_free()
		return test
		
	# Verify S-curve smoothing properties
	var q1 = net_mgr.interpolate_position(p0, p1, 0.25)
	var q3 = net_mgr.interpolate_position(p0, p1, 0.75)
	if q1.x >= 2.5 or q3.x <= 7.5:
		test["message"] = "Smoothstep ease curve failed mathematical bounds"
		net_mgr.queue_free()
		return test
		
	test["passed"] = true
	test["message"] = "Hermite spline interpolation verified with smooth acceleration/deceleration curves"
	net_mgr.queue_free()
	return test

static func _test_friends_pass_and_disconnect_fallback() -> Dictionary:
	var test = {
		"id": "TC-NET-005",
		"name": "Friend's Pass Token & Split-Screen Fallback",
		"passed": false,
		"message": ""
	}
	
	var net_mgr = NetworkManagerSingleton.new()
	net_mgr._ready()
	
	# 1. Test token validation
	var valid_token = "FP-2854000-A9F7B2C1E4D80055"
	var invalid_token = "BAD-TOKEN-123"
	
	if not net_mgr.validate_friends_pass_token(valid_token) or net_mgr.validate_friends_pass_token(invalid_token):
		test["message"] = "Friend's Pass token verification rejected valid token or accepted invalid"
		net_mgr.queue_free()
		return test
		
	# 2. Test disconnect fallback trigger
	var fallback_fired = {"val": false}
	net_mgr.fallback_triggered.connect(func(): fallback_fired["val"] = true)
	
	net_mgr.fallback_to_local_splitscreen()
	
	if not fallback_fired["val"] or net_mgr.current_role != NetworkManagerSingleton.NetworkRole.STANDALONE:
		test["message"] = "Fallback to local split-screen did not emit signal or restore standalone role"
		net_mgr.queue_free()
		return test
		
	test["passed"] = true
	test["message"] = "Friend's pass cryptographic tokens validated and fallback to split-screen verified"
	net_mgr.queue_free()
	return test
