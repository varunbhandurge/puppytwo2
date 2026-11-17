class_name ObjectiveBeacon extends Node3D

## In-World 3D Animated Waypoint Beacon for Cooperative Objectives

@export var beacon_title: String = "ACTIVE OBJECTIVE"
@export var beacon_instruction: String = "Cooperate here"
@export var bob_height: float = 0.25
@export var bob_speed: float = 3.0
@export var rotate_speed: float = 1.8

@onready var diamond_mesh: Node3D = get_node_or_null("Diamond")
@onready var label_3d: Label3D = get_node_or_null("Label3D")
@onready var light_3d: OmniLight3D = get_node_or_null("OmniLight3D")

var initial_y: float = 0.0

func _ready() -> void:
	initial_y = position.y
	update_text(beacon_title, beacon_instruction)

func _process(delta: float) -> void:
	if diamond_mesh:
		diamond_mesh.rotate_y(rotate_speed * delta)
	position.y = initial_y + sin(Time.get_ticks_msec() * 0.001 * bob_speed) * bob_height

func update_text(title: String, instruction: String) -> void:
	beacon_title = title
	beacon_instruction = instruction
	if label_3d:
		label_3d.text = "▼ %s ▼\n%s" % [title, instruction]
