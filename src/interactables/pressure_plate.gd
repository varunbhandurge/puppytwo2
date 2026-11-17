class_name PressurePlate extends Area3D

## Interactive Mechanical Pressure Plate for Cooperative Weight Puzzles

@export var plate_id: String = "plate_01"
@export var required_mass: float = 10.0
@export var is_latched_once_pressed: bool = false

var is_pressed: bool = false
var bodies_on_plate: Array[Node3D] = []

@onready var plate_mesh: MeshInstance3D = get_node_or_null("PlateMesh")
var original_plate_y: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if plate_mesh:
		original_plate_y = plate_mesh.position.y

func _on_body_entered(body: Node3D) -> void:
	if not bodies_on_plate.has(body):
		bodies_on_plate.append(body)
	_evaluate_pressure()

func _on_body_exited(body: Node3D) -> void:
	bodies_on_plate.erase(body)
	if not is_latched_once_pressed:
		_evaluate_pressure()

func _evaluate_pressure() -> void:
	var had_weight = is_pressed
	is_pressed = bodies_on_plate.size() > 0
	
	if is_pressed != had_weight:
		EventBus.pressure_plate_activated.emit(plate_id, is_pressed)
		_animate_plate(is_pressed)

func _animate_plate(pressed: bool) -> void:
	if not plate_mesh:
		return
	var tw = create_tween()
	var target_y = original_plate_y - 0.08 if pressed else original_plate_y
	tw.tween_property(plate_mesh, "position:y", target_y, 0.12)
	
	if pressed:
		AudioManager.play_procedural_tone(180.0, 0.15, 0.4)
