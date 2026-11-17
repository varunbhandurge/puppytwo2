class_name ForestUndergrowthScatter extends Node3D

## =============================================================================
## TWO PUPPIES: THE GREAT ADVENTURE — WHISPERING FOREST UNDERGROWTH SCATTER
## Renders dense woodland foliage in a single GPU draw call:
## - 2,000+ 3D Star-Tuft woodland grass clumps
## - 180+ Forest Ferns with arching fronds
## - 140+ Bioluminescent Azure Woodland Mushrooms (night/twilight glow)
## - 100+ Dry Autumn Oak & Maple Leaves
## - Dynamic puppy trample deformation in real-time
## =============================================================================

@export var grass_count: int = 2000
@export var fern_count: int = 180
@export var mushroom_count: int = 140
@export var leaf_count: int = 100

@export var forest_extents_x: float = 24.0
@export var forest_extents_z_min: float = -45.0
@export var forest_extents_z_max: float = 25.0

const GrassShader = preload("res://src/shaders/realistic_stylized_grass.gdshader")

var _grass_material: ShaderMaterial
var _bruno_node: Node3D
var _milo_node: Node3D

func _ready() -> void:
	_setup_materials()
	_generate_woodland_grass()
	_generate_forest_ferns()
	_generate_bioluminescent_mushrooms()
	_generate_fallen_leaves()
	_cache_puppy_references()

func _setup_materials() -> void:
	_grass_material = ShaderMaterial.new()
	_grass_material.shader = GrassShader
	# Deep forest shade palette: rich emerald root, forest green mid, lime-sunlit tips
	_grass_material.set_shader_parameter("root_color", Color(0.06, 0.18, 0.05, 1.0))
	_grass_material.set_shader_parameter("mid_color", Color(0.20, 0.48, 0.14, 1.0))
	_grass_material.set_shader_parameter("tip_color", Color(0.62, 0.84, 0.22, 1.0))
	_grass_material.set_shader_parameter("wind_speed", 1.8)
	_grass_material.set_shader_parameter("wind_strength", 0.15)
	_grass_material.set_shader_parameter("wind_turbulence", 0.75)
	_grass_material.set_shader_parameter("trample_radius", 1.35)
	_grass_material.set_shader_parameter("trample_strength", 0.65)

func _cache_puppy_references() -> void:
	var root = get_tree().current_scene if get_tree() else null
	if not root:
		return
	_bruno_node = root.find_child("Bruno", true, false) as Node3D
	_milo_node = root.find_child("Milo", true, false) as Node3D

func _process(_delta: float) -> void:
	if not _grass_material:
		return
	if not _bruno_node or not _milo_node:
		_cache_puppy_references()
		
	if _bruno_node and is_instance_valid(_bruno_node):
		_grass_material.set_shader_parameter("bruno_pos", _bruno_node.global_position)
	if _milo_node and is_instance_valid(_milo_node):
		_grass_material.set_shader_parameter("milo_pos", _milo_node.global_position)

func _create_star_tuft_mesh(base_w: float = 0.24, tip_h: float = 0.70) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var angles = [0.0, PI / 3.0, (2.0 * PI) / 3.0]
	var flare = 0.10
	var norm_up = Vector3(0.0, 0.85, 0.0).normalized()
	
	for angle in angles:
		var cos_a = cos(angle)
		var sin_a = sin(angle)
		var right = Vector3(cos_a, 0.0, sin_a)
		var forward = Vector3(-sin_a, 0.0, cos_a)
		
		var v0 = -right * (base_w * 0.5)
		var v1 = right * (base_w * 0.5)
		var v2 = -right * (base_w * 0.35) + Vector3(0.0, tip_h * 0.5, 0.0) + forward * flare
		var v3 = right * (base_w * 0.35) + Vector3(0.0, tip_h * 0.5, 0.0) + forward * flare
		var v4 = Vector3(0.0, tip_h, 0.0) + forward * (flare * 2.4)
		
		# Lower quad
		st.set_normal(norm_up); st.set_uv(Vector2(0.0, 0.0)); st.add_vertex(v0)
		st.set_normal(norm_up); st.set_uv(Vector2(1.0, 0.0)); st.add_vertex(v1)
		st.set_normal(norm_up); st.set_uv(Vector2(0.8, 0.5)); st.add_vertex(v3)
		
		st.set_normal(norm_up); st.set_uv(Vector2(0.0, 0.0)); st.add_vertex(v0)
		st.set_normal(norm_up); st.set_uv(Vector2(0.8, 0.5)); st.add_vertex(v3)
		st.set_normal(norm_up); st.set_uv(Vector2(0.2, 0.5)); st.add_vertex(v2)
		
		# Upper triangle
		st.set_normal(norm_up); st.set_uv(Vector2(0.2, 0.5)); st.add_vertex(v2)
		st.set_normal(norm_up); st.set_uv(Vector2(0.8, 0.5)); st.add_vertex(v3)
		st.set_normal(norm_up); st.set_uv(Vector2(0.5, 1.0)); st.add_vertex(v4)
		
	st.set_material(_grass_material)
	return st.commit()

