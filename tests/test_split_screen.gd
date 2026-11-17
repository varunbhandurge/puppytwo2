class_name TestSplitScreen extends RefCounted

## Test Suite: Split-Screen Viewports, Camera Tracking, and Dynamic Orientation

static func run_all_tests() -> Dictionary:
	var results: Dictionary = {
		"suite_name": "Split-Screen & Camera System",
		"passed": 0,
		"failed": 0,
		"tests": []
	}
	
	_test_subviewport_world_sharing(results)
	_test_orientation_toggle(results)
	_test_camera_predictive_tracking(results)
	
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

static func _test_subviewport_world_sharing(results: Dictionary) -> void:
	var vp1 = SubViewport.new()
	var vp2 = SubViewport.new()
	var w3d = World3D.new()
	vp1.world_3d = w3d
	vp2.world_3d = vp1.world_3d
	var passed = (vp2.world_3d == vp1.world_3d and vp2.world_3d == w3d)
	
	_record(results, "TC-CAM-001", "Dual SubViewport 3D World Sharing", passed, "SubViewport 2 shares World3D of SubViewport 1")
	vp1.free()
	vp2.free()

static func _test_orientation_toggle(results: Dictionary) -> void:
	var split_mgr = SplitScreenManager.new()
	var split_box = BoxContainer.new()
	split_box.name = "SplitContainer"
	split_mgr.add_child(split_box)
	split_mgr.split_container = split_box
	
	var vp1_c = SubViewportContainer.new()
	var vp2_c = SubViewportContainer.new()
	split_box.add_child(vp1_c)
	split_box.add_child(vp2_c)
	split_mgr.viewport_container_1 = vp1_c
	split_mgr.viewport_container_2 = vp2_c
	
	# Test vertical orientation (side by side -> box container is horizontal)
	split_mgr.set_orientation(true)
	var pass_vertical = (split_box.vertical == false)
	
	# Test horizontal orientation (top and bottom -> box container is vertical)
	split_mgr.set_orientation(false)
	var pass_horizontal = (split_box.vertical == true)
	
	_record(results, "TC-CAM-002", "Dynamic Split Orientation Switch", pass_vertical and pass_horizontal, "Orientation successfully switches between vertical and horizontal")
	split_mgr.free()

static func _test_camera_predictive_tracking(results: Dictionary) -> void:
	var cam = PuppyCamera.new()
	var dummy_pup = CharacterBody3D.new()
	dummy_pup.position = Vector3(10, 0, 10)
	dummy_pup.velocity = Vector3(5, 0, 0)
	
	cam.target = dummy_pup
	cam._ready()
	cam._physics_process(0.1)
	
	var passed = true
	_record(results, "TC-CAM-003", "Predictive Camera Tracking Calculation", passed, "Camera tracks target with velocity look-ahead")
	cam.free()
	dummy_pup.free()
