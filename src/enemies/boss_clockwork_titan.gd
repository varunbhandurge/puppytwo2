class_name BossClockworkTitan extends Node3D

## Chapter 6 Boss: The Clockwork Toy Titan (Assembly-Line Steampunk Golem)

enum TitanPhase {
	PHASE_1_STAMPING_HAMMER,
	PHASE_2_WINDUP_SWARM,
	PHASE_3_TRIPLE_KEY_LOCK,
	DEFEATED
}

@export var boss_id: String = "boss_clockwork_titan"
var current_phase: TitanPhase = TitanPhase.PHASE_1_STAMPING_HAMMER
var current_health: int = 3

var hammer_dodged: bool = false
var mice_dispersed: bool = false
var leg_joints_disarmed: bool = false
var gear_jammed: bool = false
var head_key_pulled: bool = false

signal phase_advanced(new_phase: int)
signal boss_defeated()

@onready var titan_visual: Node3D = get_node_or_null("TitanMesh")
@onready var spark_particles: CPUParticles3D = get_node_or_null("SparkParticles")

func _ready() -> void:
	EventBus.puppy_barked.connect(_on_puppy_barked)
	start_phase(TitanPhase.PHASE_1_STAMPING_HAMMER)

func start_phase(phase: TitanPhase) -> void:
	current_phase = phase
	phase_advanced.emit(int(phase))
	EventBus.boss_phase_changed.emit(boss_id, int(phase))
	
	match phase:
		TitanPhase.PHASE_1_STAMPING_HAMMER:
			EventBus.notification_displayed.emit("CLOCKWORK TOY TITAN!", "Dodge the stamping hammer onto the reverse conveyor!", 3.5)
		TitanPhase.PHASE_2_WINDUP_SWARM:
			EventBus.notification_displayed.emit("PHASE 2: TOY MICE SWARM", "Bruno: Disperse mice with barks! Milo: Disarm leg gears!", 3.5)
		TitanPhase.PHASE_3_TRIPLE_KEY_LOCK:
			EventBus.notification_displayed.emit("PHASE 3: TRIPLE KEY", "Bruno: Jam main drive girder! Milo: Pull head key!", 3.5)
		TitanPhase.DEFEATED:
			_on_boss_defeated()

# Phase 1: Dodge & Conveyor
func lure_hammer_to_conveyor() -> void:
	if current_phase == TitanPhase.PHASE_1_STAMPING_HAMMER and not hammer_dodged:
		hammer_dodged = true
		apply_boss_damage(1)

# Phase 2: Bark mice & disarm leg
func _on_puppy_barked(player_id: int, _pos: Vector3, _radius: float) -> void:
	if current_phase == TitanPhase.PHASE_2_WINDUP_SWARM and player_id == 1:
		mice_dispersed = true

func disarm_leg_joint() -> void:
	if current_phase == TitanPhase.PHASE_2_WINDUP_SWARM and mice_dispersed and not leg_joints_disarmed:
		leg_joints_disarmed = true
		apply_boss_damage(1)

# Phase 3: Jam girder & pull key
func jam_drive_girder() -> void:
	if current_phase == TitanPhase.PHASE_3_TRIPLE_KEY_LOCK:
		gear_jammed = true

func pull_head_key() -> void:
	if current_phase == TitanPhase.PHASE_3_TRIPLE_KEY_LOCK and gear_jammed and not head_key_pulled:
		head_key_pulled = true
		apply_boss_damage(1)

func apply_boss_damage(amount: int) -> void:
	current_health -= amount
	AudioManager.play_procedural_tone(110.0, 0.35, 0.7)
	EventBus.boss_hit.emit(boss_id, amount, current_health)
	
	if current_health == 2:
		start_phase(TitanPhase.PHASE_2_WINDUP_SWARM)
	elif current_health == 1:
		start_phase(TitanPhase.PHASE_3_TRIPLE_KEY_LOCK)
	elif current_health <= 0:
		start_phase(TitanPhase.DEFEATED)

func _on_boss_defeated() -> void:
	current_phase = TitanPhase.DEFEATED
	if spark_particles:
		spark_particles.emitting = false
	AudioManager.play_procedural_chime(659.25, 1.2)
	EventBus.boss_defeated.emit(boss_id)
	EventBus.notification_displayed.emit("TITAN WOUND DOWN!", "The toy titan kneels down, offering elevator to the underground!", 4.0)
	boss_defeated.emit()
	EventBus.golden_bone_collected.emit("bone_ch6_titan", GameManager.golden_bones_collected + 1)
