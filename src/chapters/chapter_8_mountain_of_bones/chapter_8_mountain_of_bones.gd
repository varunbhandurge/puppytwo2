class_name Chapter8MountainOfBones extends Node3D

## Chapter 8: The Mountain of Bones — Climactic Campaign Finale Level Controller

enum ChapterBeat {
	BEAT_1_BLIZZARD_ASCENT,
	BEAT_2_CHASM_GLIDER,
	BEAT_3_GATE_OF_ANCESTORS,
	BEAT_4_STAIRWAY_OF_TRIALS,
	BEAT_5_MOUNTAIN_GUARDIAN_BOSS,
	BEAT_6_REVELATION_AND_EPILOGUE,
	CHAPTER_COMPLETED
}

var current_beat: ChapterBeat = ChapterBeat.BEAT_1_BLIZZARD_ASCENT

@onready var split_screen_manager: SplitScreenManager = get_node_or_null("SplitScreenManager")
@onready var bruno: BrunoCharacter = get_node_or_null("World/Characters/Bruno")
@onready var milo: MiloCharacter = get_node_or_null("World/Characters/Milo")
@onready var boss_guardian: BossMountainGuardian = get_node_or_null("World/BossMountainGuardian")
@onready var sanctuary_gate: Node3D = get_node_or_null("World/SanctuaryGate")

signal beat_advanced(new_beat: int)
signal chapter_completed()
signal campaign_completed()

func _ready() -> void:
	GameManager.current_chapter_index = 8
	if split_screen_manager and bruno and milo:
		split_screen_manager.assign_targets(bruno, milo)
	
	if boss_guardian:
		boss_guardian.boss_defeated.connect(func():
			advance_to_beat(ChapterBeat.BEAT_6_REVELATION_AND_EPILOGUE)
		)
		
	start_beat_1()

func start_beat_1() -> void:
	current_beat = ChapterBeat.BEAT_1_BLIZZARD_ASCENT
	EventBus.notification_displayed.emit("CHAPTER 8: THE MOUNTAIN OF BONES", "The frozen summit where legends await!", 4.0)

func advance_to_beat(next_beat: ChapterBeat) -> void:
	current_beat = next_beat
	beat_advanced.emit(int(next_beat))
	
	match next_beat:
		ChapterBeat.BEAT_2_CHASM_GLIDER:
			EventBus.notification_displayed.emit("CHASM GLIDER", "Dual-handle cloth kite flight over the howling abyss!", 3.5)
		ChapterBeat.BEAT_3_GATE_OF_ANCESTORS:
			EventBus.notification_displayed.emit("GATE OF THE ANCESTORS", "Synchronized high jump onto runic floor switches!", 3.5)
		ChapterBeat.BEAT_4_STAIRWAY_OF_TRIALS:
			EventBus.notification_displayed.emit("STAIRWAY OF TRIALS", "Crumbling monolith steps leading into the aurora clouds!", 3.5)
		ChapterBeat.BEAT_5_MOUNTAIN_GUARDIAN_BOSS:
			EventBus.notification_displayed.emit("THE MOUNTAIN GUARDIAN", "Ancient stone mastiff tests the bond between brothers!", 4.0)
		ChapterBeat.BEAT_6_REVELATION_AND_EPILOGUE:
			_trigger_epilogue()
		ChapterBeat.CHAPTER_COMPLETED:
			chapter_completed.emit()
			campaign_completed.emit()
			EventBus.notification_displayed.emit("TWO PUPPIES: CAMPAIGN COMPLETE!", "True friendship is the greatest treasure of all!", 7.0)

func _trigger_epilogue() -> void:
	if sanctuary_gate and is_inside_tree():
		var tw = create_tween()
		tw.tween_property(sanctuary_gate, "position:y", sanctuary_gate.position.y - 4.0, 2.0)
	AudioManager.play_procedural_chime(880.0, 3.0)
	EventBus.notification_displayed.emit("THE LEGENDARY AURA BONE", "Its warm glow reveals a loving home in the sunlit valley!", 5.0)
	advance_to_beat(ChapterBeat.CHAPTER_COMPLETED)
