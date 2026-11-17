class_name Chapter1Backyard extends Node3D

## Chapter 1: The Backyard — Full Playable Level Controller

enum ChapterBeat {
	BEAT_1_DOGHOUSE_AWAKENING,
	BEAT_2_SANDBOX_TRENCH,
	BEAT_3_HOSE_LABYRINTH,
	BEAT_4_PICNIC_TABLE_ASCENT,
	BEAT_5_FETCH_MINIGAME,
	BEAT_6_SPRINKLER_BOSS,
	BEAT_7_BACK_GATE_ESCAPE,
	CHAPTER_COMPLETED
}

var current_beat: ChapterBeat = ChapterBeat.BEAT_1_DOGHOUSE_AWAKENING

@onready var split_screen_manager: SplitScreenManager = get_node_or_null("SplitScreenManager")
@onready var dialogue_manager: DialogueManager = get_node_or_null("DialogueManager")
@onready var cutscene_controller: CutsceneController = get_node_or_null("CutsceneController")

@onready var bruno: BrunoCharacter = get_node_or_null("World/Characters/Bruno")
@onready var milo: MiloCharacter = get_node_or_null("World/Characters/Milo")

@onready var boss_sprinkler: BossMechanicalSprinkler = get_node_or_null("World/BossSprinkler")
@onready var fetch_minigame: SqueakyBallFetchMiniGame = get_node_or_null("World/FetchMinigame")
@onready var back_gate_mesh: Node3D = get_node_or_null("World/BackGate")
@onready var objective_beacon: Node3D = get_node_or_null("World/ObjectiveBeacon")

signal beat_advanced(new_beat: int)
signal chapter_completed()

func _ready() -> void:
	GameManager.current_chapter_index = 1
	if split_screen_manager and bruno and milo:
		split_screen_manager.assign_targets(bruno, milo)
	
	_connect_events()
	start_beat_1_awakening()

func _connect_events() -> void:
	if boss_sprinkler:
		boss_sprinkler.boss_defeated.connect(func():
			advance_to_beat(ChapterBeat.BEAT_7_BACK_GATE_ESCAPE)
		)
	
	if fetch_minigame:
		fetch_minigame.minigame_completed.connect(func():
			if current_beat == ChapterBeat.BEAT_5_FETCH_MINIGAME:
				advance_to_beat(ChapterBeat.BEAT_6_SPRINKLER_BOSS)
		)

