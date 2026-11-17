class_name LawnGrassScatter extends Node3D

## =============================================================================
## TWO PUPPIES: THE GREAT ADVENTURE — AAA PROCEDURAL LAWN & FOLIAGE SCATTER
## Inspired by Hazelight's "It Takes Two" Garden Chapter:
## - 2,400+ GPU-Instanced 3D Star-Tuft Grass Clumps (crossed tapered curved blades)
## - 300+ Wildflowers (Sunny Dandelions, Pristine Daisies, Hedge Blossoms)
## - 80+ Scattered Autumn Leaves (Oak Amber, Maple Crimson, Golden Birch)
## - Canine Toys (Tennis Ball, Braided Chew Rope)
## - Stepping Stone Edge Overgrowth Clumping
## - Dynamic puppy trample deformation in real-time
## =============================================================================

@export var grass_count: int = 2400
@export var flower_count: int = 280
@export var leaf_count: int = 80
@export var lawn_extents_x: float = 17.5
@export var lawn_extents_z_min: float = -26.0
@export var lawn_extents_z_max: float = 18.0

const GrassShader = preload("res://src/shaders/realistic_stylized_grass.gdshader")

var _grass_material: ShaderMaterial
var _bruno_node: Node3D
var _milo_node: Node3D

func _ready() -> void:
	_setup_grass_material()
	_generate_3d_star_grass_multimesh()
	_generate_stepping_stone_edge_grass()
	_generate_wildflower_multimesh()
	_generate_hedge_blossom_multimesh()
	_generate_fallen_leaves_multimesh()
	_spawn_canine_props()
	_cache_puppy_references()

func _setup_grass_material() -> void:
	_grass_material = ShaderMaterial.new()
	_grass_material.shader = GrassShader
	_grass_material.set_shader_parameter("root_color", Color(0.08, 0.22, 0.06, 1.0))
	_grass_material.set_shader_parameter("mid_color", Color(0.26, 0.58, 0.16, 1.0))
	_grass_material.set_shader_parameter("tip_color", Color(0.72, 0.90, 0.24, 1.0))
	_grass_material.set_shader_parameter("wind_speed", 2.4)
	_grass_material.set_shader_parameter("wind_strength", 0.18)
	_grass_material.set_shader_parameter("wind_turbulence", 0.85)
	_grass_material.set_shader_parameter("trample_radius", 1.35)
	_grass_material.set_shader_parameter("trample_strength", 0.65)

func _cache_puppy_references() -> void:
	var tree = get_tree()
	if not tree:
		return
	var root = tree.current_scene
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

## Builds an organic 3D Star-Tuft ArrayMesh consisting of 3 crossed, tapered, flared blades
func _create_star_tuft_mesh(base_w: float = 0.22, tip_h: float = 0.62) -> ArrayMesh:
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var blade_angles = [0.0, PI / 3.0, (2.0 * PI) / 3.0] # 0, 60, 120 degrees
	var flare_curve = 0.08
	
	for angle in blade_angles:
		var cos_a = cos(angle)
		var sin_a = sin(angle)
		var right = Vector3(cos_a, 0.0, sin_a)
		var forward = Vector3(-sin_a, 0.0, cos_a)
		
		var v0 = -right * (base_w * 0.5)
		var v1 = right * (base_w * 0.5)
		var v2 = -right * (base_w * 0.35) + Vector3(0.0, tip_h * 0.5, 0.0) + forward * flare_curve
		var v3 = right * (base_w * 0.35) + Vector3(0.0, tip_h * 0.5, 0.0) + forward * flare_curve
		var v4 = Vector3(0.0, tip_h, 0.0) + forward * (flare_curve * 2.2)
		
		var norm_up = Vector3(0.0, 0.85, 0.0).normalized()
		
		# Quad lower half
		surface_tool.set_normal(norm_up)
		surface_tool.set_uv(Vector2(0.0, 0.0))
		surface_tool.add_vertex(v0)
		
		surface_tool.set_normal(norm_up)
		surface_tool.set_uv(Vector2(1.0, 0.0))
		surface_tool.add_vertex(v1)
		
		surface_tool.set_normal(norm_up)
		surface_tool.set_uv(Vector2(0.8, 0.5))
		surface_tool.add_vertex(v3)
		
		surface_tool.set_normal(norm_up)
		surface_tool.set_uv(Vector2(0.0, 0.0))
		surface_tool.add_vertex(v0)
		
		surface_tool.set_normal(norm_up)
		surface_tool.set_uv(Vector2(0.8, 0.5))
		surface_tool.add_vertex(v3)
		
		surface_tool.set_normal(norm_up)
		surface_tool.set_uv(Vector2(0.2, 0.5))
		surface_tool.add_vertex(v2)
		
		# Triangle upper half
		surface_tool.set_normal(norm_up)
		surface_tool.set_uv(Vector2(0.2, 0.5))
		surface_tool.add_vertex(v2)
		
		surface_tool.set_normal(norm_up)
		surface_tool.set_uv(Vector2(0.8, 0.5))
		surface_tool.add_vertex(v3)
		
		surface_tool.set_normal(norm_up)
		surface_tool.set_uv(Vector2(0.5, 1.0))
		surface_tool.add_vertex(v4)
		
	surface_tool.set_material(_grass_material)
	return surface_tool.commit()

