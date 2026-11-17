class_name Chapter2ForgottenGarden extends Node3D

## Chapter 2: The Forgotten Garden — Full Level Controller

enum ChapterBeat {
	BEAT_1_BRIAR_GATE,
	BEAT_2_GREENHOUSE_INFILTRATION,
	BEAT_3_FERTILIZER_SCENT,
	BEAT_4_TERRACOTTA_SEESAW,
	BEAT_5_BUTTERFLY_CHASE,
	BEAT_6_WHISKERS_BOSS,
	BEAT_7_STORM_CELLAR_ESCAPE,
	CHAPTER_COMPLETED
}

var current_beat: ChapterBeat = ChapterBeat.BEAT_1_BRIAR_GATE

@onready var split_screen_manager: SplitScreenManager = get_node_or_null("SplitScreenManager")
@onready var bruno: BrunoCharacter = get_node_or_null("World/Characters/Bruno")
@onready var milo: MiloCharacter = get_node_or_null("World/Characters/Milo")
@onready var boss_whiskers: BossGardenCat = get_node_or_null("World/BossWhiskers")
@onready var cellar_door: Node3D = get_node_or_null("World/CellarDoor")

signal beat_advanced(new_beat: int)
signal chapter_completed()

func _ready() -> void:
	GameManager.current_chapter_index = 2
	if split_screen_manager and bruno and milo:
		split_screen_manager.assign_targets(bruno, milo)
	
	if boss_whiskers:
		boss_whiskers.boss_defeated.connect(func():
			advance_to_beat(ChapterBeat.BEAT_7_STORM_CELLAR_ESCAPE)
		)
		
	start_beat_1()

func start_beat_1() -> void:
	current_beat = ChapterBeat.BEAT_1_BRIAR_GATE
	EventBus.notification_displayed.emit("CHAPTER 2: THE FORGOTTEN GARDEN", "Wild briars and ancient greenhouse ahead!", 4.0)

func advance_to_beat(next_beat: ChapterBeat) -> void:
	current_beat = next_beat
	beat_advanced.emit(int(next_beat))
	
	match next_beat:
		ChapterBeat.BEAT_2_GREENHOUSE_INFILTRATION:
			EventBus.notification_displayed.emit("GREENHOUSE", "Scramble across the mossy glass panes!", 3.5)
		ChapterBeat.BEAT_3_FERTILIZER_SCENT:
			EventBus.notification_displayed.emit("SWEET SCENT", "Milo: Follow the sweet bone meal aroma!", 3.5)
		ChapterBeat.BEAT_4_TERRACOTTA_SEESAW:
			EventBus.notification_displayed.emit("TERRACOTTA SEESAW", "Bruno: Counterweight the pot plank!", 3.5)
		ChapterBeat.BEAT_5_BUTTERFLY_CHASE:
			EventBus.notification_displayed.emit("BUTTERFLY CHASE", "Catch the glowing golden butterflies!", 3.5)
		ChapterBeat.BEAT_6_WHISKERS_BOSS:
			EventBus.notification_displayed.emit("WHISKERS' LAIR", "The calico queen stalks the high rafters!", 3.5)
		ChapterBeat.BEAT_7_STORM_CELLAR_ESCAPE:
			_open_storm_cellar()
		ChapterBeat.CHAPTER_COMPLETED:
			chapter_completed.emit()
			EventBus.notification_displayed.emit("CHAPTER 2 COMPLETE!", "Heading inside into the Giant Kitchen...", 5.0)

func _open_storm_cellar() -> void:
	if cellar_door and is_inside_tree():
		var tw = create_tween()
		tw.tween_property(cellar_door, "rotation:x", deg_to_rad(-80.0), 1.2)
	EventBus.notification_displayed.emit("STORM CELLAR OPEN!", "Escape into the human house basement!", 4.0)
	advance_to_beat(ChapterBeat.CHAPTER_COMPLETED)
