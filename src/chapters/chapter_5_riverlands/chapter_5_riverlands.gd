class_name Chapter5Riverlands extends Node3D

## Chapter 5: The Riverlands — Full Level Controller

enum ChapterBeat {
	BEAT_1_BEAVER_DAM_SLUICE,
	BEAT_2_WHITEWATER_RAFT_RUN,
	BEAT_3_WILLOW_VINE_SWINGS,
	BEAT_4_WATERMILL_GEARS,
	BEAT_5_TROUT_SPLASH,
	BEAT_6_BULLFROG_BOSS,
	BEAT_7_FACTORY_DRAINAGE_FLUME,
	CHAPTER_COMPLETED
}

var current_beat: ChapterBeat = ChapterBeat.BEAT_1_BEAVER_DAM_SLUICE

@onready var split_screen_manager: SplitScreenManager = get_node_or_null("SplitScreenManager")
@onready var bruno: BrunoCharacter = get_node_or_null("World/Characters/Bruno")
@onready var milo: MiloCharacter = get_node_or_null("World/Characters/Milo")
@onready var boss_frog: BossRiverBullfrog = get_node_or_null("World/BossRiverBullfrog")
@onready var flume_gate: Node3D = get_node_or_null("World/FlumeGate")

signal beat_advanced(new_beat: int)
signal chapter_completed()

func _ready() -> void:
	GameManager.current_chapter_index = 5
	if split_screen_manager and bruno and milo:
		split_screen_manager.assign_targets(bruno, milo)
	
	if boss_frog:
		boss_frog.boss_defeated.connect(func():
			advance_to_beat(ChapterBeat.BEAT_7_FACTORY_DRAINAGE_FLUME)
		)
		
	start_beat_1()

func start_beat_1() -> void:
	current_beat = ChapterBeat.BEAT_1_BEAVER_DAM_SLUICE
	EventBus.notification_displayed.emit("CHAPTER 5: THE RIVERLANDS", "Roaring rapids and cascading lilypads!", 4.0)

func advance_to_beat(next_beat: ChapterBeat) -> void:
	current_beat = next_beat
	beat_advanced.emit(int(next_beat))
	
	match next_beat:
		ChapterBeat.BEAT_2_WHITEWATER_RAFT_RUN:
			EventBus.notification_displayed.emit("WHITEWATER RAFTING!", "Synchronize paddling to steer past boulders!", 3.5)
		ChapterBeat.BEAT_3_WILLOW_VINE_SWINGS:
			EventBus.notification_displayed.emit("WILLOW VINES", "Swing across river gorges on dangling vines!", 3.5)
		ChapterBeat.BEAT_4_WATERMILL_GEARS:
			EventBus.notification_displayed.emit("WATERMILL FORTRESS", "Bruno turns the paddlewheel; Milo routes inner gears!", 3.5)
		ChapterBeat.BEAT_5_TROUT_SPLASH:
			EventBus.notification_displayed.emit("TROUT SPLASH!", "Jump to catch leaping river trout!", 3.5)
		ChapterBeat.BEAT_6_BULLFROG_BOSS:
			EventBus.notification_displayed.emit("GRAND RIVER BULLFROG!", "Territorial amphibian titan of the river sluice!", 3.5)
		ChapterBeat.BEAT_7_FACTORY_DRAINAGE_FLUME:
			_open_drainage_flume()
		ChapterBeat.CHAPTER_COMPLETED:
			chapter_completed.emit()
			EventBus.notification_displayed.emit("CHAPTER 5 COMPLETE!", "Swept downstream into the Toy Factory...", 5.0)

func _open_drainage_flume() -> void:
	if flume_gate and is_inside_tree():
		var tw = create_tween()
		tw.tween_property(flume_gate, "position:y", flume_gate.position.y - 4.0, 1.4)
	EventBus.notification_displayed.emit("DRAINAGE FLUME OPENED!", "Ride the rushing flume into the industrial factory!", 4.0)
	advance_to_beat(ChapterBeat.CHAPTER_COMPLETED)
