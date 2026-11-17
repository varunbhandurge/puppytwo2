class_name AudioManagerSingleton extends Node

## Comprehensive Audio Manager with Multi-Harmonic Canine Formant Vocalisations,
## Bus Volume Control, and Procedural Synthesis

var music_player: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE: int = 16

var default_music_volume_db: float = -6.0
var is_music_ducked: bool = false
var duck_tween: Tween = null

# Volume and Sound settings
var sound_enabled: bool = true
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.9

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_audio_players()
	_connect_event_bus()

func _setup_audio_players() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Master"
	add_child(music_player)
	
	for i in range(POOL_SIZE):
		var asp = AudioStreamPlayer.new()
		asp.name = "SFXPlayer_%d" % i
		asp.bus = "Master"
		add_child(asp)
		sfx_pool.append(asp)

func _connect_event_bus() -> void:
	EventBus.puppy_barked.connect(_on_puppy_barked)
	EventBus.puppy_jumped.connect(_on_puppy_jumped)
	EventBus.puppy_dug.connect(_on_puppy_dug)
	EventBus.puzzle_stage_completed.connect(_on_puzzle_stage_completed)
	EventBus.puzzle_solved.connect(_on_puzzle_solved)
	EventBus.boss_hit.connect(_on_boss_hit)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.golden_bone_collected.connect(func(_id, _c): play_bone_fanfare())
	EventBus.music_duck_requested.connect(duck_music)

# ------------------------------------------------------------------------------
# Volume & Sound Settings API
# ------------------------------------------------------------------------------

func set_sound_enabled(enabled: bool) -> void:
	sound_enabled = enabled
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx >= 0:
		AudioServer.set_bus_mute(master_bus_idx, not enabled)

func is_sound_enabled() -> bool:
	return sound_enabled

func set_master_volume(val: float) -> void:
	master_volume = clamp(val, 0.0, 1.0)
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx >= 0:
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(max(0.0001, master_volume)))

func set_music_volume(val: float) -> void:
	music_volume = clamp(val, 0.0, 1.0)
	default_music_volume_db = linear_to_db(max(0.0001, music_volume))
	if music_player and not is_music_ducked:
		music_player.volume_db = default_music_volume_db

func set_sfx_volume(val: float) -> void:
	sfx_volume = clamp(val, 0.0, 1.0)

# ------------------------------------------------------------------------------
# Music Ducking
# ------------------------------------------------------------------------------

func duck_music(amount_db: float = -12.0, duration: float = 2.0) -> void:
	if not music_player:
		return
	is_music_ducked = true
	if is_inside_tree():
		if duck_tween and duck_tween.is_valid():
			duck_tween.kill()
		duck_tween = create_tween()
		duck_tween.tween_property(music_player, "volume_db", default_music_volume_db + amount_db, 0.2)
		duck_tween.tween_interval(duration)
		duck_tween.tween_property(music_player, "volume_db", default_music_volume_db, 0.5)
		duck_tween.tween_callback(func(): is_music_ducked = false)
	else:
		music_player.volume_db = default_music_volume_db + amount_db
		is_music_ducked = false

# ------------------------------------------------------------------------------
# Organic Multi-Harmonic Canine Formant Vocalisations
# ------------------------------------------------------------------------------

## Bruno: Hearty Golden Retriever Woof/Bark (glide 260 -> 110 Hz with throat harmonics)
## Milo: Cheerful Corgi Yip (bright chirp 480 -> 680 -> 340 Hz)
func play_puppy_excited_bark(player_id: int) -> void:
	if not sound_enabled:
		return
	if player_id == 1:
		# Bruno: Deep, warm resonant woof with harmonic formants
		play_canine_bark_waveform(240.0, 105.0, 0.22, 0.65 * sfx_volume, 0.35)
	else:
		# Milo: High, energetic, bright corgi yip
		play_canine_bark_waveform(460.0, 290.0, 0.16, 0.55 * sfx_volume, 0.55)