func advance_to_beat(next_beat: ChapterBeat) -> void:
	current_beat = next_beat
	beat_advanced.emit(int(next_beat))
	
	match next_beat:
		ChapterBeat.BEAT_2_SANDBOX_TRENCH:
			EventBus.notification_displayed.emit("THE SANDBOX", "Bruno: Dig out the sand ramp for Milo!", 3.5)
			EventBus.objective_updated.emit("CROSS THE SANDBOX TRENCH", "Dig out the sand ramp [E / RT]", "Follow & leap across the gap [Space / A]")
			_set_beacon(Vector3(-10, 0.4, 0), "SANDBOX DIG MOUND", "Bruno: Dig sand ramp")
		ChapterBeat.BEAT_3_HOSE_LABYRINTH:
			EventBus.notification_displayed.emit("HOSE LABYRINTH", "Milo: Low-crawl through the brick foundation!", 3.5)
			EventBus.objective_updated.emit("NAVIGATE THE GARDEN HOSE", "Distract spray & push obstacles [E]", "Low-crawl through narrow tunnel [C / LT]")
			_set_beacon(Vector3(6.5, 0.4, 2.0), "FOUNDATION TUNNEL", "Milo: Low-crawl through burrow")
		ChapterBeat.BEAT_4_PICNIC_TABLE_ASCENT:
			EventBus.notification_displayed.emit("PICNIC TABLE", "Bruno: Snout-boost Milo onto the bench!", 3.5)
			EventBus.objective_updated.emit("ASCEND THE PICNIC TABLE", "Snout-boost Milo upward [E / RT]", "Leap onto tabletop & scout path [Space]")
			_set_beacon(Vector3(10, 0.4, -6.0), "PICNIC TABLE BENCH", "Bruno: Snout-boost Milo")
		ChapterBeat.BEAT_5_FETCH_MINIGAME:
			EventBus.notification_displayed.emit("SQUEAKY BALL CHALLENGE", "Retrieve 5 squeaky balls to unlock the yard!", 3.5)
			EventBus.objective_updated.emit("COLLECT 5 SQUEAKY BALLS", "Fetch scattered rubber balls", "Bring balls to the toy basket")
			_set_beacon(Vector3(0, 0.4, -12.0), "TOY BASKET", "Deposit squeaky balls here")
			if fetch_minigame:
				fetch_minigame.start_minigame()
		ChapterBeat.BEAT_6_SPRINKLER_BOSS:
			EventBus.notification_displayed.emit("BOSS ARENA", "The Sprinkler is out of control! Cooperate to stop it!", 3.5)
			EventBus.objective_updated.emit("DEFEAT THE MECHANICAL SPRINKLER", "Hold down deflector & intake plate", "Turn off the high-pressure brass valve")
			_set_beacon(Vector3(0, 0.5, -20.0), "SPRINKLER BOSS", "Cooperate to shut down water jets")
		ChapterBeat.BEAT_7_BACK_GATE_ESCAPE:
			EventBus.objective_updated.emit("ESCAPE TO THE FORGOTTEN GARDEN", "Run through open back gate", "Lead the way to Chapter 2")
			_set_beacon(Vector3(0, 0.5, -28.0), "GARDEN GATE", "Step through to Forgotten Garden")
			_trigger_back_gate_unlock()
		ChapterBeat.CHAPTER_COMPLETED:
			_on_chapter_completed()

func start_beat_1_awakening() -> void:
	current_beat = ChapterBeat.BEAT_1_DOGHOUSE_AWAKENING
	EventBus.objective_updated.emit("AWAKEN & EXPLORE THE BACKYARD", "Stretch & bark to awaken [F / B]", "Scout the stepping stones ahead [-Z]")
	_set_beacon(Vector3(0, 0.4, 5.0), "STEPPING STONE PATH", "Follow stepping stones forward")
	
	if dialogue_manager:
		dialogue_manager.play_sequence([
			{"speaker": "Barnaby", "text": "Beyond the wooden fence lies the Mountain of Bones...", "duration": 3.0},
			{"speaker": "Bruno", "text": "*Excited morning bark! Time to explore!*", "duration": 2.5},
			{"speaker": "Milo", "text": "*Curious yip! Look at this map scrap...*", "duration": 2.5}
		])
		dialogue_manager.dialogue_ended.connect(func():
			advance_to_beat(ChapterBeat.BEAT_2_SANDBOX_TRENCH)
		, CONNECT_ONE_SHOT)
	else:
		advance_to_beat(ChapterBeat.BEAT_2_SANDBOX_TRENCH)

func _set_beacon(pos: Vector3, title: String, instruction: String) -> void:
	if objective_beacon:
		objective_beacon.position = pos
		objective_beacon.update_text(title, instruction)
		objective_beacon.visible = true

func _trigger_back_gate_unlock() -> void:
	if back_gate_mesh and is_inside_tree():
		var tw = create_tween()
		tw.tween_property(back_gate_mesh, "rotation:y", deg_to_rad(-90.0), 1.5)
	
	EventBus.notification_displayed.emit("GATE OPENED!", "Step through the back fence to the Forgotten Garden!", 4.0)
	advance_to_beat(ChapterBeat.CHAPTER_COMPLETED)

func _on_chapter_completed() -> void:
	chapter_completed.emit()
	EventBus.notification_displayed.emit("CHAPTER 1 COMPLETE!", "The Great Adventure has begun!", 5.0)
