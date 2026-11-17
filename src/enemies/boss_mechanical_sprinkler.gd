class_name BossMechanicalSprinkler extends Node3D

## Chapter 1 Boss: The Mechanical Sprinkler (Brass Irrigation Turret)

enum SprinklerPhase {
	PHASE_1_ROTATING_JETS,
	PHASE_2_HYDRO_MORTAR,
	PHASE_3_OVERCHARGED_SPIN,
	DEFEATED
}

@export var boss_id: String = "boss_sprinkler"
@export var rotation_speed: float = 2.4

var current_phase: SprinklerPhase = SprinklerPhase.PHASE_1_ROTATING_JETS
var current_health: int = 3

# Phase 1 mechanics
var is_deflector_down: bool = false
var is_intake_unbolted: bool = false

# Phase 2 mechanics
var is_pipe_scented: bool = false
var is_pipe_excavated: bool = false

# Phase 3 mechanics
var p1_holding_handle: bool = false
var p2_holding_handle: bool = false

signal phase_advanced(new_phase: int)
signal boss_defeated()

@onready var turret_mesh: Node3D = get_node_or_null("TurretMesh")
@onready var water_jets: CPUParticles3D = get_node_or_null("WaterJets")
@onready var deflector_plate: Node3D = get_node_or_null("DeflectorPlate")

func _ready() -> void:
	EventBus.puppy_scent_toggled.connect(_on_puppy_scent_toggled)
	EventBus.puppy_dug.connect(_on_puppy_dug)
	start_phase(SprinklerPhase.PHASE_1_ROTATING_JETS)

func start_phase(phase: SprinklerPhase) -> void:
	current_phase = phase
	phase_advanced.emit(int(phase))
	EventBus.boss_phase_changed.emit(boss_id, int(phase))
	
	match phase:
		SprinklerPhase.PHASE_1_ROTATING_JETS:
			rotation_speed = 2.4
			EventBus.notification_displayed.emit("THE MECHANICAL SPRINKLER!", "Bruno: Step on deflector pedal! Milo: Unbolt the intake!", 3.5)
		SprinklerPhase.PHASE_2_HYDRO_MORTAR:
			rotation_speed = 3.6
			EventBus.notification_displayed.emit("PHASE 2: HYDRO-MORTAR", "Milo: Scent underground pipe! Bruno: Dig up the supply line!", 3.5)
		SprinklerPhase.PHASE_3_OVERCHARGED_SPIN:
			rotation_speed = 5.2
			EventBus.notification_displayed.emit("PHASE 3: OVERCHARGE!", "Pull both emergency shutoff handles together!", 3.5)
		SprinklerPhase.DEFEATED:
			_on_boss_defeated()

func _physics_process(delta: float) -> void:
	if current_phase == SprinklerPhase.DEFEATED:
		return
		
	# Turret spins furiously
	if turret_mesh:
		turret_mesh.rotate_y(rotation_speed * delta)

# Phase 1: Deflector & Intake
func set_deflector_plate(pressed: bool) -> void:
	is_deflector_down = pressed
	if deflector_plate:
		var tw = create_tween()
		var target_y = -0.5 if pressed else 0.0
		tw.tween_property(deflector_plate, "position:y", target_y, 0.2)

func unbolt_intake() -> void:
	if current_phase == SprinklerPhase.PHASE_1_ROTATING_JETS and is_deflector_down and not is_intake_unbolted:
		is_intake_unbolted = true
		apply_boss_damage(1)

# Phase 2: Scent & Dig
func _on_puppy_scent_toggled(player_id: int, is_active: bool) -> void:
	if current_phase == SprinklerPhase.PHASE_2_HYDRO_MORTAR and player_id == 2:
		is_pipe_scented = is_active

func _on_puppy_dug(player_id: int, _pos: Vector3) -> void:
	if current_phase == SprinklerPhase.PHASE_2_HYDRO_MORTAR and player_id == 1 and is_pipe_scented:
		is_pipe_excavated = true
		apply_boss_damage(1)

# Phase 3: Dual Handles
func set_handle_state(player_id: int, is_holding: bool) -> void:
	if player_id == 1:
		p1_holding_handle = is_holding
	elif player_id == 2:
		p2_holding_handle = is_holding
		
	if current_phase == SprinklerPhase.PHASE_3_OVERCHARGED_SPIN and p1_holding_handle and p2_holding_handle:
		apply_boss_damage(1)

func apply_boss_damage(amount: int) -> void:
	current_health -= amount
	AudioManager.play_procedural_tone(110.0, 0.35, 0.7)
	EventBus.boss_hit.emit(boss_id, amount, current_health)
	
	if current_health == 2:
		start_phase(SprinklerPhase.PHASE_2_HYDRO_MORTAR)
	elif current_health == 1:
		start_phase(SprinklerPhase.PHASE_3_OVERCHARGED_SPIN)
	elif current_health <= 0:
		start_phase(SprinklerPhase.DEFEATED)

func _on_boss_defeated() -> void:
	current_phase = SprinklerPhase.DEFEATED
	if water_jets:
		water_jets.emitting = false
	AudioManager.play_procedural_chime(659.25, 1.2)
	EventBus.boss_defeated.emit(boss_id)
	EventBus.notification_displayed.emit("SPRINKLER SHUT DOWN!", "The water subsides! Backyard gate unlocked!", 4.0)
	boss_defeated.emit()
	EventBus.golden_bone_collected.emit("bone_ch1_sprinkler", GameManager.golden_bones_collected + 1)
