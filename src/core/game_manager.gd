class_name GameManagerSingleton extends Node

## Core Game Manager for Two Puppies: The Great Adventure

enum GameState {
	BOOT,
	MAIN_MENU,
	GAMEPLAY,
	PAUSED,
	CUTSCENE,
	VICTORY,
	GAME_OVER
}

var current_state: GameState = GameState.BOOT
var current_chapter_index: int = 0
var golden_bones_collected: int = 0
var total_golden_bones: int = 64

# Player tracking
var player_1_node: Node3D = null # Bruno
var player_2_node: Node3D = null # Milo
var active_checkpoint_id: String = "cp_lab_start"
var active_checkpoint_position: Vector3 = Vector3(0, 1.0, 0)
var respawn_in_progress: bool = false

# Metrics & Settings
var split_is_vertical: bool = true
var is_assisting_enabled: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.checkpoint_reached.connect(_on_checkpoint_reached)
	EventBus.request_respawn.connect(_on_request_respawn)
	EventBus.golden_bone_collected.connect(_on_golden_bone_collected)
	EventBus.split_orientation_toggled.connect(_on_split_orientation_toggled)
	current_state = GameState.GAMEPLAY

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause"):
		toggle_pause()
	elif event.is_action_pressed("toggle_split_screen"):
		toggle_split_screen_orientation()

func register_player(player_id: int, node: Node3D) -> void:
	if player_id == 1:
		player_1_node = node
	elif player_id == 2:
		player_2_node = node

func toggle_pause() -> void:
	if current_state == GameState.GAMEPLAY:
		current_state = GameState.PAUSED
		get_tree().paused = true
		EventBus.game_pause_toggled.emit(true)
		EventBus.notification_displayed.emit("PAUSED", "Game is currently paused", 2.0)
	elif current_state == GameState.PAUSED:
		current_state = GameState.GAMEPLAY
		get_tree().paused = false
		EventBus.game_pause_toggled.emit(false)
		EventBus.notification_displayed.emit("RESUMED", "Welcome back!", 1.0)

func toggle_split_screen_orientation() -> void:
	split_is_vertical = !split_is_vertical
	EventBus.split_orientation_toggled.emit(split_is_vertical)
	var mode_name = "Side-by-Side (Vertical)" if split_is_vertical else "Top-and-Bottom (Horizontal)"
	EventBus.notification_displayed.emit("SPLIT-SCREEN MODE", mode_name, 2.0)

func _on_checkpoint_reached(cp_id: String, safe_pos: Vector3) -> void:
	active_checkpoint_id = cp_id
	active_checkpoint_position = safe_pos
	SaveManager.save_checkpoint_state(cp_id, safe_pos, golden_bones_collected)
	EventBus.notification_displayed.emit("CHECKPOINT REACHED", "Progress securely saved!", 2.0)

func _on_request_respawn(player_id: int) -> void:
	if respawn_in_progress:
		return
	respawn_in_progress = true
	EventBus.notification_displayed.emit("OOPS!", "Respawning together at checkpoint...", 1.5)
	
	# Small delay then respawn both puppies side-by-side
	var timer = get_tree().create_timer(0.8)
	timer.timeout.connect(func():
		if is_instance_valid(player_1_node):
			player_1_node.global_position = active_checkpoint_position + Vector3(-1.0, 0.5, 0)
			if player_1_node.has_method("reset_velocity"):
				player_1_node.reset_velocity()
		if is_instance_valid(player_2_node):
			player_2_node.global_position = active_checkpoint_position + Vector3(1.0, 0.5, 0)
			if player_2_node.has_method("reset_velocity"):
				player_2_node.reset_velocity()
		respawn_in_progress = false
	)

func _on_golden_bone_collected(bone_id: String, total_count: int) -> void:
	golden_bones_collected = total_count
	EventBus.notification_displayed.emit("GOLDEN BONE!", "Collected: %d / %d" % [golden_bones_collected, total_golden_bones], 3.0)

func _on_split_orientation_toggled(is_vertical: bool) -> void:
	split_is_vertical = is_vertical
