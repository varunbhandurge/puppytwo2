class_name BossApplianceGolem extends Node3D

## Chapter 3 Boss: The Kitchen Appliance Golem (Robotic Vacuum & Mixer Fusion)

enum GolemPhase {
	PHASE_1_VACUUM_VORTEX,
	PHASE_2_WHISK_FLAIL,
	PHASE_3_SHORT_CIRCUIT,
	DEFEATED
}

@export var boss_id: String = "boss_appliance_golem"
var current_phase: GolemPhase = GolemPhase.PHASE_1_VACUUM_VORTEX
var current_health: int = 3

var is_vortex_active: bool = true
var is_pan_braced: bool = false
var is_power_toggled: bool = false
var is_cord_unplugged: bool = false
var is_sponge_placed: bool = false

signal phase_advanced(new_phase: int)
signal boss_defeated()

@onready var body_mesh: Node3D = get_node_or_null("GolemMesh")
@onready var vacuum_particles: CPUParticles3D = get_node_or_null("VacuumParticles")

func _ready() -> void:
	start_phase(GolemPhase.PHASE_1_VACUUM_VORTEX)

func start_phase(phase: GolemPhase) -> void:
	current_phase = phase
	phase_advanced.emit(int(phase))
	EventBus.boss_phase_changed.emit(boss_id, int(phase))
	
	match phase:
		GolemPhase.PHASE_1_VACUUM_VORTEX:
			EventBus.notification_displayed.emit("APPLIANCE GOLEM!", "Bruno: Brace the frying pan! Milo: Vault to the power button!", 3.5)
		GolemPhase.PHASE_2_WHISK_FLAIL:
			EventBus.notification_displayed.emit("PHASE 2: WHISK FLAIL", "Milo: Unplug the cord! Bruno: Push golem into soapy puddle!", 3.5)
		GolemPhase.PHASE_3_SHORT_CIRCUIT:
			EventBus.notification_displayed.emit("PHASE 3: OVERHEAT!", "Bruno: Haul wet sponge into path to trip the fuse!", 3.5)
		GolemPhase.DEFEATED:
			_on_boss_defeated()

# Phase 1: Vacuum Vortex
func brace_frying_pan(pressed: bool) -> void:
	is_pan_braced = pressed

func vault_power_button() -> void:
	if current_phase == GolemPhase.PHASE_1_VACUUM_VORTEX and is_pan_braced and not is_power_toggled:
		is_power_toggled = true
		apply_boss_damage(1)

# Phase 2: Unplug & Push into soap
func unplug_cord() -> void:
	if current_phase == GolemPhase.PHASE_2_WHISK_FLAIL:
		is_cord_unplugged = true

func push_into_soap() -> void:
	if current_phase == GolemPhase.PHASE_2_WHISK_FLAIL and is_cord_unplugged:
		apply_boss_damage(1)

# Phase 3: Wet sponge trip
func place_wet_sponge() -> void:
	if current_phase == GolemPhase.PHASE_3_SHORT_CIRCUIT and not is_sponge_placed:
		is_sponge_placed = true
		apply_boss_damage(1)

func apply_boss_damage(amount: int) -> void:
	current_health -= amount
	AudioManager.play_procedural_tone(110.0, 0.35, 0.7)
	EventBus.boss_hit.emit(boss_id, amount, current_health)
	
	if current_health == 2:
		start_phase(GolemPhase.PHASE_2_WHISK_FLAIL)
	elif current_health == 1:
		start_phase(GolemPhase.PHASE_3_SHORT_CIRCUIT)
	elif current_health <= 0:
		start_phase(GolemPhase.DEFEATED)

func _on_boss_defeated() -> void:
	current_phase = GolemPhase.DEFEATED
	if vacuum_particles:
		vacuum_particles.emitting = false
	AudioManager.play_procedural_chime(659.25, 1.2)
	EventBus.boss_defeated.emit(boss_id)
	EventBus.notification_displayed.emit("APPLIANCE TAMED!", "The golem beeps happily! Kitchen exit unlocked!", 4.0)
	boss_defeated.emit()
	EventBus.golden_bone_collected.emit("bone_ch3_golem", GameManager.golden_bones_collected + 1)
