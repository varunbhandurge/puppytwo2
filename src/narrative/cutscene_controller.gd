class_name CutsceneController extends Node

## Coordinates In-Engine Narrative Cutscenes, Cinematic Framing, and Emotional Storytelling

signal cutscene_started(cutscene_id: String)
signal cutscene_finished(cutscene_id: String)

var is_cutscene_running: bool = false
var active_cutscene_id: String = ""

const CHAPTER_CINEMATICS: Dictionary = {
	1: {
		"intro": [
			{"speaker": "Bruno", "text": "Good morning Milo! The morning sun is up!", "icon": "☀️", "duration": 2.5},
			{"speaker": "Milo", "text": "I catch a sweet golden scent drifting from beyond the fence!", "icon": "👃", "duration": 2.5},
			{"speaker": "Barnaby", "text": "Listen well, little ones... The legendary Aura Bone calls only to true friends.", "icon": "🦴", "duration": 3.0}
		],
		"outro": [
			{"speaker": "Bruno", "text": "The back gate is open! The great outside awaits!", "icon": "🎉", "duration": 2.5},
			{"speaker": "Milo", "text": "Stay close, Bruno. We do this together!", "icon": "🐾", "duration": 2.5}
		]
	},
	2: {
		"intro": [
			{"speaker": "Milo", "text": "The Forgotten Garden... Giant overgrown briars everywhere!", "icon": "🌿", "duration": 2.5},
			{"speaker": "Bruno", "text": "No thorns can stop our paws!", "icon": "💪", "duration": 2.0}
		],
		"outro": [
			{"speaker": "Bruno", "text": "Whiskers is purring peacefully by the yarn ball.", "icon": "😸", "duration": 2.5},
			{"speaker": "Milo", "text": "Down through the storm cellar door into the house!", "icon": "🚪", "duration": 2.5}
		]
	},
	3: {
		"intro": [
			{"speaker": "Bruno", "text": "Woah! Look at the height of these kitchen counters!", "icon": "😲", "duration": 2.5},
			{"speaker": "Milo", "text": "Watch your footing on this slippery linoleum floor!", "icon": "🧈", "duration": 2.5}
		],
		"outro": [
			{"speaker": "Bruno", "text": "The golem is settled down. Look, the screen door pushed open!", "icon": "✨", "duration": 2.5},
			{"speaker": "Milo", "text": "Out to the giant redwoods of the wild forest!", "icon": "🌲", "duration": 2.5}
		]
	},
	4: {
		"intro": [
			{"speaker": "Milo", "text": "The trees are so tall you can barely see the sky!", "icon": "🌲", "duration": 2.5},
			{"speaker": "Bruno", "text": "Hark! That glossy black crow is watching us from high above...", "icon": "🦅", "duration": 2.5}
		],
		"outro": [
			{"speaker": "Bruno", "text": "Corvus dropped his shiny trinket and flew free into the dusk!", "icon": "🌟", "duration": 2.5},
			{"speaker": "Milo", "text": "The sound of rushing water... The Riverlands are just ahead!", "icon": "🌊", "duration": 2.5}
		]
	},
	5: {
		"intro": [
			{"speaker": "Bruno", "text": "A roaring river! I love splashing, but this current is fierce!", "icon": "🌊", "duration": 2.5},
			{"speaker": "Milo", "text": "We'll build a raft and steer using the beaver dam gates!", "icon": "🪵", "duration": 2.5}
		],
		"outro": [
			{"speaker": "Milo", "text": "We made it across the rapids! That bullfrog made a great splash!", "icon": "🐸", "duration": 2.5},
			{"speaker": "Bruno", "text": "Look at those smokestacks and gears... The Toy Factory!", "icon": "🏭", "duration": 2.5}
		]
	},
	6: {
		"intro": [
			{"speaker": "Milo", "text": "Conveyor belts, clockwork gears, and toy trains everywhere!", "icon": "⚙️", "duration": 2.5},
			{"speaker": "Bruno", "text": "Stay sharp, that giant mechanical clockwork titan is patrolling!", "icon": "🤖", "duration": 2.5}
		],
		"outro": [
			{"speaker": "Bruno", "text": "All three windup keys unlocked the ore chute!", "icon": "🗝️", "duration": 2.5},
			{"speaker": "Milo", "text": "Hold onto your ears, Bruno! We're sliding deep underground!", "icon": "🎢", "duration": 2.5}
		]
	},
	7: {
		"intro": [
			{"speaker": "Bruno", "text": "It's so dark down here... But listen to the crystal echoes!", "icon": "💎", "duration": 2.5},
			{"speaker": "Milo", "text": "My scent senses glowing mushrooms ahead. Watch my steps!", "icon": "🍄", "duration": 2.5}
		],
		"outro": [
			{"speaker": "Milo", "text": "The Mole King opened the steam elevator shaft for us!", "icon": "👑", "duration": 2.5},
			{"speaker": "Bruno", "text": "To the summit! The Mountain of Bones is right above!", "icon": "🏔️", "duration": 2.5}
		]
	},
	8: {
		"intro": [
			{"speaker": "Bruno", "text": "The blizzard is freezing! Milo, huddle close against the wind!", "icon": "❄️", "duration": 2.5},
			{"speaker": "Milo", "text": "I feel your warmth, Bruno. The ancient summit shrine is near!", "icon": "❤️", "duration": 2.5}
		],
		"outro": [
			{"speaker": "Mountain Guardian", "text": "You chose each other over any selfish prize... That is true loyalty.", "icon": "✨", "duration": 3.5},
			{"speaker": "Bruno", "text": "Look at the Aura Bone glow! It shows the warm lights of a home below!", "icon": "🌟", "duration": 3.0},
			{"speaker": "Milo", "text": "We found more than a bone, Bruno. We found our forever home together.", "icon": "🏡", "duration": 3.5}
		]
	}
}

