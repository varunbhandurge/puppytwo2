class_name PuppyBase extends CharacterBody3D

## Foundational Quadruped Character Controller for Two Puppies

@export var player_id: int = 1
@export var puppy_name: String = "Puppy"
@export var walk_speed: float = 4.8
@export var sprint_speed: float = 7.5
@export var jump_velocity: float = 7.2
@export var turn_speed: float = 14.0
@export var gravity: float = 18.0

# State flags
var is_sprinting: bool = false
var is_crawling: bool = false
var is_stunned: bool = false
var is_boosting_partner: bool = false
var can_move: bool = true

enum EmotionalState {
	NORMAL,
	CELEBRATING,
	COWERING,
	HUDDLING,
	SHAKING_DRY,
	RESTING
}

var current_emotion: EmotionalState = EmotionalState.NORMAL
var emotion_timer: float = 0.0
var emotion_duration: float = 0.0
var huddle_target: Vector3 = Vector3.ZERO

# Interaction detection
var nearby_interactable: Area3D = null

# Visual model references for procedural quadruped animation
@onready var visual_root: Node3D = $VisualRoot
@onready var body_mesh: MeshInstance3D = $VisualRoot/Body
@onready var head_node: Node3D = $VisualRoot/Head
@onready var tail_node: Node3D = $VisualRoot/Tail
@onready var left_ear_node: Node3D = $VisualRoot/Head/LeftEar
@onready var right_ear_node: Node3D = $VisualRoot/Head/RightEar
@onready var leg_fl: Node3D = $VisualRoot/LegFL
@onready var leg_fr: Node3D = $VisualRoot/LegFR
@onready var leg_rl: Node3D = $VisualRoot/LegRL
@onready var leg_rr: Node3D = $VisualRoot/LegRR
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var collar_mesh: MeshInstance3D = get_node_or_null("VisualRoot/Collar")
@onready var collar_tag_mesh: MeshInstance3D = get_node_or_null("VisualRoot/CollarTag")

var anim_phase: float = 0.0
var original_capsule_height: float = 0.6

func _ready() -> void:
	GameManager.register_player(player_id, self)
	if collision_shape and collision_shape.shape is CapsuleShape3D:
		original_capsule_height = (collision_shape.shape as CapsuleShape3D).height
	
	EventBus.customization_updated.connect(func(p1_d, p2_d):
		apply_customization(p1_d if player_id == 1 else p2_d)
	)
	if SaveManager:
		apply_customization(SaveManager.get_customization())

func apply_customization(custom_dict: Dictionary) -> void:
	var prefix = "p1" if player_id == 1 else "p2"
	var name_key = prefix + "_name"
	if custom_dict.has(name_key):
		puppy_name = str(custom_dict[name_key])
		
	var col_key = prefix + "_collar_color"
	if custom_dict.has(col_key) and collar_mesh:
		var arr = custom_dict[col_key]
		if arr is Array and arr.size() >= 3:
			var c = Color(arr[0], arr[1], arr[2], arr[3] if arr.size() > 3 else 1.0)
			var mat = StandardMaterial3D.new()
			mat.albedo_color = c
			mat.roughness = 0.4
			collar_mesh.material_override = mat

func _physics_process(delta: float) -> void:
	if is_stunned:
		_apply_gravity(delta)
		move_and_slide()
		return
	
	var cmd: InputManagerSingleton.PuppyCommand = InputManager.get_player_command(player_id)
	
	_handle_input_actions(cmd)
	_handle_movement(cmd, delta)
	_apply_gravity(delta)
	_animate_quadruped_procedural(delta)
	
	move_and_slide()
	EventBus.puppy_moved.emit(player_id, global_position)
	
	# Void boundary check
	if is_inside_tree() and global_position.y < -15.0:
		EventBus.request_respawn.emit(player_id)

func _handle_input_actions(cmd: InputManagerSingleton.PuppyCommand) -> void:
	if not can_move:
		return
		
	if cmd.jump_just_pressed and is_on_floor():
		velocity.y = jump_velocity
		EventBus.puppy_jumped.emit(player_id)
	
	if cmd.bark_just_pressed:
		execute_bark()
	
	if cmd.interact_just_pressed and nearby_interactable != null:
		if nearby_interactable.has_method("on_interact"):
			nearby_interactable.on_interact(self)

