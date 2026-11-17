class_name Chapter3GiantKitchen extends Node3D

## Chapter 3: The Giant Kitchen — Full Level Controller

enum ChapterBeat {
	BEAT_1_LINOLEUM_CROSSING,
	BEAT_2_TRASHCAN_CATAPULT,
	BEAT_3_DISHWASHER_DRAWBRIDGE,
	BEAT_4_REFRIGERATOR_ASCENT,
	BEAT_5_PANCAKE_FLIP,
	BEAT_6_APPLIANCE_GOLEM_BOSS,
	BEAT_7_SCREEN_DOOR_EXIT,
	CHAPTER_COMPLETED
}

var current_beat: ChapterBeat = ChapterBeat.BEAT_1_LINOLEUM_CROSSING

@onready var split_screen_manager: SplitScreenManager = get_node_or_null("SplitScreenManager")
@onready var bruno: BrunoCharacter = get_node_or_null("World/Characters/Bruno")
@onready var milo: MiloCharacter = get_node_or_null("World/Characters/Milo")
@onready var boss_golem: BossApplianceGolem = get_node_or_null("World/BossApplianceGolem")
@onready var screen_door: Node3D = get_node_or_null("World/ScreenDoor")

signal beat_advanced(new_beat: int)
signal chapter_completed()

func _ready() -> void:
	GameManager.current_chapter_index = 3
	if split_screen_manager and bruno and milo:
		split_screen_manager.assign_targets(bruno, milo)
	
	if boss_golem:
		boss_golem.boss_defeated.connect(func():
			advance_to_beat(ChapterBeat.BEAT_7_SCREEN_DOOR_EXIT)
		)
		
	start_beat_1()

func start_beat_1() -> void:
	current_beat = ChapterBeat.BEAT_1_LINOLEUM_CROSSING
	EventBus.notification_displayed.emit("CHAPTER 3: THE GIANT KITCHEN", "Monumental domestic wilderness! Watch for soapy spills!", 4.0)

func advance_to_beat(next_beat: ChapterBeat) -> void:
	current_beat = next_beat
	beat_advanced.emit(int(next_beat))
	
	match next_beat:
		ChapterBeat.BEAT_2_TRASHCAN_CATAPULT:
			EventBus.notification_displayed.emit("TRASH CAN CATAPULT", "Bruno: Press foot pedal! Milo: Vault from the lid!", 3.5)
		ChapterBeat.BEAT_3_DISHWASHER_DRAWBRIDGE:
			EventBus.notification_displayed.emit("DISHWASHER BRIDGE", "Pull the door latch to span the sink gap!", 3.5)
		ChapterBeat.BEAT_4_REFRIGERATOR_ASCENT:
			EventBus.notification_displayed.emit("REFRIGERATOR CLIFFS", "Scale the butter shelves and egg carton steps!", 3.5)
		ChapterBeat.BEAT_5_PANCAKE_FLIP:
			EventBus.notification_displayed.emit("PANCAKE FLIP!", "Bounce on the silicone spatula trampoline!", 3.5)
		ChapterBeat.BEAT_6_APPLIANCE_GOLEM_BOSS:
			EventBus.notification_displayed.emit("APPLIANCE GOLEM!", "A robotic vacuum and mixer gone wild!", 3.5)
		ChapterBeat.BEAT_7_SCREEN_DOOR_EXIT:
			_open_screen_door()
		ChapterBeat.CHAPTER_COMPLETED:
			chapter_completed.emit()
			EventBus.notification_displayed.emit("CHAPTER 3 COMPLETE!", "Escaping into the ancient Forest of Giants...", 5.0)

func _open_screen_door() -> void:
	if screen_door and is_inside_tree():
		var tw = create_tween()
		tw.tween_property(screen_door, "position:x", screen_door.position.x + 3.0, 1.2)
	EventBus.notification_displayed.emit("SCREEN DOOR SLID OPEN!", "Head out into the great open forest!", 4.0)
	advance_to_beat(ChapterBeat.CHAPTER_COMPLETED)