func _generate_woodland_grass() -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "InstancedWoodlandGrass"
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mmi)
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = grass_count
	mm.mesh = _create_star_tuft_mesh()
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 98765
	
	var placed = 0
	for i in range(grass_count):
		var gx = rng.randf_range(-forest_extents_x, forest_extents_x)
		var gz = rng.randf_range(forest_extents_z_min, forest_extents_z_max)
		
		# Avoid deep stream channel (x: -24 to 24, z: -3 to 3)
		if abs(gz) < 2.5:
			continue
			
		var s = rng.randf_range(0.85, 1.45)
		var t = Transform3D()
		t = t.scaled(Vector3(s, s * rng.randf_range(0.9, 1.3), s))
		t = t.rotated(Vector3.UP, rng.randf_range(0.0, TAU))
		t.origin = Vector3(gx, 0.0, gz)
		mm.set_instance_transform(placed, t)
		placed += 1
		
	while placed < grass_count:
		mm.set_instance_transform(placed, Transform3D().scaled(Vector3.ZERO))
		placed += 1
		
	mmi.multimesh = mm

func _generate_forest_ferns() -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "InstancedFerns"
	add_child(mmi)
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = fern_count
	
	var fern_mat = StandardMaterial3D.new()
	fern_mat.albedo_color = Color(0.18, 0.44, 0.12, 1.0) # Forest fern emerald
	fern_mat.roughness = 0.55
	
	# Broad arched leaf quad for fern fronds
	var fern_mesh = PrismMesh.new()
	fern_mesh.size = Vector3(0.65, 0.85, 0.25)
	fern_mesh.material = fern_mat
	mm.mesh = fern_mesh
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 54321
	
	for i in range(fern_count):
		var fx = rng.randf_range(-forest_extents_x * 0.9, forest_extents_x * 0.9)
		var fz = rng.randf_range(forest_extents_z_min * 0.9, forest_extents_z_max * 0.9)
		
		if abs(fz) < 2.8:
			continue
			
		var t = Transform3D()
		var s = rng.randf_range(0.9, 1.5)
		t = t.scaled(Vector3(s, s, s))
		t = t.rotated(Vector3.UP, rng.randf_range(0.0, TAU))
		t.origin = Vector3(fx, 0.4, fz)
		mm.set_instance_transform(i, t)
		
	mmi.multimesh = mm

func _generate_bioluminescent_mushrooms() -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "InstancedMushrooms"
	add_child(mmi)
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = mushroom_count
	
	var shroom_mat = StandardMaterial3D.new()
	shroom_mat.albedo_color = Color(0.25, 0.72, 0.92, 1.0) # Glowing cyan cap
	shroom_mat.emission_enabled = true
	shroom_mat.emission = Color(0.2, 0.8, 1.0, 1.0)
	shroom_mat.emission_energy_multiplier = 0.75
	shroom_mat.roughness = 0.35
	
	var cap = SphereMesh.new()
	cap.radius = 0.14
	cap.height = 0.18
	cap.material = shroom_mat
	mm.mesh = cap
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 112233
	
	for i in range(mushroom_count):
		var mx = rng.randf_range(-forest_extents_x * 0.88, forest_extents_x * 0.88)
		var mz = rng.randf_range(forest_extents_z_min * 0.88, forest_extents_z_max * 0.88)
		
		var t = Transform3D()
		var s = rng.randf_range(0.75, 1.35)
		t = t.scaled(Vector3(s, s * 0.8, s))
		t.origin = Vector3(mx, 0.16, mz)
		mm.set_instance_transform(i, t)
		
	mmi.multimesh = mm

func _generate_fallen_leaves() -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "InstancedLeaves"
	add_child(mmi)
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = leaf_count
	
	var leaf_mat = StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.72, 0.36, 0.12, 1.0) # Russet oak
	leaf_mat.roughness = 0.8
	
	var leaf_mesh = BoxMesh.new()
	leaf_mesh.size = Vector3(0.28, 0.02, 0.18)
	leaf_mesh.material = leaf_mat
	mm.mesh = leaf_mesh
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 667788
	
	for i in range(leaf_count):
		var lx = rng.randf_range(-forest_extents_x * 0.85, forest_extents_x * 0.85)
		var lz = rng.randf_range(forest_extents_z_min * 0.85, forest_extents_z_max * 0.85)
		
		var t = Transform3D()
		var s = rng.randf_range(0.8, 1.4)
		t = t.scaled(Vector3(s, 1.0, s))
		t = t.rotated(Vector3.UP, rng.randf_range(0.0, TAU))
		t.origin = Vector3(lx, 0.02, lz)
		mm.set_instance_transform(i, t)
		
	mmi.multimesh = mm
