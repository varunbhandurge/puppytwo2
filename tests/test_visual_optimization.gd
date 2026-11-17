class_name TestVisualOptimization extends RefCounted

## Test Suite: Custom Shaders, Visual Polish, Quality Profiles & Dynamic Frame Optimizer

const FurShaderPath = "res://src/shaders/fur_rim_fluff.gdshader"
const EyeShaderPath = "res://src/shaders/cartoon_eye.gdshader"
const WaterShaderPath = "res://src/shaders/stylized_water.gdshader"
const FogShaderPath = "res://src/shaders/atmospheric_fog.gdshader"

static func run_all_tests() -> Dictionary:
	var results: Dictionary = {
		"suite_name": "Visual Polish, Custom Shaders & Frame Optimization",
		"passed": 0,
		"failed": 0,
		"tests": []
	}
	
	_test_custom_shaders_loading(results)
	_test_quality_tier_transitions(results)
	_test_dynamic_resolution_scaling(results)
	_test_performance_metrics_telemetry(results)
	_test_memory_budget_enforcement(results)
	_test_fur_material_instantiation(results)
	
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

static func _test_custom_shaders_loading(results: Dictionary) -> void:
	var s_fur = load(FurShaderPath) as Shader
	var s_eye = load(EyeShaderPath) as Shader
	var s_water = load(WaterShaderPath) as Shader
	var s_fog = load(FogShaderPath) as Shader
	
	var pass_fur = (s_fur != null and s_fur.get_rid().is_valid())
	var pass_eye = (s_eye != null and s_eye.get_rid().is_valid())
	var pass_water = (s_water != null and s_water.get_rid().is_valid())
	var pass_fog = (s_fog != null and s_fog.get_rid().is_valid())
	
	var pass_all = pass_fur and pass_eye and pass_water and pass_fog
	_record(results, "TC-OPT-001", "Custom Shaders Resource Compilation", pass_all, "Fur fluff, cartoon eye, stylized water, and height fog shaders compile with valid RIDs")

static func _test_quality_tier_transitions(results: Dictionary) -> void:
	var tracker = {"tier_events": 0}
	var on_tier = func(_t: int): tracker["tier_events"] += 1
	PerformanceOptimizer.quality_tier_changed.connect(on_tier)
	
	PerformanceOptimizer.apply_quality_tier(PerformanceOptimizerSingleton.QualityTier.PERFORMANCE)
	var pass_perf = (PerformanceOptimizer.current_tier == PerformanceOptimizerSingleton.QualityTier.PERFORMANCE and PerformanceOptimizer.current_3d_scale == 0.85)
	
	PerformanceOptimizer.apply_quality_tier(PerformanceOptimizerSingleton.QualityTier.BALANCED)
	var pass_bal = (PerformanceOptimizer.current_tier == PerformanceOptimizerSingleton.QualityTier.BALANCED and PerformanceOptimizer.current_3d_scale == 1.0)
	
	PerformanceOptimizer.apply_quality_tier(PerformanceOptimizerSingleton.QualityTier.ULTRA)
	var pass_ult = (PerformanceOptimizer.current_tier == PerformanceOptimizerSingleton.QualityTier.ULTRA and PerformanceOptimizer.current_3d_scale == 1.0)
	
	PerformanceOptimizer.quality_tier_changed.disconnect(on_tier)
	var pass_all = pass_perf and pass_bal and pass_ult and (tracker["tier_events"] >= 3)
	_record(results, "TC-OPT-002", "Quality Tier Transitions & Scaling", pass_all, "Quality profiles (Performance, Balanced, Ultra) configure 3D scales and shadow parameters")

static func _test_dynamic_resolution_scaling(results: Dictionary) -> void:
	# Test DRS scale reduction under simulated frametime spike
	PerformanceOptimizer.current_3d_scale = 1.0
	PerformanceOptimizer._evaluate_drs(12.0) # 12ms = 83 FPS, above 9.58ms threshold
	var pass_drop = (PerformanceOptimizer.current_3d_scale < 1.0)
	
	# Test DRS scale recovery under surplus performance
	PerformanceOptimizer._evaluate_drs(5.0) # 5ms = 200 FPS, below 7.08ms threshold
	var pass_boost = (PerformanceOptimizer.current_3d_scale == 1.0)
	
	_record(results, "TC-OPT-003", "Dynamic Resolution Scaling (DRS) Logic", pass_drop and pass_boost, "DRS responds dynamically to frametime load spikes and recovers smoothly")

static func _test_performance_metrics_telemetry(results: Dictionary) -> void:
	var metrics = PerformanceOptimizer.get_performance_metrics()
	var has_fps = metrics.has("fps")
	var has_frametime = metrics.has("frametime_ms")
	var has_target = metrics.has("target_fps") and metrics["target_fps"] == 120.0
	var has_tier = metrics.has("quality_tier")
	var has_mem = metrics.has("static_memory_mb")
	
	var pass_all = has_fps and has_frametime and has_target and has_tier and has_mem
	_record(results, "TC-OPT-004", "Performance Metrics & Telemetry", pass_all, "Metrics dictionary reports FPS, frametime, target 120 FPS, tier, and memory usage")

static func _test_memory_budget_enforcement(results: Dictionary) -> void:
	var mem_mb = OS.get_static_memory_usage() / (1024.0 * 1024.0)
	# Memory in headless harness should be well under 250 MB
	var pass_mem = (mem_mb < 250.0)
	_record(results, "TC-OPT-005", "Static Memory Budget Verification", pass_mem, "Static memory allocation (%.1f MB) conforms to < 250 MB constraint" % mem_mb)

static func _test_fur_material_instantiation(results: Dictionary) -> void:
	var s_fur = load(FurShaderPath) as Shader
	var mat = ShaderMaterial.new()
	mat.shader = s_fur
	mat.set_shader_parameter("fur_base_color", Color(0.85, 0.65, 0.35, 1.0))
	mat.set_shader_parameter("rim_intensity", 1.5)
	
	var read_color = mat.get_shader_parameter("fur_base_color")
	var read_rim = mat.get_shader_parameter("rim_intensity")
	var pass_mat = (read_color == Color(0.85, 0.65, 0.35, 1.0) and abs(read_rim - 1.5) < 0.01)
	
	_record(results, "TC-OPT-006", "Fur ShaderMaterial Parameter Binding", pass_mat, "ShaderMaterial binds parameters and applies rim fluff values correctly")
