class_name ForestUndergrowthScatter extends Node3D

## =============================================================================
## TWO PUPPIES: THE GREAT ADVENTURE — PREMIUM STYLIZED UNDERGROWTH SCATTER
## Renders dense, Pixar-style storybook woodland foliage in single GPU draw calls:
## - 6,000 Micro Star-Tuft grass clumps (0.22m puppy scale, curved quads)
## - 600 Woodland Clovers (3-leaf forest ground cover)
## - 400 Golden Buttercup & Bluebell Wildflowers (5-petal cups)
## - 300 Multi-frond Arched Forest Ferns
## - 180 Bioluminescent Woodland Mushrooms
## - 150 Organic Autumn Leaf Decals
## - Dynamic puppy trample deformation in real-time
## =============================================================================

@export var grass_count: int = 6000
@export var clover_count: int = 600
@export var flower_count: int = 400
@export var fern_count: int = 300
@export var mushroom_count: int = 180
@export var leaf_count: int = 150

@export var forest_extents_x: float = 24.0
@export var forest_extents_z_min: float = -44.0
@export var forest_extents_z_max: float = 28.0

const GrassShader = preload("res://src/shaders/realistic_stylized_grass.gdshader")

var _grass_material: ShaderMaterial
var _bruno_node: Node3D
var _milo_node: Node3D

func _ready() -> void:
	_setup_materials()
	_generate_woodland_grass()
	_generate_woodland_clovers()
	_generate_wildflowers()
	_generate_forest_ferns()
	_generate_bioluminescent_mushrooms()
	_generate_fallen_leaves()
	_cache_puppy_references()

func _setup_materials() -> void:
	_grass_material = ShaderMaterial.new()
	_grass_material.shader = GrassShader
	# Deep forest shade palette: rich emerald root, forest green mid, lime-sunlit tips
	_grass_material.set_shader_parameter("root_color", Color(0.08, 0.22, 0.06, 1.0))
	_grass_material.set_shader_parameter("mid_color", Color(0.22, 0.52, 0.16, 1.0))
	_grass_material.set_shader_parameter("tip_color", Color(0.68, 0.88, 0.26, 1.0))
	_grass_material.set_shader_parameter("wind_speed", 2.2)
	_grass_material.set_shader_parameter("wind_strength", 0.18)
	_grass_material.set_shader_parameter("wind_turbulence", 0.85)
	_grass_material.set_shader_parameter("trample_radius", 1.2)
	_grass_material.set_shader_parameter("trample_strength", 0.7)

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

## Heightmap function matching sculpted terrain elevation
static func get_ground_height(x: float, z: float) -> float:
	var y = 0.0
	var edge = abs(x)
	if edge > 14.0:
		y += pow((edge - 14.0) / 12.0, 1.8) * 6.5
	if abs(z) < 4.5:
		y -= (1.0 - (abs(z) / 4.5)) * 0.75
	if abs(z - (-16.0)) < 3.2 and abs(x) < 8.0:
		y -= (1.0 - (abs(z - (-16.0)) / 3.2)) * 2.8
	if z < -24.0:
		var cf = clamp((-24.0 - z) / 8.0, 0.0, 1.0)
		y += cf * 3.2
	if z <= -34.0:
		y = 3.4
		if edge > 12.0:
			y += ((edge - 12.0) / 14.0) * 4.0
	y += sin(x * 0.4) * cos(z * 0.3) * 0.22
	return y