func trigger_cutscene(cutscene_id: String, duration: float, camera_node: Camera3D = null) -> void:
	is_cutscene_running = true
	active_cutscene_id = cutscene_id
	GameManager.current_state = GameManager.GameState.CUTSCENE
	
	# Lock player movement
	if is_instance_valid(GameManager.player_1_node):
		GameManager.player_1_node.can_move = false
	if is_instance_valid(GameManager.player_2_node):
		GameManager.player_2_node.can_move = false
		
	cutscene_started.emit(cutscene_id)
	EventBus.cutscene_started.emit(cutscene_id)
	
	if camera_node:
		camera_node.current = true
		
	if is_inside_tree() and duration > 0.0:
		var timer = get_tree().create_timer(duration)
		timer.timeout.connect(func():
			if is_cutscene_running:
				end_cutscene()
		)

func end_cutscene() -> void:
	if not is_cutscene_running:
		return
	is_cutscene_running = false
	GameManager.current_state = GameManager.GameState.GAMEPLAY
	
	# Unlock player movement
	if is_instance_valid(GameManager.player_1_node):
		GameManager.player_1_node.can_move = true
	if is_instance_valid(GameManager.player_2_node):
		GameManager.player_2_node.can_move = true
		
	cutscene_finished.emit(active_cutscene_id)
	EventBus.cutscene_ended.emit(active_cutscene_id)

func play_chapter_cinematic(chapter_index: int, is_intro: bool = true, dialogue_mgr: DialogueManager = null) -> void:
	var ch_data = CHAPTER_CINEMATICS.get(chapter_index, {})
	var seq_key = "intro" if is_intro else "outro"
	var lines: Array = ch_data.get(seq_key, [])
	
	var cutscene_id = "ch%d_%s" % [chapter_index, seq_key]
	var total_dur: float = 0.0
	for l in lines:
		total_dur += l.get("duration", 2.5)
		
	trigger_cutscene(cutscene_id, total_dur)
	AudioManager.play_chapter_motif(chapter_index)
	
	# Trigger character celebratory or huddle emotions if appropriate
	if not is_intro:
		if is_instance_valid(GameManager.player_1_node) and GameManager.player_1_node.has_method("celebrate"):
			GameManager.player_1_node.celebrate(total_dur)
		if is_instance_valid(GameManager.player_2_node) and GameManager.player_2_node.has_method("celebrate"):
			GameManager.player_2_node.celebrate(total_dur)
	elif chapter_index == 8:
		# Chapter 8 blizzard huddle
		if is_instance_valid(GameManager.player_1_node) and GameManager.player_1_node.has_method("huddle"):
			GameManager.player_1_node.huddle(Vector3.ZERO, total_dur)
		if is_instance_valid(GameManager.player_2_node) and GameManager.player_2_node.has_method("huddle"):
			GameManager.player_2_node.huddle(Vector3.ZERO, total_dur)
	
	if dialogue_mgr != null and not lines.is_empty():
		dialogue_mgr.play_sequence(lines)
