class_name CheckpointZone extends Area3D

## Safe Checkpoint Zone Saving Player Progress

@export var checkpoint_id: String = "checkpoint_01"
@export var is_one_shot: bool = true

var is_activated: bool = false
@onready var beacon_mesh: MeshInstance3D = get_node_or_null("BeaconMesh")
@onready var light: OmniLight3D = get_node_or_null("OmniLight3D")

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if is_activated and is_one_shot:
		return
		
	if body is PuppyBase:
		activate_checkpoint()

func activate_checkpoint() -> void:
	is_activated = true
	EventBus.checkpoint_reached.emit(checkpoint_id, global_position)
	
	if light:
		var tw = create_tween()
		tw.tween_property(light, "light_energy", 3.5, 0.2)
		tw.tween_property(light, "light_energy", 1.2, 0.4)
	
	AudioManager.play_procedural_chime(587.33, 0.5)