## Creates puppy-scale (0.22m) curved grass star-tuft mesh
func _create_star_tuft_mesh(base_w: float = 0.08, tip_h: float = 0.22) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var angles = [0.0, PI * 0.25, PI * 0.5, PI * 0.75]
	var norm_up = Vector3(0.0, 0.95, 0.0).normalized()
	
	for angle in angles:
		var cos_a = cos(angle)
		var sin_a = sin(angle)
		var right = Vector3(cos_a, 0.0, sin_a)
		var forward = Vector3(-sin_a, 0.0, cos_a)
		var curve_out = 0.04
		
		# Root vertices
		var v0 = -right * (base_w * 0.5)
		var v1 = right * (base_w * 0.5)
		# Mid vertices (curved slightly forward)
		var v2 = -right * (base_w * 0.35) + Vector3(0.0, tip_h * 0.5, 0.0) + forward * curve_out
		var v3 = right * (base_w * 0.35) + Vector3(0.0, tip_h * 0.5, 0.0) + forward * curve_out
		# Tip vertex (arching further outward)
		var v4 = Vector3(0.0, tip_h, 0.0) + forward * (curve_out * 2.5)
		
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

## Creates realistic 3-leaf woodland clover cluster
func _create_clover_mesh() -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var norm = Vector3.UP
	for i in range(3):
		var angle = i * (TAU / 3.0)
		var dir = Vector2(cos(angle), sin(angle))
		var perp = Vector2(-sin(angle), cos(angle)) * 0.045
		var center = dir * 0.075
		var p0 = Vector3(0, 0.01, 0)
		var p1 = Vector3(center.x - perp.x, 0.025, center.y - perp.y)
		var p2 = Vector3(center.x + perp.x, 0.025, center.y + perp.y)
		var p3 = Vector3(dir.x * 0.12, 0.035, dir.y * 0.12)
		st.set_normal(norm); st.set_uv(Vector2(0, 0)); st.add_vertex(p0)
		st.set_normal(norm); st.set_uv(Vector2(0, 1)); st.add_vertex(p1)
		st.set_normal(norm); st.set_uv(Vector2(1, 1)); st.add_vertex(p3)

		st.set_normal(norm); st.set_uv(Vector2(0, 0)); st.add_vertex(p0)
		st.set_normal(norm); st.set_uv(Vector2(1, 1)); st.add_vertex(p3)
		st.set_normal(norm); st.set_uv(Vector2(1, 0)); st.add_vertex(p2)
		
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.20, 0.54, 0.16, 1.0) # Forest green clover
	mat.roughness = 0.55
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	st.set_material(mat)
	return st.commit()

## Creates 5-petal stylized wildflower mesh
func _create_wildflower_mesh() -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var norm = Vector3.UP
	for i in range(5):
		var angle = i * (TAU / 5.0)
		var dir = Vector2(cos(angle), sin(angle))
		var perp = Vector2(-sin(angle), cos(angle)) * 0.03
		var p0 = Vector3(0, 0.04, 0)
		var p1 = Vector3(dir.x * 0.04 - perp.x, 0.06, dir.y * 0.04 - perp.y)
		var p2 = Vector3(dir.x * 0.04 + perp.x, 0.06, dir.y * 0.04 + perp.y)
		var p3 = Vector3(dir.x * 0.08, 0.08, dir.y * 0.08)
		st.set_normal(norm); st.set_uv(Vector2(0, 0)); st.add_vertex(p0)
		st.set_normal(norm); st.set_uv(Vector2(0, 1)); st.add_vertex(p1)
		st.set_normal(norm); st.set_uv(Vector2(1, 1)); st.add_vertex(p3)

		st.set_normal(norm); st.set_uv(Vector2(0, 0)); st.add_vertex(p0)
		st.set_normal(norm); st.set_uv(Vector2(1, 1)); st.add_vertex(p3)
		st.set_normal(norm); st.set_uv(Vector2(1, 0)); st.add_vertex(p2)

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.86, 0.22, 1.0) # Buttercup gold
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.88, 0.28, 1.0)
	mat.emission_energy_multiplier = 0.4
	mat.roughness = 0.35
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	st.set_material(mat)
	return st.commit()

