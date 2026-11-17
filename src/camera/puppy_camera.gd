class_name PuppyCamera extends Node3D

## Third-Person Predictive Spring-Arm Camera for Canine Protagonists

@export var target: Node3D = null
@export var follow_distance: float = 3.6
@export var follow_height: float = 1.4
@export var smooth_speed: float = 8.0
@export var look_ahead_factor: float = 0.4
@export var pitch_min: float = -35.0
@export var pitch_max: float = 65.0

var current_yaw: float = 0.0
var current_pitch: float = 18.0

@onready var camera: Camera3D = get_node_or_null("Camera3D")
@onready var raycast: RayCast3D = get_node_or_null("RayCast3D")

func _ready() -> void:
	if not camera:
		camera = Camera3D.new()
		camera.name = "Camera3D"
		camera.current = true
		add_child(camera)
		
	# Configure Cinematic Macro Camera Attributes (Tilt-Shift Miniature Aesthetics)
	var cam_attr = CameraAttributesPractical.new()
	cam_attr.dof_blur_far_enabled = true
	cam_attr.dof_blur_far_distance = 20.0
	cam_attr.dof_blur_far_transition = 10.0
	cam_attr.dof_blur_near_enabled = true
	cam_attr.dof_blur_near_distance = 1.0
	cam_attr.dof_blur_near_transition = 0.6
	cam_attr.dof_blur_amount = 0.07
	camera.attributes = cam_attr
		
	if not raycast:
		raycast = RayCast3D.new()
		raycast.name = "RayCast3D"
		raycast.enabled = true
		raycast.collision_mask = 1 # World Static
		add_child(raycast)

func _physics_process(delta: float) -> void:
	if not is_inside_tree() or not is_instance_valid(target):
		return
	
	# Predictive target position using velocity
	var target_vel = Vector3.ZERO
	if target is CharacterBody3D:
		target_vel = (target as CharacterBody3D).velocity
	
	var predicted_pos = target.global_position + Vector3(0, follow_height, 0)
	predicted_pos += Vector3(target_vel.x, 0, target_vel.z) * look_ahead_factor
	
	global_position = global_position.lerp(predicted_pos, smooth_speed * delta)
	
	# Calculate ideal camera offset based on yaw and pitch
	var rad_yaw = deg_to_rad(current_yaw)
	var rad_pitch = deg_to_rad(current_pitch)
	
	var offset = Vector3(
		sin(rad_yaw) * cos(rad_pitch) * follow_distance,
		sin(rad_pitch) * follow_distance,
		cos(rad_yaw) * cos(rad_pitch) * follow_distance
	)
	
	# Occlusion test: raycast from puppy to ideal camera position
	raycast.target_position = offset
	raycast.force_raycast_update()
	
	var actual_offset = offset
	if raycast.is_colliding():
		var col_point = raycast.get_collision_point()
		var dist_to_col = global_position.distance_to(col_point)
		actual_offset = offset.normalized() * max(0.8, dist_to_col - 0.2)
	
	camera.global_position = global_position + actual_offset
	camera.look_at(global_position + Vector3(0, 0.2, 0), Vector3.UP)
