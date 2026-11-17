class_name Chapter6ToyFactory extends Node3D

## Chapter 6: The Toy Factory — Full Level Controller

enum ChapterBeat {
	BEAT_1_CONVEYOR_MAZE,
	BEAT_2_PLUSH_STUFFING_CHUTE,
	BEAT_3_CLOCKWORK_TRAIN,
	BEAT_4_BATTERY_CIRCUIT,
	BEAT_5_TOY_CAR_RALLY,
	BEAT_6_CLOCKWORK_TITAN_BOSS,
	BEAT_7_ORE_CHUTE_DESCENT,
	CHAPTER_COMPLETED
}

var current_beat: ChapterBeat = ChapterBeat.BEAT_1_CONVEYOR_MAZE

@onready var split_screen_manager: SplitScreenManager = get_node_or_null("SplitScreenManager")
@onready var bruno: BrunoCharacter = get_node_or_null("World/Characters/Bruno")
@onready var milo: MiloCharacter = get_node_or_null("World/Characters/Milo")
@onready var boss_titan: BossClockworkTitan = get_node_or_null("World/BossClockworkTitan")
@onready var ore_chute_gate: Node3D = get_node_or_null("World/OreChuteGate")

signal beat_advanced(new_beat: int)
signal chapter_completed()

func _ready() -> void:
	GameManager.current_chapter_index = 6
	if split_screen_manager and bruno and milo:
		split_screen_manager.assign_targets(bruno, milo)
	
	if boss_titan:
		boss_titan.boss_defeated.connect(func():
			advance_to_beat(ChapterBeat.BEAT_7_ORE_CHUTE_DESCENT)
		)
		
	start_beat_1()

func start_beat_1() -> void:
	current_beat = ChapterBeat.BEAT_1_CONVEYOR_MAZE
	EventBus.notification_displayed.emit("CHAPTER 6: THE TOY FACTORY", "Clockwork assembly lines and mechanical wonders!", 4.0)

func advance_to_beat(next_beat: ChapterBeat) -> void:
	current_beat = next_beat
	beat_advanced.emit(int(next_beat))
	
	match next_beat:
		ChapterBeat.BEAT_2_PLUSH_STUFFING_CHUTE:
			EventBus.notification_displayed.emit("PLUSH CHUTE", "Soft high-flying drops into mounds of cotton fluff!", 3.5)
		ChapterBeat.BEAT_3_CLOCKWORK_TRAIN:
			EventBus.notification_displayed.emit("CLOCKWORK TRAIN", "Defend the train cars as you roll along tracks!", 3.5)
		ChapterBeat.BEAT_4_BATTERY_CIRCUIT:
			EventBus.notification_displayed.emit("BATTERY CIRCUIT", "Bruno presses terminals; Milo routes copper wires!", 3.5)
		ChapterBeat.BEAT_5_TOY_CAR_RALLY:
			EventBus.notification_displayed.emit("TOY CAR RALLY!", "Remote-controlled wooden track racing!", 3.5)
		ChapterBeat.BEAT_6_CLOCKWORK_TITAN_BOSS:
			EventBus.notification_displayed.emit("THE CLOCKWORK TITAN!", "Four-armed assembly titan powered by 3 keys!", 3.5)
		ChapterBeat.BEAT_7_ORE_CHUTE_DESCENT:
			_open_ore_chute()
		ChapterBeat.CHAPTER_COMPLETED:
			chapter_completed.emit()
			EventBus.notification_displayed.emit("CHAPTER 6 COMPLETE!", "Plunging deep into the Dark Underground...", 5.0)

func _open_ore_chute() -> void:
	if ore_chute_gate and is_inside_tree():
		var tw = create_tween()
		tw.tween_property(ore_chute_gate, "position:y", ore_chute_gate.position.y - 3.5, 1.2)
	EventBus.notification_displayed.emit("ORE CHUTE OPEN!", "Slide into the subterranean mining caverns below!", 4.0)
	advance_to_beat(ChapterBeat.CHAPTER_COMPLETED)
