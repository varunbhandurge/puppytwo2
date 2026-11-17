class_name BossGardenCat extends CharacterBody3D

## Whiskers the Menace: 3-Phase Cooperative Boss Encounter

enum BossPhase {
	PHASE_1_POUNCE,
	PHASE_2_RAFTERS,
	PHASE_3_YARN_CHASE,
	DEFEATED
}

@export var boss_id: String = "boss_whiskers"
@export var max_health: int = 3
var current_health: int = 3
var current_phase: BossPhase = BossPhase.PHASE_1_POUNCE

signal boss_defeated()

var is_vulnerable: bool = false
var target_pounce_pos: Vector3 = Vector3.ZERO
var pounce_timer: float = 0.0

@onready var cat_mesh: Node3D = get_node_or_null("CatVisual")
@onready var telegraph_decal: MeshInstance3D = get_node_or_null("TelegraphDecal")
@onready var purr_particles: CPUParticles3D = get_node_or_null("PurrParticles")

func _ready() -> void:
	EventBus.puppy_barked.connect(_on_puppy_barked)
	if telegraph_decal:
		telegraph_decal.visible = false
	start_phase(BossPhase.PHASE_1_POUNCE)

func start_phase(phase: BossPhase) -> void:
	current_phase = phase
	EventBus.boss_phase_changed.emit(boss_id, int(phase))
	
	match phase:
		BossPhase.PHASE_1_POUNCE:
			EventBus.notification_displayed.emit("WHISKERS ATTACKS!", "Watch out for high pounces! Bruno: Bark to startle!", 3.0)
		BossPhase.PHASE_2_RAFTERS:
			EventBus.notification_displayed.emit("PHASE 2: RAFTERS", "Milo: Climb high to knock down the yarn ball!", 3.0)
		BossPhase.PHASE_3_YARN_CHASE:
			EventBus.notification_displayed.emit("PHASE 3: YARN TRAP", "Bruno: Push yarn into net! Milo: Pull the latch!", 3.0)
		BossPhase.DEFEATED:
			_on_boss_defeated()

func _physics_process(delta: float) -> void:
	if current_phase == BossPhase.DEFEATED:
		return
		
	if current_phase == BossPhase.PHASE_1_POUNCE:
		_process_phase_1(delta)

func _process_phase_1(delta: float) -> void:
	pounce_timer += delta
	if pounce_timer > 4.5 and not is_vulnerable:
		pounce_timer = 0.0
		_telegraph_and_pounce()

func _telegraph_and_pounce() -> void:
	var target = GameManager.player_2_node # Targets Milo by default
	if not is_instance_valid(target):
		target = GameManager.player_1_node
	if not is_instance_valid(target):
		return
		
	target_pounce_pos = target.global_position
	if telegraph_decal:
		telegraph_decal.global_position = target_pounce_pos + Vector3(0, 0.05, 0)
		telegraph_decal.visible = true
	
	EventBus.boss_attack_telegraphed.emit(boss_id, "Pounce", target_pounce_pos, 1.5)
	
	var timer = get_tree().create_timer(1.4)
	timer.timeout.connect(func():
		if current_phase == BossPhase.PHASE_1_POUNCE and not is_vulnerable:
			_execute_pounce_strike()
	)

func _execute_pounce_strike() -> void:
	if telegraph_decal:
		telegraph_decal.visible = false
	
	var tw = create_tween()
	tw.tween_property(self, "global_position", target_pounce_pos, 0.3)
	tw.tween_callback(func():
		# Pounce lands
		AudioManager.play_procedural_tone(120.0, 0.25, 0.6)
	)

func _on_puppy_barked(player_id: int, pos: Vector3, radius: float) -> void:
	if not is_inside_tree():
		if player_id == 1:
			trigger_vulnerability()
		return
	if current_phase == BossPhase.PHASE_1_POUNCE:
		# If Bruno barks near the cat or during telegraph, cat gets startled and claws stick in wood!
		if player_id == 1 and global_position.distance_to(pos) <= radius + 4.0:
			trigger_vulnerability()

func trigger_vulnerability() -> void:
	is_vulnerable = true
	if telegraph_decal:
		telegraph_decal.visible = false
	EventBus.notification_displayed.emit("WHISKERS STARTLED!", "Claws stuck! Milo, pull the trap cord!", 2.5)
	
	# Vulnerable for 4.5 seconds
	if is_inside_tree():
		var timer = get_tree().create_timer(4.5)
		timer.timeout.connect(func():
			if is_vulnerable:
				is_vulnerable = false
		)

## Called when co-op trap mechanism is triggered
func apply_coop_hit() -> void:
	current_health -= 1
	is_vulnerable = false
	EventBus.boss_hit.emit(boss_id, 1, current_health)
	
	if current_health == 2:
		start_phase(BossPhase.PHASE_2_RAFTERS)
	elif current_health == 1:
		start_phase(BossPhase.PHASE_3_YARN_CHASE)
	elif current_health <= 0:
		start_phase(BossPhase.DEFEATED)

func hit_cat() -> void:
	apply_coop_hit()

func _on_boss_defeated() -> void:
	current_phase = BossPhase.DEFEATED
	EventBus.boss_defeated.emit(boss_id)
	EventBus.notification_displayed.emit("WHISKERS TAMED!", "Whiskers is purring asleep! Victory!", 4.0)
	boss_defeated.emit()
	
	if purr_particles:
		purr_particles.emitting = true
	
	# Spawn Golden Bone reward
	EventBus.golden_bone_collected.emit("bone_whiskers_victory", GameManager.golden_bones_collected + 1)
