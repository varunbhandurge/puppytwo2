extends SceneTree

func _init() -> void:
	print("===================================================================")
	print("  CONVERTING GLB ASSETS TO NATIVE GODOT PACKED SCENES (.tscn)")
	print("===================================================================")
	var models = [
		"stylized_ancient_oak",
		"stylized_mountain_pine",
		"stylized_river_boulders",
		"stylized_hollow_log",
		"stylized_canine_monolith",
		"stylized_forest_terrain",
		"stylized_bruno_hero",
		"stylized_milo_hero"
	]
	
	for name in models:
		var glb_path = "res://src/assets/models/%s.glb" % name
		var tscn_path = "res://src/assets/models/%s.tscn" % name
		
		var gltf = GLTFDocument.new()
		var state = GLTFState.new()
		var err = gltf.append_from_file(glb_path, state)
		if err != OK:
			print("Failed to append %s: %d" % [glb_path, err])
			continue
			
		var root = gltf.generate_scene(state)
		if not root:
			print("Failed to generate scene for %s" % glb_path)
			continue
			
		# Ensure owner is set for all descendants so PackedScene saves all nodes
		_set_owner_recursive(root, root)
		
		var packed = PackedScene.new()
		var pack_err = packed.pack(root)
		if pack_err == OK:
			var save_err = ResourceSaver.save(packed, tscn_path)
			print("[PACKED] %s -> %s (status: %d)" % [glb_path, tscn_path, save_err])
		else:
			print("Failed to pack %s: %d" % [glb_path, pack_err])
			
	print("===================================================================")
	print("  ALL ASSETS SUCCESSFULLY CONVERTED TO NATIVE .tscn SCENES!")
	print("===================================================================")
	quit(0)

func _set_owner_recursive(node: Node, scene_owner: Node) -> void:
	for child in node.get_children():
		child.owner = scene_owner
		_set_owner_recursive(child, scene_owner)
