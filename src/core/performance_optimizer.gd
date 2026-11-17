class_name PerformanceOptimizerSingleton extends Node

## Master Visual Polish, Quality Profiles & Dynamic Frame Budget Optimizer
## Targets locked 120 FPS (8.33ms) on RTX 3060 baseline at 1440p dual-viewport split-screen.

enum QualityTier {
	PERFORMANCE,
	BALANCED,
	ULTRA
}

var current_tier: QualityTier = QualityTier.ULTRA
var target_fps: float = 120.0
var target_frametime_ms: float = 8.33

# Dynamic Resolution Scaling (DRS)
var drs_enabled: bool = true
var min_scale: float = 0.75
var max_scale: float = 1.0
var current_3d_scale: float = 1.0

# Frame telemetry smoothing
var frame_history: Array[float] = []
const HISTORY_CAPACITY: int = 60

signal quality_tier_changed(new_tier: int)
signal drs_scale_adjusted(new_scale: float)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	apply_quality_tier(QualityTier.ULTRA)

func apply_quality_tier(tier: QualityTier) -> void:
	current_tier = tier
	
	match tier:
		QualityTier.PERFORMANCE:
			target_fps = 120.0
			current_3d_scale = 0.85
			_set_shadow_atlas_size(1024)
			_set_msaa_level(RenderingServer.VIEWPORT_MSAA_DISABLED)
			_set_screen_space_aa(RenderingServer.VIEWPORT_SCREEN_SPACE_AA_FXAA)
			_set_lod_bias(0.8)
		QualityTier.BALANCED:
			target_fps = 120.0
			current_3d_scale = 1.0
			_set_shadow_atlas_size(2048)
			_set_msaa_level(RenderingServer.VIEWPORT_MSAA_2X)
			_set_screen_space_aa(RenderingServer.VIEWPORT_SCREEN_SPACE_AA_FXAA)
			_set_lod_bias(1.0)
		QualityTier.ULTRA:
			target_fps = 120.0
			current_3d_scale = 1.0
			_set_shadow_atlas_size(4096)
			_set_msaa_level(RenderingServer.VIEWPORT_MSAA_4X)
			_set_screen_space_aa(RenderingServer.VIEWPORT_SCREEN_SPACE_AA_FXAA)
			_set_lod_bias(1.2)
			
	_apply_3d_scale(current_3d_scale)
	quality_tier_changed.emit(int(tier))

func _process(delta: float) -> void:
	if not drs_enabled or delta <= 0.0:
		return
		
	var frame_ms = delta * 1000.0
	frame_history.append(frame_ms)
	if frame_history.size() > HISTORY_CAPACITY:
		frame_history.pop_front()
		
	# Check rolling average every 30 frames
	if frame_history.size() >= 30 and Engine.get_process_frames() % 30 == 0:
		var sum: float = 0.0
		for t in frame_history:
			sum += t
		var avg_ms = sum / float(frame_history.size())
		
		_evaluate_drs(avg_ms)

func _evaluate_drs(avg_frametime_ms: float) -> void:
	var threshold_drop = target_frametime_ms * 1.15 # If frametime > 9.58ms (below 104 FPS)
	var threshold_boost = target_frametime_ms * 0.85 # If frametime < 7.08ms (above 140 FPS)
	
	if avg_frametime_ms > threshold_drop and current_3d_scale > min_scale:
		current_3d_scale = max(min_scale, current_3d_scale - 0.05)
		_apply_3d_scale(current_3d_scale)
		drs_scale_adjusted.emit(current_3d_scale)
	elif avg_frametime_ms < threshold_boost and current_3d_scale < max_scale:
		current_3d_scale = min(max_scale, current_3d_scale + 0.05)
		_apply_3d_scale(current_3d_scale)
		drs_scale_adjusted.emit(current_3d_scale)

func _apply_3d_scale(scale: float) -> void:
	if is_inside_tree() and get_viewport():
		get_viewport().scaling_3d_scale = scale

func _set_shadow_atlas_size(size: int) -> void:
	if is_inside_tree() and get_viewport():
		RenderingServer.viewport_set_positional_shadow_atlas_size(get_viewport().get_viewport_rid(), size, true)

func _set_msaa_level(msaa: RenderingServer.ViewportMSAA) -> void:
	if is_inside_tree() and get_viewport():
		RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), msaa)

func _set_screen_space_aa(aa: RenderingServer.ViewportScreenSpaceAA) -> void:
	if is_inside_tree() and get_viewport():
		RenderingServer.viewport_set_screen_space_aa(get_viewport().get_viewport_rid(), aa)

func _set_lod_bias(bias: float) -> void:
	# Tuning camera/viewport mesh LOD threshold
	ProjectSettings.set_setting("rendering/mesh_lod/lod_change/threshold_pixels", 1.0 / bias)

func get_performance_metrics() -> Dictionary:
	var current_fps = Engine.get_frames_per_second()
	var frametime = 1000.0 / max(1.0, float(current_fps))
	
	return {
		"fps": current_fps,
		"frametime_ms": frametime,
		"target_fps": target_fps,
		"target_frametime_ms": target_frametime_ms,
		"quality_tier": QualityTier.keys()[current_tier],
		"scaling_3d": current_3d_scale,
		"drs_enabled": drs_enabled,
		"static_memory_mb": OS.get_static_memory_usage() / (1024.0 * 1024.0)
	}