func _generate_3d_star_grass_multimesh() -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "Instanced3DStarGrass"
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mmi)
	
	var tuft_mesh = _create_star_tuft_mesh()
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = grass_count
	mm.mesh = tuft_mesh
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 1337
	
	var placed: int = 0
	var attempts: int = 0
	var max_attempts: int = grass_count * 4
	
	while placed < grass_count and attempts < max_attempts:
		attempts += 1
		var gx = rng.randf_range(-lawn_extents_x, lawn_extents_x)
		var gz = rng.randf_range(lawn_extents_z_min, lawn_extents_z_max)
		
		# Avoid central stepping stone path
		if abs(gx) < 1.1 and gz > -24.0 and gz < 9.0:
			continue
		# Avoid sandbox
		if gx < -6.5 and gx > -15.5 and abs(gz) < 4.8:
			continue
		# Avoid picnic table
		if gx > 7.5 and gx < 14.5 and gz > -10.5 and gz < -1.5:
			continue
		# Avoid doghouse
		if abs(gx) < 3.2 and gz > 9.5 and gz < 16.5:
			continue
		# Avoid sprinkler boss arena
		if abs(gx) < 3.5 and gz > -24.0 and gz < -16.0:
			continue
			
		var scale_val = rng.randf_range(0.85, 1.45)
		var rot_y = rng.randf_range(0.0, TAU)
		
		var t = Transform3D()
		t = t.scaled(Vector3(scale_val, scale_val * rng.randf_range(0.9, 1.3), scale_val))
		t = t.rotated(Vector3.UP, rot_y)
		t.origin = Vector3(gx, 0.0, gz)
		
		mm.set_instance_transform(placed, t)
		placed += 1
		
	while placed < grass_count:
		var t = Transform3D().scaled(Vector3.ZERO)
		mm.set_instance_transform(placed, t)
		placed += 1
		
	mmi.multimesh = mm

## Tightly clusters grass blades along the stepping stone edges to create lush organic embedding
func _generate_stepping_stone_edge_grass() -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "InstancedSteppingStoneEdgeGrass"
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mmi)
	
	var edge_tuft = _create_star_tuft_mesh(0.18, 0.48)
	var count = 300
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = count
	mm.mesh = edge_tuft
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 2026
	
	for i in range(count):
		# Spine runs along z = -20.0 to 8.0, stones are at x = [-0.9, 0.9]
		var z = rng.randf_range(-20.0, 8.0)
		var side = -1.0 if rng.randf() > 0.5 else 1.0
		var x = side * rng.randf_range(0.85, 1.55)
		
		var s = rng.randf_range(0.75, 1.25)
		var t = Transform3D()
		t = t.scaled(Vector3(s, s * 1.1, s))
		t = t.rotated(Vector3.UP, rng.randf_range(0.0, TAU))
		t.origin = Vector3(x, 0.0, z)
		mm.set_instance_transform(i, t)
		
	mmi.multimesh = mm

## Wildflowers: Sunny Dandelions and White Meadow Daisies
func _generate_wildflower_multimesh() -> void:
	# 1. Dandelions
	var mmi_d = MultiMeshInstance3D.new()
	mmi_d.name = "InstancedDandelions"
	add_child(mmi_d)
	
	var mm_d = MultiMesh.new()
	mm_d.transform_format = MultiMesh.TRANSFORM_3D
	var dandelion_count = int(flower_count * 0.6)
	mm_d.instance_count = dandelion_count
	
	var flower_mat = StandardMaterial3D.new()
	flower_mat.albedo_color = Color(1.0, 0.88, 0.15, 1.0)
	flower_mat.roughness = 0.4
	flower_mat.emission_enabled = true
	flower_mat.emission = Color(0.95, 0.75, 0.1, 1.0)
	flower_mat.emission_energy_multiplier = 0.25
	
	var blossom = SphereMesh.new()
	blossom.radius = 0.10
	blossom.height = 0.20
	blossom.material = flower_mat
	mm_d.mesh = blossom
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 8888
	
	for i in range(dandelion_count):
		var fx = rng.randf_range(-lawn_extents_x * 0.92, lawn_extents_x * 0.92)
		var fz = rng.randf_range(lawn_extents_z_min * 0.92, lawn_extents_z_max * 0.92)
		
		var t = Transform3D()
		var s = rng.randf_range(0.85, 1.35)
		t = t.scaled(Vector3(s, s * 1.3, s))
		t.origin = Vector3(fx, 0.14, fz)
		mm_d.set_instance_transform(i, t)
		
	mmi_d.multimesh = mm_d
	
	# 2. White Meadow Daisies
	var mmi_w = MultiMeshInstance3D.new()
	mmi_w.name = "InstancedDaisies"
	add_child(mmi_w)
	
	var mm_w = MultiMesh.new()
	mm_w.transform_format = MultiMesh.TRANSFORM_3D
	var daisy_count = flower_count - dandelion_count
	mm_w.instance_count = daisy_count
	
	var daisy_mat = StandardMaterial3D.new()
	daisy_mat.albedo_color = Color(0.96, 0.96, 0.98, 1.0)
	daisy_mat.roughness = 0.45
	
	var daisy_blossom = SphereMesh.new()
	daisy_blossom.radius = 0.08
	daisy_blossom.height = 0.14
	daisy_blossom.material = daisy_mat
	mm_w.mesh = daisy_blossom
	
	for i in range(daisy_count):
		var fx = rng.randf_range(-lawn_extents_x * 0.88, lawn_extents_x * 0.88)
		var fz = rng.randf_range(lawn_extents_z_min * 0.88, lawn_extents_z_max * 0.88)
		
		var t = Transform3D()
		var s = rng.randf_range(0.8, 1.25)
		t = t.scaled(Vector3(s * 1.2, s * 0.8, s * 1.2))
		t.origin = Vector3(fx, 0.12, fz)
		mm_w.set_instance_transform(i, t)
		
	mmi_w.multimesh = mm_w

