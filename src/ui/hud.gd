class_name HUDController extends Control

## Minimal Stylized Diegetic HUD Overlay with Cinematic Letterboxing & Dialogue Presentation

@onready var notification_panel: PanelContainer = get_node_or_null("NotificationPanel")
@onready var title_label: Label = get_node_or_null("NotificationPanel/MarginContainer/VBoxContainer/TitleLabel")
@onready var subtitle_label: Label = get_node_or_null("NotificationPanel/MarginContainer/VBoxContainer/SubtitleLabel")
@onready var bones_label: Label = get_node_or_null("TopBar/BonesContainer/BonesLabel")
@onready var prompt_p1: Label = get_node_or_null("PromptP1")
@onready var prompt_p2: Label = get_node_or_null("PromptP2")

# Objective Card Nodes
@onready var objective_card: PanelContainer = get_node_or_null("ObjectiveCard")
@onready var objective_title_label: Label = get_node_or_null("ObjectiveCard/Margin/VBox/TitleHBox/ObjectiveTitle")
@onready var bruno_task_label: Label = get_node_or_null("ObjectiveCard/Margin/VBox/TasksHBox/BrunoTask")
@onready var milo_task_label: Label = get_node_or_null("ObjectiveCard/Margin/VBox/TasksHBox/MiloTask")
@onready var pause_menu: Control = get_node_or_null("PauseMenu")

# Cinematic & Dialogue Nodes
@onready var cinematic_top: ColorRect = get_node_or_null("CinematicTopBar")
@onready var cinematic_bottom: ColorRect = get_node_or_null("CinematicBottomBar")
@onready var dialogue_panel: PanelContainer = get_node_or_null("DialoguePanel")
@onready var speaker_label: Label = get_node_or_null("DialoguePanel/Margin/VBox/SpeakerHeader/SpeakerLabel")
@onready var emotion_icon: Label = get_node_or_null("DialoguePanel/Margin/VBox/SpeakerHeader/EmotionIcon")
@onready var dialogue_text: Label = get_node_or_null("DialoguePanel/Margin/VBox/DialogueText")

var notif_tween: Tween = null
var bars_tween: Tween = null
var dialogue_tween: Tween = null

