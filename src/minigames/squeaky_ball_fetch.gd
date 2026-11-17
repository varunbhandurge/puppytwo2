class_name SqueakyBallFetchMiniGame extends Node3D

## Mini-Game: Squeaky Ball Fetch Mania

signal minigame_started()
signal ball_deposited(current: int, target: int)
signal minigame_completed()

@export var target_balls: int = 5
@export var minigame_id: String = "minigame_fetch"

var balls_deposited_count: int = 0
var is_active: bool = false
var is_completed: bool = false

@onready var basket_trigger: Area3D = get_node_or_null("BasketArea")
@onready var launcher_mesh: MeshInstance3D = get_node_or_null("LauncherMesh")

func _ready() -> void:
	if basket_trigger:
		basket_trigger.body_entered.connect(_on_basket_body_entered)

func start_minigame() -> void:
	if is_completed or is_active:
		return
	is_active = true
	balls_deposited_count = 0
	minigame_started.emit()
	EventBus.notification_displayed.emit("MINI-GAME: FETCH!", "Retrieve 5 tennis balls into the basket!", 3.5)

func deposit_ball() -> void:
	if not is_active:
		return
	balls_deposited_count += 1
	ball_deposited.emit(balls_deposited_count, target_balls)
	AudioManager.play_procedural_chime(523.25, 0.3)
	EventBus.notification_displayed.emit("BALL RETRIEVED!", "Count: %d / %d" % [balls_deposited_count, target_balls], 1.5)
	
	if balls_deposited_count >= target_balls:
		complete_minigame()

func complete_minigame() -> void:
	is_active = false
	is_completed = true
	minigame_completed.emit()
	AudioManager.play_procedural_chime(659.25, 1.0)
	EventBus.notification_displayed.emit("FETCH CHAMPIONS!", "Mini-game complete! Golden Bone unlocked!", 4.0)
	EventBus.golden_bone_collected.emit("bone_ch1_fetch", GameManager.golden_bones_collected + 1)

func _on_basket_body_entered(body: Node3D) -> void:
	if not is_active:
		return
	if body.is_in_group("tennis_ball"):
		body.queue_free()
		deposit_ball()
