class_name BrunoCharacter extends PuppyBase

## Bruno: The Golden Retriever Pup (Strength, Digging, Heavy Push, Booming Bark)

@export var dig_radius: float = 2.0
@export var push_force: float = 18.0

func _init() -> void:
	player_id = 1
	puppy_name = "Bruno"
	walk_speed = 4.8
	sprint_speed = 7.6
	jump_velocity = 7.0

func _handle_input_actions(cmd: InputManagerSingleton.PuppyCommand) -> void:
	super._handle_input_actions(cmd)
	
	if cmd.special_just_pressed:
		execute_mighty_dig()
	
	# Bruno snout boost stance: Hold interact when standing still
	if cmd.interact_held and velocity.length_squared() < 0.1:
		if not is_boosting_partner:
			enter_boost_stance()
	else:
		if is_boosting_partner:
			exit_boost_stance()

func execute_mighty_dig() -> void:
	var dig_pos = global_position if is_inside_tree() else position
	EventBus.puppy_dug.emit(player_id, dig_pos)
	# Trigger head/paw digging animation recoil
	if head_node and is_inside_tree():
		var tw = create_tween()
		tw.tween_property(head_node, "rotation:x", 0.4, 0.08)
		tw.tween_property(head_node, "rotation:x", -0.1, 0.1)
		tw.tween_property(head_node, "rotation:x", 0.0, 0.08)

func enter_boost_stance() -> void:
	is_boosting_partner = true
	EventBus.snout_boost_initiated.emit(player_id, 2)
	# Lower head and front paws
	if head_node:
		head_node.position.y = -0.1
	if body_mesh:
		body_mesh.rotation.x = 0.2

func exit_boost_stance() -> void:
	is_boosting_partner = false
	if head_node:
		head_node.position.y = 0.0
	if body_mesh:
		body_mesh.rotation.x = 0.0

## Check for rigid bodies to push
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		if collider is RigidBody3D:
			var push_dir = -col.get_normal()
			push_dir.y = 0
			collider.apply_central_impulse(push_dir.normalized() * push_force * delta)
