class_name MiloCharacter extends PuppyBase

## Milo: The Tri-Color Corgi Pup (Agility, Scent-o-Vision, Low Crawl, Precision Jump)

var is_scent_vision_active: bool = false
@export var scent_range: float = 12.0

func _init() -> void:
	player_id = 2
	puppy_name = "Milo"
	walk_speed = 4.6
	sprint_speed = 7.8
	jump_velocity = 7.6
	turn_speed = 18.0

func _handle_input_actions(cmd: InputManagerSingleton.PuppyCommand) -> void:
	super._handle_input_actions(cmd)
	
	# Scent-o-Vision toggle
	if cmd.special_just_pressed:
		toggle_scent_vision()
	
	# Low Crawl toggle
	if cmd.sprint_held and is_on_floor() and not is_sprinting:
		# Double-mapped or custom crawl action
		pass
	
	# Check for proximity to Bruno if Bruno is boosting
	if cmd.jump_just_pressed and is_on_floor():
		_check_snout_boost_jump()

func toggle_scent_vision() -> void:
	is_scent_vision_active = !is_scent_vision_active
	EventBus.puppy_scent_toggled.emit(player_id, is_scent_vision_active)
	var state_txt = "ACTIVATED" if is_scent_vision_active else "DEACTIVATED"
	EventBus.notification_displayed.emit("SCENT-O-VISION", state_txt, 1.5)

func toggle_low_crawl(enable: bool) -> void:
	is_crawling = enable
	EventBus.puppy_crawl_toggled.emit(player_id, is_crawling)
	
	if collision_shape and collision_shape.shape is CapsuleShape3D:
		var cap = collision_shape.shape as CapsuleShape3D
		cap.height = 0.25 if is_crawling else original_capsule_height
		collision_shape.position.y = 0.15 if is_crawling else 0.3
	
	if body_mesh:
		body_mesh.position.y = -0.1 if is_crawling else 0.0

func _check_snout_boost_jump() -> void:
	var bruno = GameManager.player_1_node
	if is_instance_valid(bruno) and bruno is BrunoCharacter:
		if bruno.is_boosting_partner and global_position.distance_to(bruno.global_position) < 2.0:
			# Perform high snout boost leap!
			velocity.y = 11.0 # Super boost jump!
			EventBus.snout_boost_completed.emit(1, 2)
			EventBus.notification_displayed.emit("SNOUT BOOST!", "Super jump executed!", 1.5)
