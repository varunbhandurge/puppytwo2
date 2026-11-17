class_name BossMoleKing extends Node3D

## Chapter 7 Boss: The Mole King (Subterranean Excavation Sovereign)

enum MolePhase {
	PHASE_1_DIRT_MOUND_BREACH,
	PHASE_2_STALACTITE_SPIKES,
	PHASE_3_CROWN_DISLODGEMENT,
	DEFEATED
}

@export var boss_id: String = "boss_mole_king"
var current_phase: MolePhase = MolePhase.PHASE_1_DIRT_MOUND_BREACH
var current_health: int = 3

var is_breach_scented: bool = false
var is_pit_dug: bool = false
var stalactites_avoided: int = 0
var is_king_disoriented: bool = false
var is_crown_knocked: bool = false

signal phase_advanced(new_phase: int)
signal boss_defeated()

@onready var mole_visual: Node3D = get_node_or_null("MoleMesh")
@onready var dust_particles: CPUParticles3D = get_node_or_null("DustParticles")

func _ready() -> void:
	EventBus.puppy_scent_toggled.connect(_on_puppy_scent_toggled)
	EventBus.puppy_dug.connect(_on_puppy_dug)
	EventBus.puppy_barked.connect(_on_puppy_barked)
	start_phase(MolePhase.PHASE_1_DIRT_MOUND_BREACH)

func start_phase(phase: MolePhase) -> void:
	current_phase = phase
	phase_advanced.emit(int(phase))
	EventBus.boss_phase_changed.emit(boss_id, int(phase))
	
	match phase:
		MolePhase.PHASE_1_DIRT_MOUND_BREACH:
			EventBus.notification_displayed.emit("THE MOLE KING!", "Milo: Scent breach point! Bruno: Dig pit trap ahead!", 3.5)
		MolePhase.PHASE_2_STALACTITE_SPIKES:
			EventBus.notification_displayed.emit("PHASE 2: CAVE TREMORS", "Dodge the falling crystal stalactites!", 3.5)
		MolePhase.PHASE_3_CROWN_DISLODGEMENT:
			EventBus.notification_displayed.emit("PHASE 3: CROWN TRAP", "Bruno: Acoustic bark to stun! Milo: Knock bronze crown over eyes!", 3.5)
		MolePhase.DEFEATED:
			_on_boss_defeated()

# Phase 1: Scent & Pit
func _on_puppy_scent_toggled(player_id: int, is_active: bool) -> void:
	if current_phase == MolePhase.PHASE_1_DIRT_MOUND_BREACH and player_id == 2:
		is_breach_scented = is_active

func _on_puppy_dug(player_id: int, _pos: Vector3) -> void:
	if current_phase == MolePhase.PHASE_1_DIRT_MOUND_BREACH and player_id == 1 and is_breach_scented:
		is_pit_dug = true
		apply_boss_damage(1)

# Phase 2: Dodge stalactites
func survive_stalactite_tremor() -> void:
	if current_phase == MolePhase.PHASE_2_STALACTITE_SPIKES:
		stalactites_avoided += 1
		if stalactites_avoided >= 2:
			apply_boss_damage(1)

# Phase 3: Bark disorient & crown knock
func _on_puppy_barked(player_id: int, _pos: Vector3, _radius: float) -> void:
	if current_phase == MolePhase.PHASE_3_CROWN_DISLODGEMENT and player_id == 1:
		is_king_disoriented = true

func knock_bronze_crown() -> void:
	if current_phase == MolePhase.PHASE_3_CROWN_DISLODGEMENT and is_king_disoriented and not is_crown_knocked:
		is_crown_knocked = true
		apply_boss_damage(1)

func apply_boss_damage(amount: int) -> void:
	current_health -= amount
	AudioManager.play_procedural_tone(110.0, 0.35, 0.7)
	EventBus.boss_hit.emit(boss_id, amount, current_health)
	
	if current_health == 2:
		start_phase(MolePhase.PHASE_2_STALACTITE_SPIKES)
	elif current_health == 1:
		start_phase(MolePhase.PHASE_3_CROWN_DISLODGEMENT)
	elif current_health <= 0:
		start_phase(MolePhase.DEFEATED)

func _on_boss_defeated() -> void:
	current_phase = MolePhase.DEFEATED
	if dust_particles:
		dust_particles.emitting = false
	AudioManager.play_procedural_chime(659.25, 1.2)
	EventBus.boss_defeated.emit(boss_id)
	EventBus.notification_displayed.emit("MOLE KING BEFRIENDED!", "The Mole King clears the minecart track to the mountain!", 4.0)
	boss_defeated.emit()
	EventBus.golden_bone_collected.emit("bone_ch7_mole", GameManager.golden_bones_collected + 1)
