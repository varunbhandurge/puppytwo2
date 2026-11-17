class_name DialogueManager extends Node

## Subtitled Canine Dialogue & Thought-Bubble System with Audio Ducking and Vocalizations

signal dialogue_started(speaker_name: String, text: String)
signal dialogue_advanced(line_index: int, total_lines: int)
signal dialogue_ended()

var is_dialogue_active: bool = false
var current_dialogue_queue: Array[Dictionary] = []
var current_line_idx: int = 0

func play_sequence(lines: Array[Dictionary]) -> void:
	current_dialogue_queue = lines
	current_line_idx = 0
	is_dialogue_active = true
	_display_current_line()

func _display_current_line() -> void:
	if current_line_idx < current_dialogue_queue.size():
		var line = current_dialogue_queue[current_line_idx]
		var speaker = line.get("speaker", "Narrator")
		var text = line.get("text", "")
		var icon = line.get("icon", "🐾")
		var duration = line.get("duration", 3.5)
		
		dialogue_started.emit(speaker, text)
		dialogue_advanced.emit(current_line_idx, current_dialogue_queue.size())
		EventBus.dialogue_line_started.emit(speaker, text, icon)
		EventBus.notification_displayed.emit(speaker.to_upper(), text, duration)
		EventBus.music_duck_requested.emit(-10.0, duration)
		
		# Play speaker vocalization chime
		match speaker.to_upper():
			"BRUNO":
				AudioManager.play_procedural_tone(160.0, 0.2, 0.4)
			"MILO":
				AudioManager.play_procedural_tone(360.0, 0.15, 0.4)
			"BARNABY":
				AudioManager.play_procedural_tone(110.0, 0.35, 0.5)
			"CORVUS":
				AudioManager.play_procedural_tone(580.0, 0.18, 0.35)
			"MOLE KING":
				AudioManager.play_procedural_tone(95.0, 0.3, 0.5)
			"MOUNTAIN GUARDIAN":
				AudioManager.play_procedural_tone(784.0, 0.4, 0.35)
			_:
				AudioManager.play_procedural_tone(440.0, 0.1, 0.2)
		
		if is_inside_tree() and duration > 0.0:
			var timer = get_tree().create_timer(duration)
			timer.timeout.connect(func():
				if is_dialogue_active:
					advance_line()
			)
	else:
		end_dialogue()

func advance_line() -> void:
	if not is_dialogue_active:
		return
	current_line_idx += 1
	if current_line_idx < current_dialogue_queue.size():
		_display_current_line()
	else:
		end_dialogue()

func end_dialogue() -> void:
	is_dialogue_active = false
	current_dialogue_queue.clear()
	EventBus.dialogue_sequence_ended.emit()
	dialogue_ended.emit()