## Creates arched multi-frond woodland fern mesh
func _create_fern_mesh() -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(5):
		var angle = i * (TAU / 5.0) + 0.25
		var dir = Vector3(cos(angle), 0, sin(angle))
		var side = Vector3(-sin(angle), 0, cos(angle)) * 0.12
		var p0 = Vector3(0, 0.02, 0)
		var p1 = dir * 0.25 + side * 0.5 + Vector3(0, 0.22, 0)
		var p2 = dir * 0.25 - side * 0.5 + Vector3(0, 0.22, 0)
		var p3 = dir * 0.55 + Vector3(0, 0.12, 0)
		var norm = (Vector3.UP + dir * 0.4).normalized()
		st.set_normal(norm); st.set_uv(Vector2(0, 0)); st.add_vertex(p0)
		st.set_normal(norm); st.set_uv(Vector2(0, 1)); st.add_vertex(p1)
		st.set_normal(norm); st.set_uv(Vector2(1, 1)); st.add_vertex(p3)

		st.set_normal(norm); st.set_uv(Vector2(0, 0)); st.add_vertex(p0)
		st.set_normal(norm); st.set_uv(Vector2(1, 1)); st.add_vertex(p3)
		st.set_normal(norm); st.set_uv(Vector2(1, 0)); st.add_vertex(p2)

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.14, 0.46, 0.12, 1.0) # Deep fern emerald
	mat.roughness = 0.6
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	st.set_material(mat)
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
		
		# Avoid deep river channel and ravine chasm
		if abs(gz) < 2.0 or (abs(gz - (-16.0)) < 2.2 and abs(gx) < 6.5):
			continue
			
		var gy = get_ground_height(gx, gz)
		var s = rng.randf_range(0.85, 1.45)
		var t = Transform3D()
		t = t.scaled(Vector3(s, s * rng.randf_range(0.9, 1.3), s))
		t = t.rotated(Vector3.UP, rng.randf_range(0.0, TAU))
		t.origin = Vector3(gx, gy, gz)
		mm.set_instance_transform(placed, t)
		placed += 1
		
	while placed < grass_count:
		mm.set_instance_transform(placed, Transform3D().scaled(Vector3.ZERO))
		placed += 1
		
	mmi.multimesh = mm

func _generate_woodland_clovers() -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "InstancedClovers"
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mmi)
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = clover_count
	mm.mesh = _create_clover_mesh()
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 445566
	var placed = 0
	for i in range(clover_count):
		var cx = rng.randf_range(-forest_extents_x * 0.9, forest_extents_x * 0.9)
		var cz = rng.randf_range(forest_extents_z_min * 0.9, forest_extents_z_max * 0.9)
		if abs(cz) < 2.0 or (abs(cz - (-16.0)) < 2.2 and abs(cx) < 6.5):
			continue
		var cy = get_ground_height(cx, cz)
		var t = Transform3D()
		var s = rng.randf_range(0.8, 1.4)
		t = t.scaled(Vector3(s, s, s))
		t = t.rotated(Vector3.UP, rng.randf_range(0.0, TAU))
		t.origin = Vector3(cx, cy + 0.015, cz)
		mm.set_instance_transform(placed, t)
		placed += 1
		
	while placed < clover_count:
		mm.set_instance_transform(placed, Transform3D().scaled(Vector3.ZERO))
		placed += 1
	mmi.multimesh = mm

