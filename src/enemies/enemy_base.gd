class_name EnemyBase extends CharacterBody3D

## Hierarchical Finite State Machine for Cooperative Enemy AI

enum AIState {
	IDLE,
	PATROL,
	INVESTIGATE,
	ALERT_CHASE,
	ATTACK,
	STUNNED,
	DEFEATED
}

@export var enemy_id: String = "enemy_00"
@export var move_speed: float = 3.2
@export var detection_radius: float = 8.0

var current_state: AIState = AIState.IDLE
var target_player: PuppyBase = null

func _ready() -> void:
	EventBus.puppy_barked.connect(_on_puppy_barked)

func _physics_process(delta: float) -> void:
	match current_state:
		AIState.IDLE:
			_process_idle(delta)
		AIState.PATROL:
			_process_patrol(delta)
		AIState.INVESTIGATE:
			_process_investigate(delta)
		AIState.ALERT_CHASE:
			_process_chase(delta)
		AIState.STUNNED:
			_process_stunned(delta)

func _process_idle(_delta: float) -> void:
	pass

func _process_patrol(_delta: float) -> void:
	pass

func _process_investigate(_delta: float) -> void:
	pass

func _process_chase(_delta: float) -> void:
	if is_instance_valid(target_player):
		var dir = (target_player.global_position - global_position).normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		move_and_slide()

func _process_stunned(_delta: float) -> void:
	velocity = Vector3.ZERO
	move_and_slide()

func _on_puppy_barked(player_id: int, pos: Vector3, radius: float) -> void:
	if current_state == AIState.DEFEATED:
		return
	if global_position.distance_to(pos) <= radius:
		on_bark_sensed(player_id, pos)

func on_bark_sensed(player_id: int, pos: Vector3) -> void:
	current_state = AIState.INVESTIGATE

func apply_stun(duration: float) -> void:
	current_state = AIState.STUNNED
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(func():
		if current_state == AIState.STUNNED:
			current_state = AIState.IDLE
	)
