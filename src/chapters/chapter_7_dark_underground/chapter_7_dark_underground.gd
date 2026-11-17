class_name Chapter7DarkUnderground extends Node3D

## Chapter 7: The Dark Underground — Full Level Controller

enum ChapterBeat {
	BEAT_1_THE_GREAT_SEPARATION,
	BEAT_2_CRYSTAL_CHIMES,
	BEAT_3_MINECART_DESCENT,
	BEAT_4_BIOLUMINESCENT_MUSHROOMS,
	BEAT_5_CRYSTAL_MEMORY_CONTEST,
	BEAT_6_MOLE_KING_BOSS,
	BEAT_7_ORE_ELEVATOR_ASCENT,
	CHAPTER_COMPLETED
}

var current_beat: ChapterBeat = ChapterBeat.BEAT_1_THE_GREAT_SEPARATION

@onready var split_screen_manager: SplitScreenManager = get_node_or_null("SplitScreenManager")
@onready var bruno: BrunoCharacter = get_node_or_null("World/Characters/Bruno")
@onready var milo: MiloCharacter = get_node_or_null("World/Characters/Milo")
@onready var boss_mole: BossMoleKing = get_node_or_null("World/BossMoleKing")
@onready var ore_elevator: Node3D = get_node_or_null("World/OreElevator")

signal beat_advanced(new_beat: int)
signal chapter_completed()

func _ready() -> void:
	GameManager.current_chapter_index = 7
	if split_screen_manager and bruno and milo:
		split_screen_manager.assign_targets(bruno, milo)
	
	if boss_mole:
		boss_mole.boss_defeated.connect(func():
			advance_to_beat(ChapterBeat.BEAT_7_ORE_ELEVATOR_ASCENT)
		)
		
	start_beat_1()

func start_beat_1() -> void:
	current_beat = ChapterBeat.BEAT_1_THE_GREAT_SEPARATION
	EventBus.notification_displayed.emit("CHAPTER 7: THE DARK UNDERGROUND", "Subterranean cavern tunnels and crystal echoes!", 4.0)

func advance_to_beat(next_beat: ChapterBeat) -> void:
	current_beat = next_beat
	beat_advanced.emit(int(next_beat))
	
	match next_beat:
		ChapterBeat.BEAT_2_CRYSTAL_CHIMES:
			EventBus.notification_displayed.emit("CRYSTAL CHIMES", "Bruno: Acoustic bark resonates crystal bridges!", 3.5)
		ChapterBeat.BEAT_3_MINECART_DESCENT:
			EventBus.notification_displayed.emit("MINECART DESCENT", "Dual handbrakes and track switches down the shafts!", 3.5)
		ChapterBeat.BEAT_4_BIOLUMINESCENT_MUSHROOMS:
			EventBus.notification_displayed.emit("MUSHROOM CROSSING", "Milo: Scent-guide safe glowing fungal caps!", 3.5)
		ChapterBeat.BEAT_5_CRYSTAL_MEMORY_CONTEST:
			EventBus.notification_displayed.emit("CRYSTAL MELODY", "Harmonic bark sequence echoing across the grotto!", 3.5)
		ChapterBeat.BEAT_6_MOLE_KING_BOSS:
			EventBus.notification_displayed.emit("THE MOLE KING'S GROTTO", "Excavation sovereign guards the mountain lift!", 3.5)
		ChapterBeat.BEAT_7_ORE_ELEVATOR_ASCENT:
			_activate_ore_elevator()
		ChapterBeat.CHAPTER_COMPLETED:
			chapter_completed.emit()
			EventBus.notification_displayed.emit("CHAPTER 7 COMPLETE!", "Ascending to the Mountain of Bones...", 5.0)

func _activate_ore_elevator() -> void:
	if ore_elevator and is_inside_tree():
		var tw = create_tween()
		tw.tween_property(ore_elevator, "position:y", ore_elevator.position.y + 12.0, 3.0)
	EventBus.notification_displayed.emit("ORE ELEVATOR POWERED!", "Riding the steam counterweight hoist to the summit!", 4.0)
	advance_to_beat(ChapterBeat.CHAPTER_COMPLETED)