func _handle_movement(cmd: InputManagerSingleton.PuppyCommand, delta: float) -> void:
	if not can_move:
		velocity.x = move_toward(velocity.x, 0.0, 15.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 15.0 * delta)
		return
		
	var target_speed = sprint_speed if cmd.sprint_held and not is_crawling else walk_speed
	if is_crawling:
		target_speed *= 0.5
	
	# Determine camera relative forward/right vectors if camera is available
	var move_dir: Vector3 = Vector3(cmd.move_vector.x, 0, cmd.move_vector.y)
	
	if move_dir.length_squared() > 0.01:
		velocity.x = move_toward(velocity.x, move_dir.x * target_speed, 25.0 * delta)
		velocity.z = move_toward(velocity.z, move_dir.z * target_speed, 25.0 * delta)
		
		# Smooth rotation towards move direction
		var target_yaw = atan2(-move_dir.x, -move_dir.z)
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_yaw, turn_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 20.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 20.0 * delta)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func _animate_quadruped_procedural(delta: float) -> void:
	# Check emotion duration expiration
	if emotion_duration > 0.0:
		emotion_timer += delta
		if emotion_timer >= emotion_duration:
			set_emotion(EmotionalState.NORMAL)

	var horiz_speed = Vector2(velocity.x, velocity.z).length()
	
	# Emotional overrides
	if current_emotion == EmotionalState.CELEBRATING:
		_animate_celebrating(delta)
		return
	elif current_emotion == EmotionalState.COWERING:
		_animate_cowering(delta)
		return
	elif current_emotion == EmotionalState.HUDDLING:
		_animate_huddling(delta)
		return
	elif current_emotion == EmotionalState.SHAKING_DRY:
		_animate_shaking_dry(delta)
		return
	elif current_emotion == EmotionalState.RESTING:
		_animate_resting(delta)
		return

	# Reset visual root roll/offset if coming from special emotions
	if visual_root:
		visual_root.position.x = lerp(visual_root.position.x, 0.0, 10.0 * delta)
		visual_root.rotation.z = lerp(visual_root.rotation.z, 0.0, 10.0 * delta)

	# Tail wagging physics (faster wag when excited or moving)
	var wag_speed = 8.0 if horiz_speed < 0.2 else 16.0
	var wag_amplitude = 0.35 if horiz_speed < 0.2 else 0.65
	if tail_node:
		tail_node.rotation.y = sin(Time.get_ticks_msec() * 0.001 * wag_speed) * wag_amplitude
		tail_node.rotation.x = -0.3 + sin(Time.get_ticks_msec() * 0.001 * (wag_speed * 0.5)) * 0.1
	
	# Leg trotting animation
	if horiz_speed > 0.3 and is_on_floor():
		anim_phase += delta * horiz_speed * 3.5
		var leg_swing = sin(anim_phase) * 0.45
		if leg_fl and leg_rr and leg_fr and leg_rl:
			leg_fl.rotation.x = leg_swing
			leg_rr.rotation.x = leg_swing
			leg_fr.rotation.x = -leg_swing
			leg_rl.rotation.x = -leg_swing
		
		# Gentle spine bobbing
		if body_mesh:
			body_mesh.position.y = abs(sin(anim_phase * 2.0)) * 0.04
	else:
		# Return legs to rest position
		if leg_fl and leg_rr and leg_fr and leg_rl:
			leg_fl.rotation.x = lerp(leg_fl.rotation.x, 0.0, 10.0 * delta)
			leg_rr.rotation.x = lerp(leg_rr.rotation.x, 0.0, 10.0 * delta)
			leg_fr.rotation.x = lerp(leg_fr.rotation.x, 0.0, 10.0 * delta)
			leg_rl.rotation.x = lerp(leg_rl.rotation.x, 0.0, 10.0 * delta)
		if body_mesh:
			body_mesh.position.y = lerp(body_mesh.position.y, 0.0, 8.0 * delta)
	
	# Ear flutters
	if left_ear_node and right_ear_node:
		var ear_bounce = sin(Time.get_ticks_msec() * 0.008) * 0.08
		left_ear_node.rotation.z = -0.2 + ear_bounce
		right_ear_node.rotation.z = 0.2 - ear_bounce

func _animate_celebrating(delta: float) -> void:
	var t = Time.get_ticks_msec() * 0.001
	if tail_node:
		tail_node.rotation.y = sin(t * 26.0) * 0.8
		tail_node.rotation.x = -0.6 # High upright wag
	if head_node:
		head_node.rotation.x = -0.3 + sin(t * 8.0) * 0.15
	if body_mesh:
		body_mesh.position.y = 0.06 + abs(sin(t * 10.0)) * 0.08
	if leg_fl and leg_fr:
		leg_fl.rotation.x = -0.6 + sin(t * 12.0) * 0.3
		leg_fr.rotation.x = -0.6 - sin(t * 12.0) * 0.3
	if leg_rl and leg_rr:
		leg_rl.rotation.x = lerp(leg_rl.rotation.x, 0.1, 10.0 * delta)
		leg_rr.rotation.x = lerp(leg_rr.rotation.x, 0.1, 10.0 * delta)

