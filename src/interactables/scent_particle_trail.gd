class_name ScentParticleTrail extends Node3D

## Olfactory Scent Trail Revealed Only During Milo's Scent-o-Vision

@export var trail_id: String = "scent_trail_01"
@export var trail_color: Color = Color(0.8, 0.3, 1.0, 0.8)

@onready var particles: CPUParticles3D = get_node_or_null("CPUParticles3D")
@onready var clue_marker: MeshInstance3D = get_node_or_null("ClueMarker")

func _ready() -> void:
	EventBus.puppy_scent_toggled.connect(_on_puppy_scent_toggled)
	set_trail_visibility(false)

func _on_puppy_scent_toggled(player_id: int, is_active: bool) -> void:
	if player_id == 2: # Milo
		set_trail_visibility(is_active)

func set_trail_visibility(visible_state: bool) -> void:
	if particles:
		particles.emitting = visible_state
		particles.visible = visible_state
	if clue_marker:
		clue_marker.visible = visible_state