func play_puppy_whimper(player_id: int) -> void:
	if not sound_enabled:
		return
	var base_freq = 380.0 if player_id == 1 else 620.0
	play_procedural_tone(base_freq, 0.35, 0.25 * sfx_volume)

func play_puppy_growl(player_id: int) -> void:
	if not sound_enabled:
		return
	var base_freq = 75.0 if player_id == 1 else 130.0
	play_procedural_tone(base_freq, 0.45, 0.4 * sfx_volume)

func play_puppy_sniff(player_id: int) -> void:
	if not sound_enabled:
		return
	var freq = 360.0 if player_id == 1 else 520.0
	play_procedural_tone(freq, 0.06, 0.25 * sfx_volume)
	if is_inside_tree():
		var t = get_tree().create_timer(0.08)
		t.timeout.connect(func(): play_procedural_tone(freq * 1.1, 0.07, 0.22 * sfx_volume))

func play_footstep(surface: String, player_id: int) -> void:
	if not sound_enabled:
		return
	var freq = 120.0
	var dur = 0.04
	match surface:
		"grass": freq = 135.0
		"wood": freq = 180.0
		"stone": freq = 220.0
		"water": freq = 340.0
		"snow": freq = 90.0
	if player_id == 2:
		freq *= 1.3
	play_procedural_tone(freq, dur, 0.12 * sfx_volume)

func play_water_splash() -> void:
	if not sound_enabled:
		return
	play_procedural_tone(280.0, 0.18, 0.35 * sfx_volume)
	if is_inside_tree():
		var timer = get_tree().create_timer(0.06)
		timer.timeout.connect(func(): play_procedural_tone(190.0, 0.22, 0.3 * sfx_volume))

func play_wind_howl(duration: float = 1.2) -> void:
	if not sound_enabled:
		return
	play_procedural_tone(110.0, duration, 0.25 * sfx_volume)

func play_mechanical_clank() -> void:
	if not sound_enabled:
		return
	play_procedural_tone(420.0, 0.08, 0.4 * sfx_volume)
	if is_inside_tree():
		var timer = get_tree().create_timer(0.04)
		timer.timeout.connect(func(): play_procedural_tone(260.0, 0.16, 0.35 * sfx_volume))

func play_bone_fanfare() -> void:
	if not sound_enabled:
		return
	# Sparkling major arpeggio fanfare
	play_procedural_chime(659.25, 0.5)
	if is_inside_tree():
		var timer = get_tree().create_timer(0.12)
		timer.timeout.connect(func(): play_procedural_chime(1046.50, 0.6))

func play_chapter_motif(chapter_index: int) -> void:
	if not sound_enabled:
		return
	match chapter_index:
		1: play_procedural_chime(523.25, 0.6) # Backyard (C major)
		2: play_procedural_chime(349.23, 0.7) # Forgotten Garden (F major)
		3: play_procedural_chime(392.00, 0.5) # Giant Kitchen (G major)
		4: play_procedural_tone(329.63, 0.4, 0.3 * sfx_volume) # Forest (E minor)
		5: play_procedural_chime(293.66, 0.7) # Riverlands (D major)
		6: play_mechanical_clank()             # Toy Factory
		7: play_procedural_tone(220.00, 0.6, 0.3 * sfx_volume) # Underground (A minor)
		8: play_procedural_chime(1046.50, 1.0) # Mountain of Bones (High C)
		_: play_procedural_chime(523.25, 0.5)

# ------------------------------------------------------------------------------
# Audio Stream Dispatch & Synthesis
# ------------------------------------------------------------------------------