func _animate_cowering(delta: float) -> void:
	var t = Time.get_ticks_msec() * 0.001
	if tail_node:
		tail_node.rotation.x = lerp(tail_node.rotation.x, 0.6, 8.0 * delta) # Tucked between legs
		tail_node.rotation.y = sin(t * 40.0) * 0.05 # Micro tremor
	if head_node:
		head_node.rotation.x = lerp(head_node.rotation.x, 0.3, 8.0 * delta) # Lowered head
	if body_mesh:
		body_mesh.position.y = lerp(body_mesh.position.y, -0.08, 8.0 * delta) # Low crouch
	if left_ear_node and right_ear_node:
		left_ear_node.rotation.z = lerp(left_ear_node.rotation.z, -0.4, 8.0 * delta) # Flat back ears
		right_ear_node.rotation.z = lerp(right_ear_node.rotation.z, 0.4, 8.0 * delta)

func _animate_huddling(delta: float) -> void:
	var t = Time.get_ticks_msec() * 0.001
	if tail_node:
		tail_node.rotation.y = sin(t * 6.0) * 0.25 # Slow warm wag
		tail_node.rotation.x = -0.2
	if head_node:
		head_node.rotation.x = 0.1
		head_node.rotation.z = sin(t * 4.0) * 0.1 # Gentle lean
	if body_mesh:
		body_mesh.position.y = lerp(body_mesh.position.y, -0.04, 6.0 * delta)
	if left_ear_node and right_ear_node:
		left_ear_node.rotation.z = -0.15
		right_ear_node.rotation.z = 0.15

func _animate_shaking_dry(delta: float) -> void:
	var t = Time.get_ticks_msec() * 0.001
	var shake = sin(t * 38.0)
	if body_mesh:
		body_mesh.rotation.z = shake * 0.32
	if head_node:
		head_node.rotation.z = -shake * 0.45
	if tail_node:
		tail_node.rotation.y = -shake * 0.6

func _animate_resting(delta: float) -> void:
	if body_mesh:
		body_mesh.position.y = lerp(body_mesh.position.y, -0.12, 6.0 * delta)
	if head_node:
		head_node.rotation.x = lerp(head_node.rotation.x, 0.22, 6.0 * delta)
	if tail_node:
		tail_node.rotation.x = lerp(tail_node.rotation.x, 0.1, 6.0 * delta)
		tail_node.rotation.y = 0.0
	if leg_fl and leg_fr and leg_rl and leg_rr:
		leg_fl.rotation.x = lerp(leg_fl.rotation.x, 0.4, 6.0 * delta)
		leg_fr.rotation.x = lerp(leg_fr.rotation.x, 0.4, 6.0 * delta)

func set_emotion(state: EmotionalState, duration: float = 0.0) -> void:
	current_emotion = state
	emotion_timer = 0.0
	emotion_duration = duration
	var emotion_name = EmotionalState.keys()[state]
	EventBus.puppy_emotion_changed.emit(player_id, emotion_name)

func celebrate(duration: float = 2.5) -> void:
	set_emotion(EmotionalState.CELEBRATING, duration)
	AudioManager.play_puppy_excited_bark(player_id)

func cower(duration: float = 2.5) -> void:
	set_emotion(EmotionalState.COWERING, duration)
	AudioManager.play_puppy_whimper(player_id)

func huddle(target_pos: Vector3 = Vector3.ZERO, duration: float = 3.5) -> void:
	huddle_target = target_pos
	set_emotion(EmotionalState.HUDDLING, duration)

func shake_dry(duration: float = 1.2) -> void:
	set_emotion(EmotionalState.SHAKING_DRY, duration)
	AudioManager.play_water_splash()

func rest(duration: float = 3.0) -> void:
	set_emotion(EmotionalState.RESTING, duration)

func execute_bark() -> void:
	EventBus.puppy_barked.emit(player_id, global_position, 8.0)
	# Visual head recoil
	if head_node:
		var tw = create_tween()
		tw.tween_property(head_node, "rotation:x", -0.35, 0.08)
		tw.tween_property(head_node, "rotation:x", 0.0, 0.14)

func reset_velocity() -> void:
	velocity = Vector3.ZERO

func apply_stun(duration: float) -> void:
	is_stunned = true
	can_move = false
	EventBus.puppy_stunned.emit(player_id, duration)
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(func():
		is_stunned = false
		can_move = true
		EventBus.puppy_revived.emit(player_id)
	)
