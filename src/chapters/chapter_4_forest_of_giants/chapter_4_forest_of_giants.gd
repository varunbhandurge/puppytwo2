class_name Chapter4ForestOfGiants extends Node3D

## Chapter 4: The Forest of Giants — Full Level Controller

enum ChapterBeat {
	BEAT_1_REDWOOD_TRAIL,
	BEAT_2_SQUIRREL_CACHE,
	BEAT_3_DRIFT_LOG_CROSSING,
	BEAT_4_FIREFLY_HOLLOW,
	BEAT_5_PINECONE_BOWLING,
	BEAT_6_CORVUS_CROW_BOSS,
	BEAT_7_OVERLOOK_CLIFF_EXIT,
	CHAPTER_COMPLETED
}

var current_beat: ChapterBeat = ChapterBeat.BEAT_1_REDWOOD_TRAIL

@onready var split_screen_manager: SplitScreenManager = get_node_or_null("SplitScreenManager")
@onready var bruno: BrunoCharacter = get_node_or_null("World/Characters/Bruno")
@onready var milo: MiloCharacter = get_node_or_null("World/Characters/Milo")
@onready var boss_crow: BossCorvusCrow = get_node_or_null("World/BossCorvusCrow")
@onready var overlook_bridge: Node3D = get_node_or_null("World/OverlookBridge")

signal beat_advanced(new_beat: int)
signal chapter_completed()

func _ready() -> void:
	GameManager.current_chapter_index = 4
	if split_screen_manager and bruno and milo:
		split_screen_manager.assign_targets(bruno, milo)
	
	if boss_crow:
		boss_crow.boss_defeated.connect(func():
			advance_to_beat(ChapterBeat.BEAT_7_OVERLOOK_CLIFF_EXIT)
		)
		
	start_beat_1()

func start_beat_1() -> void:
	current_beat = ChapterBeat.BEAT_1_REDWOOD_TRAIL
	EventBus.notification_displayed.emit("CHAPTER 4: THE FOREST OF GIANTS", "Ancient twilight canopy and towering redwoods!", 4.0)

func advance_to_beat(next_beat: ChapterBeat) -> void:
	current_beat = next_beat
	beat_advanced.emit(int(next_beat))
	
	match next_beat:
		ChapterBeat.BEAT_2_SQUIRREL_CACHE:
			EventBus.notification_displayed.emit("SQUIRREL CACHE", "Bruno: Dig through pine needles for hidden nuts!", 3.5)
		ChapterBeat.BEAT_3_DRIFT_LOG_CROSSING:
			EventBus.notification_displayed.emit("LOG CROSSING", "Balance and roll across the fallen drift trunk!", 3.5)
		ChapterBeat.BEAT_4_FIREFLY_HOLLOW:
			EventBus.notification_displayed.emit("FIREFLY HOLLOW", "Milo: Gather glowing fireflies to light the path!", 3.5)
		ChapterBeat.BEAT_5_PINECONE_BOWLING:
			EventBus.notification_displayed.emit("PINECONE BOWLING!", "Launch pinecones at mischievous badger pins!", 3.5)
		ChapterBeat.BEAT_6_CORVUS_CROW_BOSS:
			EventBus.notification_displayed.emit("CORVUS' CANOPY!", "The Crow King attacks from the high branches!", 3.5)
		ChapterBeat.BEAT_7_OVERLOOK_CLIFF_EXIT:
			_open_overlook_path()
		ChapterBeat.CHAPTER_COMPLETED:
			chapter_completed.emit()
			EventBus.notification_displayed.emit("CHAPTER 4 COMPLETE!", "Descending into the roaring Riverlands...", 5.0)

func _open_overlook_path() -> void:
	if overlook_bridge and is_inside_tree():
		var tw = create_tween()
		tw.tween_property(overlook_bridge, "rotation:z", deg_to_rad(0.0), 1.2)
	EventBus.notification_displayed.emit("OVERLOOK BRIDGE LOWERED!", "Descend into the rushing Riverlands below!", 4.0)
	advance_to_beat(ChapterBeat.CHAPTER_COMPLETED)