func play_sfx_stream(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not sound_enabled:
		return
	for player in sfx_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.pitch_scale = pitch_scale
			player.play()
			return
	sfx_pool[0].stop()
	sfx_pool[0].stream = stream
	sfx_pool[0].volume_db = volume_db
	sfx_pool[0].pitch_scale = pitch_scale
	sfx_pool[0].play()

## Multi-harmonic Formant Canine Bark Waveform Generator
func play_canine_bark_waveform(start_freq: float, end_freq: float, duration: float, volume: float = 0.5, formant_mix: float = 0.4) -> void:
	if not sound_enabled:
		return
	var sample_rate: int = 22050
	var total_frames: int = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	
	var data = PackedByteArray()
	data.resize(total_frames * 2)
	
	var phase: float = 0.0
	for i in range(total_frames):
		var progress: float = float(i) / float(total_frames)
		# Frequency drop simulating natural vocal tract closing
		var current_freq: float = lerp(start_freq, end_freq, progress)
		phase += TAU * current_freq / float(sample_rate)
		
		# Fundamental + 2nd Harmonic + Formant Overtone
		var fundamental: float = sin(phase)
		var harmonic2: float = sin(phase * 2.0) * 0.45
		var formant: float = sin(phase * 3.2) * formant_mix
		
		# Amplitude envelope: quick sharp attack, warm decay
		var env: float = 1.0
		if progress < 0.12:
			env = progress / 0.12
		else:
			env = 1.0 - pow((progress - 0.12) / 0.88, 1.2)
			
		var val: float = (fundamental * 0.55 + harmonic2 + formant) * volume * env
		var sample_16: int = int(clamp(val * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, sample_16)
		
	stream.data = data
	play_sfx_stream(stream)

func play_procedural_tone(frequency: float, duration: float, volume: float = 0.5, decay: bool = true) -> void:
	if not sound_enabled:
		return
	var sample_rate: int = 22050
	var total_frames: int = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	
	var data = PackedByteArray()
	data.resize(total_frames * 2)
	
	for i in range(total_frames):
		var t: float = float(i) / float(sample_rate)
		var amp: float = volume
		if decay:
			amp *= max(0.0, 1.0 - (float(i) / float(total_frames)))
		var val: float = sin(TAU * frequency * t) * amp
		var sample_16: int = int(clamp(val * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, sample_16)
	
	stream.data = data
	play_sfx_stream(stream)

func play_procedural_chime(root_freq: float = 523.25, duration: float = 0.6) -> void:
	if not sound_enabled:
		return
	play_procedural_tone(root_freq, duration, 0.3 * sfx_volume)
	if is_inside_tree():
		var t1 = get_tree().create_timer(0.08)
		t1.timeout.connect(func(): play_procedural_tone(root_freq * 1.2599, duration * 0.8, 0.25 * sfx_volume))
		var t2 = get_tree().create_timer(0.16)
		t2.timeout.connect(func(): play_procedural_tone(root_freq * 1.4983, duration * 0.8, 0.25 * sfx_volume))

# ------------------------------------------------------------------------------
# Event Handlers
# ------------------------------------------------------------------------------

func _on_puppy_barked(player_id: int, _pos: Vector3, _radius: float) -> void:
	play_puppy_excited_bark(player_id)

func _on_puppy_jumped(player_id: int) -> void:
	var freq = 220.0 if player_id == 1 else 320.0
	play_procedural_tone(freq, 0.1, 0.2 * sfx_volume)

func _on_puppy_dug(_pid: int, _pos: Vector3) -> void:
	play_procedural_tone(85.0, 0.12, 0.4 * sfx_volume)

func _on_puzzle_stage_completed(_puz_id: String, _stage: int) -> void:
	play_procedural_chime(440.0, 0.5)

func _on_puzzle_solved(_puz_id: String) -> void:
	play_procedural_chime(523.25, 0.8)

func _on_boss_hit(_id: String, _dmg: int, _remaining: int) -> void:
	play_procedural_tone(110.0, 0.3, 0.7 * sfx_volume)

func _on_boss_defeated(_id: String) -> void:
	play_procedural_chime(659.25, 1.2)
