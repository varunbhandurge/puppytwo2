class_name BossCorvusCrow extends Node3D

## Chapter 4 Boss: Corvus the Crow King (Aerial Canopy Sovereign)

enum CrowPhase {
	PHASE_1_PINECONE_RAIN,
	PHASE_2_GUST_BUFFET,
	PHASE_3_PERCH_KNOCKDOWN,
	DEFEATED
}

@export var boss_id: String = "boss_corvus_crow"
var current_phase: CrowPhase = CrowPhase.PHASE_1_PINECONE_RAIN
var current_health: int = 3

var pinecones_returned: int = 0
var is_root_anchored: bool = false
var is_perch_shattered: bool = false

signal phase_advanced(new_phase: int)
signal boss_defeated()

@onready var crow_visual: Node3D = get_node_or_null("CrowMesh")
@onready var wind_particles: CPUParticles3D = get_node_or_null("WindParticles")

func _ready() -> void:
	EventBus.puppy_barked.connect(_on_puppy_barked)
	start_phase(CrowPhase.PHASE_1_PINECONE_RAIN)

func start_phase(phase: CrowPhase) -> void:
	current_phase = phase
	phase_advanced.emit(int(phase))
	EventBus.boss_phase_changed.emit(boss_id, int(phase))
	
	match phase:
		CrowPhase.PHASE_1_PINECONE_RAIN:
			EventBus.notification_displayed.emit("CORVUS THE CROW KING!", "Bruno: Catch pinecones in jaws and launch them back!", 3.5)
		CrowPhase.PHASE_2_GUST_BUFFET:
			EventBus.notification_displayed.emit("PHASE 2: GALE WINDS", "Milo: Anchor in hollow root and throw tether to Bruno!", 3.5)
		CrowPhase.PHASE_3_PERCH_KNOCKDOWN:
			EventBus.notification_displayed.emit("PHASE 3: RESONANT ROAR", "Bruno: Deliver sonic bark into hollow branch!", 3.5)
		CrowPhase.DEFEATED:
			_on_boss_defeated()

# Phase 1: Return pinecone
func return_pinecone() -> void:
	if current_phase == CrowPhase.PHASE_1_PINECONE_RAIN:
		pinecones_returned += 1
		if pinecones_returned >= 2:
			apply_boss_damage(1)

# Phase 2: Anchor tether
func anchor_root_tether() -> void:
	if current_phase == CrowPhase.PHASE_2_GUST_BUFFET and not is_root_anchored:
		is_root_anchored = true
		apply_boss_damage(1)

# Phase 3: Bark into hollow perch
func _on_puppy_barked(player_id: int, _pos: Vector3, _radius: float) -> void:
	if current_phase == CrowPhase.PHASE_3_PERCH_KNOCKDOWN and player_id == 1 and not is_perch_shattered:
		is_perch_shattered = true
		apply_boss_damage(1)

func apply_boss_damage(amount: int) -> void:
	current_health -= amount
	AudioManager.play_procedural_tone(110.0, 0.35, 0.7)
	EventBus.boss_hit.emit(boss_id, amount, current_health)
	
	if current_health == 2:
		start_phase(CrowPhase.PHASE_2_GUST_BUFFET)
	elif current_health == 1:
		start_phase(CrowPhase.PHASE_3_PERCH_KNOCKDOWN)
	elif current_health <= 0:
		start_phase(CrowPhase.DEFEATED)

func _on_boss_defeated() -> void:
	current_phase = CrowPhase.DEFEATED
	if wind_particles:
		wind_particles.emitting = false
	AudioManager.play_procedural_chime(659.25, 1.2)
	EventBus.boss_defeated.emit(boss_id)
	EventBus.notification_displayed.emit("CORVUS HONORED!", "Corvus caws respectfully and yields the Forest crest!", 4.0)
	boss_defeated.emit()
	EventBus.golden_bone_collected.emit("bone_ch4_crow", GameManager.golden_bones_collected + 1)