func _generate_wildflowers() -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "InstancedWildflowers"
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mmi)
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = flower_count
	mm.mesh = _create_wildflower_mesh()
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 778899
	var placed = 0
	for i in range(flower_count):
		var fx = rng.randf_range(-forest_extents_x * 0.85, forest_extents_x * 0.85)
		var fz = rng.randf_range(forest_extents_z_min * 0.85, forest_extents_z_max * 0.85)
		if abs(fz) < 2.2 or (abs(fz - (-16.0)) < 2.2 and abs(fx) < 6.5):
			continue
		var fy = get_ground_height(fx, fz)
		var t = Transform3D()
		var s = rng.randf_range(0.9, 1.6)
		t = t.scaled(Vector3(s, s, s))
		t = t.rotated(Vector3.UP, rng.randf_range(0.0, TAU))
		t.origin = Vector3(fx, fy + 0.02, fz)
		mm.set_instance_transform(placed, t)
		placed += 1
		
	while placed < flower_count:
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
	mm.mesh = _create_fern_mesh()
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 54321
	var placed = 0
	for i in range(fern_count):
		var fx = rng.randf_range(-forest_extents_x * 0.9, forest_extents_x * 0.9)
		var fz = rng.randf_range(forest_extents_z_min * 0.9, forest_extents_z_max * 0.9)
		if abs(fz) < 2.5:
			continue
		var fy = get_ground_height(fx, fz)
		var t = Transform3D()
		var s = rng.randf_range(0.8, 1.5)
		t = t.scaled(Vector3(s, s, s))
		t = t.rotated(Vector3.UP, rng.randf_range(0.0, TAU))
		t.origin = Vector3(fx, fy + 0.02, fz)
		mm.set_instance_transform(placed, t)
		placed += 1
		
	while placed < fern_count:
		mm.set_instance_transform(placed, Transform3D().scaled(Vector3.ZERO))
		placed += 1
	mmi.multimesh = mm

func _generate_bioluminescent_mushrooms() -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "InstancedMushrooms"
	add_child(mmi)
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = mushroom_count
	
	var shroom_mat = StandardMaterial3D.new()
	shroom_mat.albedo_color = Color(0.18, 0.78, 0.98, 1.0) # Glowing cyan cap
	shroom_mat.emission_enabled = true
	shroom_mat.emission = Color(0.2, 0.85, 1.0, 1.0)
	shroom_mat.emission_energy_multiplier = 0.85
	shroom_mat.roughness = 0.35
	
	var cap = SphereMesh.new()
	cap.radius = 0.08
	cap.height = 0.09
	cap.material = shroom_mat
	mm.mesh = cap
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 112233
	var placed = 0
	for i in range(mushroom_count):
		var mx = rng.randf_range(-forest_extents_x * 0.88, forest_extents_x * 0.88)
		var mz = rng.randf_range(forest_extents_z_min * 0.88, forest_extents_z_max * 0.88)
		if abs(mz) < 2.5:
			continue
		var my = get_ground_height(mx, mz)
		var t = Transform3D()
		var s = rng.randf_range(0.7, 1.3)
		t = t.scaled(Vector3(s, s * 0.8, s))
		t.origin = Vector3(mx, my + 0.05, mz)
		mm.set_instance_transform(placed, t)
		placed += 1
		
	while placed < mushroom_count:
		mm.set_instance_transform(placed, Transform3D().scaled(Vector3.ZERO))
		placed += 1
	mmi.multimesh = mm

func _generate_fallen_leaves() -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "InstancedLeaves"
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mmi)
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = leaf_count
	
	var leaf_mat = StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.78, 0.40, 0.16, 1.0) # Russet oak
	leaf_mat.roughness = 0.85
	
	var leaf_mesh = BoxMesh.new()
	leaf_mesh.size = Vector3(0.18, 0.015, 0.12)
	leaf_mesh.material = leaf_mat
	mm.mesh = leaf_mesh
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 667788
	var placed = 0
	for i in range(leaf_count):
		var lx = rng.randf_range(-forest_extents_x * 0.85, forest_extents_x * 0.85)
		var lz = rng.randf_range(forest_extents_z_min * 0.85, forest_extents_z_max * 0.85)
		if abs(lz) < 2.5:
			continue
		var ly = get_ground_height(lx, lz)
		var t = Transform3D()
		var s = rng.randf_range(0.8, 1.4)
		t = t.scaled(Vector3(s, 1.0, s))
		t = t.rotated(Vector3.UP, rng.randf_range(0.0, TAU))
		t.origin = Vector3(lx, ly + 0.01, lz)
		mm.set_instance_transform(placed, t)
		placed += 1
		
	while placed < leaf_count:
		mm.set_instance_transform(placed, Transform3D().scaled(Vector3.ZERO))
		placed += 1
	mmi.multimesh = mm
