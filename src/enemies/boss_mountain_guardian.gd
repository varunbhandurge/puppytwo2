class_name BossMountainGuardian extends Node3D

## Chapter 8 Climax Boss: The Mountain Guardian (Ancient Stone Mastiff)

enum GuardianPhase {
	PHASE_1_GALE_HOWL,
	PHASE_2_CRUMBLING_PILLARS,
	PHASE_3_TRIAL_OF_SELFLESSNESS,
	DEFEATED
}

@export var boss_id: String = "boss_mountain_guardian"
var current_phase: GuardianPhase = GuardianPhase.PHASE_1_GALE_HOWL
var current_health: int = 3

var is_huddled_together: bool = false
var pillars_stabilized: int = 0
var p1_wished_for_partner: bool = false
var p2_wished_for_partner: bool = false

signal phase_advanced(new_phase: int)
signal boss_defeated()

@onready var guardian_mesh: Node3D = get_node_or_null("GuardianMesh")
@onready var snow_particles: CPUParticles3D = get_node_or_null("SnowParticles")
@onready var aura_light: OmniLight3D = get_node_or_null("AuraLight")

func _ready() -> void:
	start_phase(GuardianPhase.PHASE_1_GALE_HOWL)

func start_phase(phase: GuardianPhase) -> void:
	current_phase = phase
	phase_advanced.emit(int(phase))
	EventBus.boss_phase_changed.emit(boss_id, int(phase))
	
	match phase:
		GuardianPhase.PHASE_1_GALE_HOWL:
			EventBus.notification_displayed.emit("THE MOUNTAIN GUARDIAN!", "Howling blizzards! Puppies must huddle together to push forward!", 4.0)
		GuardianPhase.PHASE_2_CRUMBLING_PILLARS:
			EventBus.notification_displayed.emit("PHASE 2: MONOLITH ASCENT", "Milo: Leap ahead to trigger runes stabilizing steps for Bruno!", 4.0)
		GuardianPhase.PHASE_3_TRIAL_OF_SELFLESSNESS:
			EventBus.notification_displayed.emit("FINAL TRIAL: SELFLESSNESS", "The shrine asks who will take the wish...", 4.0)
		GuardianPhase.DEFEATED:
			_on_boss_defeated()

# Phase 1: Huddle together
func huddle_together(active: bool) -> void:
	is_huddled_together = active
	if is_huddled_together and current_phase == GuardianPhase.PHASE_1_GALE_HOWL:
		apply_boss_damage(1)

# Phase 2: Stabilize pillars
func stabilize_pillar() -> void:
	if current_phase == GuardianPhase.PHASE_2_CRUMBLING_PILLARS:
		pillars_stabilized += 1
		if pillars_stabilized >= 2:
			apply_boss_damage(1)

# Phase 3: Trial of selflessness
func offer_wish_to_partner(player_id: int) -> void:
	if player_id == 1:
		p1_wished_for_partner = true
	elif player_id == 2:
		p2_wished_for_partner = true
		
	if current_phase == GuardianPhase.PHASE_3_TRIAL_OF_SELFLESSNESS and p1_wished_for_partner and p2_wished_for_partner:
		apply_boss_damage(1)

func apply_boss_damage(amount: int) -> void:
	current_health -= amount
	AudioManager.play_procedural_tone(110.0, 0.35, 0.7)
	EventBus.boss_hit.emit(boss_id, amount, current_health)
	
	if current_health == 2:
		start_phase(GuardianPhase.PHASE_2_CRUMBLING_PILLARS)
	elif current_health == 1:
		start_phase(GuardianPhase.PHASE_3_TRIAL_OF_SELFLESSNESS)
	elif current_health <= 0:
		start_phase(GuardianPhase.DEFEATED)

func _on_boss_defeated() -> void:
	current_phase = GuardianPhase.DEFEATED
	if aura_light:
		aura_light.light_energy = 4.0
	AudioManager.play_procedural_chime(783.99, 2.0)
	EventBus.boss_defeated.emit(boss_id)
	EventBus.notification_displayed.emit("THE LEGENDARY BONE REVEALED!", "The ancient spirit smiles; the bone illuminates your true forever home!", 6.0)
	boss_defeated.emit()
	EventBus.golden_bone_collected.emit("bone_ch8_legendary", GameManager.golden_bones_collected + 1)
