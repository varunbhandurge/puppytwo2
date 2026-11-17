class_name BossRiverBullfrog extends Node3D

## Chapter 5 Boss: The Grand River Bullfrog (Territorial Amphibian Sovereign)

enum FrogPhase {
	PHASE_1_TONGUE_LASH,
	PHASE_2_BELLY_WAVE,
	PHASE_3_SLUICE_FLOTATION,
	DEFEATED
}

@export var boss_id: String = "boss_river_bullfrog"
var current_phase: FrogPhase = FrogPhase.PHASE_1_TONGUE_LASH
var current_health: int = 3

var is_tongue_bitten: bool = false
var waves_cleared: int = 0
var p1_sluice_cranked: bool = false
var p2_sluice_cranked: bool = false

signal phase_advanced(new_phase: int)
signal boss_defeated()

@onready var frog_visual: Node3D = get_node_or_null("FrogMesh")
@onready var splash_particles: CPUParticles3D = get_node_or_null("SplashParticles")

func _ready() -> void:
	start_phase(FrogPhase.PHASE_1_TONGUE_LASH)

func start_phase(phase: FrogPhase) -> void:
	current_phase = phase
	phase_advanced.emit(int(phase))
	EventBus.boss_phase_changed.emit(boss_id, int(phase))
	
	match phase:
		FrogPhase.PHASE_1_TONGUE_LASH:
			EventBus.notification_displayed.emit("GRAND RIVER BULLFROG!", "Partner must bite the extended tongue to tickle-stun!", 3.5)
		FrogPhase.PHASE_2_BELLY_WAVE:
			EventBus.notification_displayed.emit("PHASE 2: TIDAL WAVE", "Jump over the expanding river waves in sync!", 3.5)
		FrogPhase.PHASE_3_SLUICE_FLOTATION:
			EventBus.notification_displayed.emit("PHASE 3: FLOOD THE BANK", "Turn both waterwheel levers to float the frog onto mud!", 3.5)
		FrogPhase.DEFEATED:
			_on_boss_defeated()

# Phase 1: Bite extended tongue
func bite_extended_tongue() -> void:
	if current_phase == FrogPhase.PHASE_1_TONGUE_LASH and not is_tongue_bitten:
		is_tongue_bitten = true
		apply_boss_damage(1)

# Phase 2: Jump waves
func clear_tidal_wave() -> void:
	if current_phase == FrogPhase.PHASE_2_BELLY_WAVE:
		waves_cleared += 1
		if waves_cleared >= 2:
			apply_boss_damage(1)

# Phase 3: Dual waterwheel sluice cranks
func crank_sluice(player_id: int) -> void:
	if player_id == 1:
		p1_sluice_cranked = true
	elif player_id == 2:
		p2_sluice_cranked = true
		
	if current_phase == FrogPhase.PHASE_3_SLUICE_FLOTATION and p1_sluice_cranked and p2_sluice_cranked:
		apply_boss_damage(1)

func apply_boss_damage(amount: int) -> void:
	current_health -= amount
	AudioManager.play_procedural_tone(110.0, 0.35, 0.7)
	EventBus.boss_hit.emit(boss_id, amount, current_health)
	
	if current_health == 2:
		start_phase(FrogPhase.PHASE_2_BELLY_WAVE)
	elif current_health == 1:
		start_phase(FrogPhase.PHASE_3_SLUICE_FLOTATION)
	elif current_health <= 0:
		start_phase(FrogPhase.DEFEATED)

func _on_boss_defeated() -> void:
	current_phase = FrogPhase.DEFEATED
	if splash_particles:
		splash_particles.emitting = false
	AudioManager.play_procedural_chime(659.25, 1.2)
	EventBus.boss_defeated.emit(boss_id)
	EventBus.notification_displayed.emit("BULLFROG CONTENT!", "The frog sunbathes peacefully; river path opened!", 4.0)
	boss_defeated.emit()
	EventBus.golden_bone_collected.emit("bone_ch5_frog", GameManager.golden_bones_collected + 1)