const SPEAKER_COLORS: Dictionary = {
	"BRUNO": Color(1.0, 0.82, 0.4, 1),
	"MILO": Color(0.2, 0.84, 0.63, 1),
	"BARNABY": Color(0.71, 0.51, 0.35, 1),
	"WHISKERS": Color(0.95, 0.45, 0.45, 1),
	"CORVUS": Color(0.61, 0.36, 0.9, 1),
	"MOLE KING": Color(0.83, 0.64, 0.45, 1),
	"MOUNTAIN GUARDIAN": Color(0.44, 0.84, 1.0, 1),
	"NARRATOR": Color(0.9, 0.9, 0.95, 1)
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.notification_displayed.connect(_on_notification_displayed)
	EventBus.objective_updated.connect(_on_objective_updated)
	EventBus.game_pause_toggled.connect(_on_pause_toggled)
	EventBus.golden_bone_collected.connect(_on_bones_updated)
	EventBus.interaction_available.connect(_on_interaction_available)
	EventBus.interaction_cleared.connect(_on_interaction_cleared)
	EventBus.cutscene_started.connect(func(_id): set_cinematic_mode(true))
	EventBus.cutscene_ended.connect(func(_id): set_cinematic_mode(false))
	EventBus.dialogue_line_started.connect(_on_dialogue_line_started)
	EventBus.dialogue_sequence_ended.connect(_on_dialogue_sequence_ended)
	
	if notification_panel:
		notification_panel.modulate.a = 0.0
	if prompt_p1:
		prompt_p1.visible = false
	if prompt_p2:
		prompt_p2.visible = false
	if cinematic_top:
		cinematic_top.modulate.a = 0.0
	if cinematic_bottom:
		cinematic_bottom.modulate.a = 0.0
	if dialogue_panel:
		dialogue_panel.modulate.a = 0.0
		
	_on_bones_updated("", GameManager.golden_bones_collected)
	_on_objective_updated("FIND A WAY OUT OF THE BACKYARD", "Dig out the Sandbox Ramp [E / RT]", "Scent-track & low-crawl burrows [V / LT]")

func _on_objective_updated(main_objective: String, bruno_task: String, milo_task: String) -> void:
	if objective_title_label:
		objective_title_label.text = main_objective
	if bruno_task_label:
		bruno_task_label.text = "🐕 %s" % bruno_task
	if milo_task_label:
		milo_task_label.text = "🐕‍🦺 %s" % milo_task
	
	if objective_card and is_inside_tree():
		var tw = create_tween()
		tw.tween_property(objective_card, "scale", Vector2(1.04, 1.04), 0.12)
		tw.tween_property(objective_card, "scale", Vector2.ONE, 0.15)

func _on_notification_displayed(title: String, subtitle: String, duration: float) -> void:
	if not notification_panel or not title_label:
		return
		
	title_label.text = title
	if subtitle_label:
		subtitle_label.text = subtitle
	
	if notif_tween and notif_tween.is_valid():
		notif_tween.kill()
		
	if is_inside_tree():
		notif_tween = create_tween()
		notif_tween.tween_property(notification_panel, "modulate:a", 1.0, 0.2)
		notif_tween.tween_interval(duration)
		notif_tween.tween_property(notification_panel, "modulate:a", 0.0, 0.4)

func set_cinematic_mode(active: bool) -> void:
	var target_alpha = 1.0 if active else 0.0
	if bars_tween and bars_tween.is_valid():
		bars_tween.kill()
		
	if is_inside_tree():
		bars_tween = create_tween().set_parallel(true)
		if cinematic_top:
			bars_tween.tween_property(cinematic_top, "modulate:a", target_alpha, 0.4)
		if cinematic_bottom:
			bars_tween.tween_property(cinematic_bottom, "modulate:a", target_alpha, 0.4)
	else:
		if cinematic_top:
			cinematic_top.modulate.a = target_alpha
		if cinematic_bottom:
			cinematic_bottom.modulate.a = target_alpha

func _on_dialogue_line_started(speaker: String, text: String, icon: String) -> void:
	if not dialogue_panel:
		return
		
	if speaker_label:
		speaker_label.text = speaker.to_upper()
		var color = SPEAKER_COLORS.get(speaker.to_upper(), Color(0.9, 0.9, 0.95, 1))
		speaker_label.modulate = color
	if emotion_icon:
		emotion_icon.text = icon if icon != "" else "🐾"
	if dialogue_text:
		dialogue_text.text = text
		
	if dialogue_tween and dialogue_tween.is_valid():
		dialogue_tween.kill()
		
	if is_inside_tree():
		dialogue_tween = create_tween()
		dialogue_tween.tween_property(dialogue_panel, "modulate:a", 1.0, 0.18)
	else:
		dialogue_panel.modulate.a = 1.0

func _on_dialogue_sequence_ended() -> void:
	if not dialogue_panel:
		return
	if dialogue_tween and dialogue_tween.is_valid():
		dialogue_tween.kill()
	if is_inside_tree():
		dialogue_tween = create_tween()
		dialogue_tween.tween_property(dialogue_panel, "modulate:a", 0.0, 0.3)
	else:
		dialogue_panel.modulate.a = 0.0

func _on_bones_updated(_id: String, count: int) -> void:
	if bones_label:
		bones_label.text = "🦴 %d / %d" % [count, GameManager.total_golden_bones]

func _on_interaction_available(player_id: int, obj_name: String, prompt_text: String) -> void:
	var label = prompt_p1 if player_id == 1 else prompt_p2
	if label:
		label.text = "[ %s ]\n%s" % [obj_name, prompt_text]
		label.visible = true

func _on_pause_toggled(is_paused: bool) -> void:
	if pause_menu:
		pause_menu.visible = is_paused

func _on_interaction_cleared(player_id: int) -> void:
	var label = prompt_p1 if player_id == 1 else prompt_p2
	if label:
		label.visible = false
