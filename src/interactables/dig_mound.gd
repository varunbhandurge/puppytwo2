class_name DigMound extends Area3D

## Soft Earth Mound Excavatable Exclusively by Bruno

@export var mound_id: String = "mound_01"
@export var digs_required: int = 3
@export var reveals_item_scene: PackedScene = null

var current_dig_count: int = 0
var is_fully_excavated: bool = false
var bruno_in_range: bool = false

@onready var mound_mesh: MeshInstance3D = get_node_or_null("MoundMesh")
@onready var particles: CPUParticles3D = get_node_or_null("CPUParticles3D")

signal excavated(mound_id: String)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	EventBus.puppy_dug.connect(_on_puppy_dug)

func _on_body_entered(body: Node3D) -> void:
	if body is BrunoCharacter:
		bruno_in_range = true
		EventBus.interaction_available.emit(1, "Soft Soil Mound", "Press [F] or [Special] to Dig!")

func _on_body_exited(body: Node3D) -> void:
	if body is BrunoCharacter:
		bruno_in_range = false
		EventBus.interaction_cleared.emit(1)

func _on_puppy_dug(player_id: int, pos: Vector3) -> void:
	if is_fully_excavated:
		return
	if player_id == 1 and (bruno_in_range or global_position.distance_to(pos) < 2.0):
		perform_dig()

func perform_dig() -> void:
	current_dig_count += 1
	if particles:
		particles.emitting = true
	
	if mound_mesh:
		var tw = create_tween()
		var new_scale_y = max(0.2, 1.0 - (float(current_dig_count) / float(digs_required)) * 0.8)
		tw.tween_property(mound_mesh, "scale:y", new_scale_y, 0.15)
	
	if current_dig_count >= digs_required:
		is_fully_excavated = true
		excavated.emit(mound_id)
		EventBus.interaction_cleared.emit(1)
		EventBus.notification_displayed.emit("EXCAVATED!", "Buried path revealed!", 1.5)
		if reveals_item_scene:
			var item = reveals_item_scene.instantiate()
			get_parent().add_child(item)
			if item is Node3D:
				(item as Node3D).global_position = global_position + Vector3(0, 0.4, 0)