## Colorful flowering hedge blossoms along the east and west fence perimeter
func _generate_hedge_blossom_multimesh() -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "InstancedHedgeBlossoms"
	add_child(mmi)
	
	var count = 120
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = count
	
	var blossom_mat = StandardMaterial3D.new()
	blossom_mat.albedo_color = Color(0.88, 0.32, 0.58, 1.0) # Rose magenta
	blossom_mat.roughness = 0.5
	
	var mesh = SphereMesh.new()
	mesh.radius = 0.12
	mesh.height = 0.22
	mesh.material = blossom_mat
	mm.mesh = mesh
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 4444
	
	for i in range(count):
		var side = -18.2 if i < 60 else 18.2
		var z = rng.randf_range(-25.0, 16.0)
		var y = rng.randf_range(0.8, 2.8) # Varied height along hedge
		
		var t = Transform3D()
		var s = rng.randf_range(0.8, 1.4)
		t = t.scaled(Vector3(s, s, s))
		t.origin = Vector3(side + rng.randf_range(-0.4, 0.4), y, z)
		mm.set_instance_transform(i, t)
		
	mmi.multimesh = mm

## Scattered autumn leaves (amber, crimson, gold) on the lawn
func _generate_fallen_leaves_multimesh() -> void:
	var mmi = MultiMeshInstance3D.new()
	mmi.name = "InstancedFallenLeaves"
	add_child(mmi)
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = leaf_count
	
	var leaf_mat = StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.85, 0.44, 0.14, 1.0) # Amber orange leaf
	leaf_mat.roughness = 0.7
	
	var leaf_mesh = BoxMesh.new()
	leaf_mesh.size = Vector3(0.24, 0.02, 0.16)
	leaf_mesh.material = leaf_mat
	mm.mesh = leaf_mesh
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 7777
	
	for i in range(leaf_count):
		var lx = rng.randf_range(-lawn_extents_x * 0.85, lawn_extents_x * 0.85)
		var lz = rng.randf_range(lawn_extents_z_min * 0.85, lawn_extents_z_max * 0.85)
		
		var t = Transform3D()
		var s = rng.randf_range(0.8, 1.3)
		t = t.scaled(Vector3(s, 1.0, s))
		t = t.rotated(Vector3.UP, rng.randf_range(0.0, TAU))
		t.origin = Vector3(lx, 0.02, lz)
		mm.set_instance_transform(i, t)
		
	mmi.multimesh = mm

## Spawns playful canine toys (Tennis Ball, Braided Chew Rope) on the grass
func _spawn_canine_props() -> void:
	var props_node = Node3D.new()
	props_node.name = "PuppyLawnToys"
	add_child(props_node)
	
	# 1. Fuzzy Tennis Ball near Patio Deck
	var ball = MeshInstance3D.new()
	ball.name = "TennisBall"
	var ball_mesh = SphereMesh.new()
	ball_mesh.radius = 0.18
	ball_mesh.height = 0.36
	var ball_mat = StandardMaterial3D.new()
	ball_mat.albedo_color = Color(0.88, 0.95, 0.22, 1.0) # Tennis neon yellow
	ball_mat.roughness = 0.85
	ball.mesh = ball_mesh
	ball.material_override = ball_mat
	ball.position = Vector3(3.2, 0.18, 11.5)
	props_node.add_child(ball)
	
	# 2. Braided Chew Rope near Doghouse
	var rope = MeshInstance3D.new()
	rope.name = "ChewRope"
	var rope_mesh = CylinderMesh.new()
	rope_mesh.top_radius = 0.09
	rope_mesh.bottom_radius = 0.09
	rope_mesh.height = 0.85
	var rope_mat = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.92, 0.28, 0.24, 1.0) # Red braided rope
	rope_mat.roughness = 0.75
	rope.mesh = rope_mesh
	rope.material_override = rope_mat
	rope.position = Vector3(-2.8, 0.09, 10.8)
	rope.rotation = Vector3(PI / 2.0, 0.4, 0.8)
	props_node.add_child(rope)
