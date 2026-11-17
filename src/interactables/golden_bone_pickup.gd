class_name GoldenBonePickup extends Area3D

## 3D Collectible Golden Bone with Shimmering Idle Animation

@export var bone_id: String = "bone_ch1_01"
@export var rotation_speed: float = 2.0
@export var bob_amplitude: float = 0.12
@export var bob_frequency: float = 2.5

var is_collected: bool = false
var base_y: float = 0.0

@onready var bone_mesh: Node3D = get_node_or_null("BoneMesh")
@onready var sparkle_particles: CPUParticles3D = get_node_or_null("SparkleParticles")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	base_y = position.y

func _process(delta: float) -> void:
	if is_collected:
		return
	rotate_y(rotation_speed * delta)
	position.y = base_y + sin(Time.get_ticks_msec() * 0.001 * bob_frequency) * bob_amplitude

func _on_body_entered(body: Node3D) -> void:
	if is_collected:
		return
	if body is PuppyBase:
		collect()

func collect() -> void:
	is_collected = true
	GameManager.golden_bones_collected += 1
	EventBus.golden_bone_collected.emit(bone_id, GameManager.golden_bones_collected)
	
	if sparkle_particles:
		sparkle_particles.emitting = true
	
	if bone_mesh:
		var tw = create_tween()
		tw.tween_property(bone_mesh, "scale", Vector3(1.4, 1.4, 1.4), 0.15)
		tw.tween_property(bone_mesh, "scale", Vector3.ZERO, 0.2)
		tw.tween_callback(func():
			visible = false
		)
	else:
		visible = false
