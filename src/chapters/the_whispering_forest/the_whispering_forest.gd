class_name TheWhisperingForest extends Node3D

## =============================================================================
## TWO PUPPIES: THE GREAT ADVENTURE — THE WHISPERING FOREST (VERTICAL SLICE)
## 10–15 Minute Flagship Cooperative Level:
## - Scene 1: Forest Entrance (Cinematic arrival, locomotion, first hidden bone)
## - Scene 2: Stream Crossing (River dam dig, floating log, winch raft)
## - Scene 3: The Ancient Hollow Oak (Physics see-saw fulcrum balance)
## - Scene 4: Briar Traversal Ascent (Scent tracking, root tunnel, snout boost)
## - Scene 5: The Whispering Shrine (Dual resonant bark unsealing Aura Bone)
## =============================================================================

enum ForestBeat {
	BEAT_1_ENTRANCE,
	BEAT_2_STREAM_CROSSING,
	BEAT_3_HOLLOW_OAK_SEESAW,
	BEAT_4_BRIAR_ASCENT,
	BEAT_5_ANCIENT_SHRINE,
	CHAPTER_COMPLETED
}

var current_beat: ForestBeat = ForestBeat.BEAT_1_ENTRANCE

@onready var split_screen_manager: SplitScreenManager = get_node_or_null("SplitScreenManager")
@onready var bruno: BrunoCharacter = get_node_or_null("World/Characters/Bruno")
@onready var milo: MiloCharacter = get_node_or_null("World/Characters/Milo")
@onready var hud: HUDController = get_node_or_null("HUD")
@onready var beacon: Node3D = get_node_or_null("World/ObjectiveBeacon")

# Interactive Level Entities
@onready var river_log: RigidBody3D = get_node_or_null("World/StreamPuzzle/FloatingLog")
@onready var raft_mesh: Node3D = get_node_or_null("World/StreamPuzzle/BarkRaft")
@onready var seesaw_bridge: AnimatableBody3D = get_node_or_null("World/RavinePuzzle/SeeSawLog")
@onready var vine_ladder: Node3D = get_node_or_null("World/AscentPuzzle/VineLadder")
@onready var shrine_aura_bone: Node3D = get_node_or_null("World/ShrinePuzzle/AuraBonePickup")

var _p1_bark_resonated: bool = false
var _p2_bark_resonated: bool = false
var _shrine_unsealed: bool = false
var dialogue_manager: DialogueManager = null

signal beat_advanced(new_beat: int)
signal chapter_completed()

func _ready() -> void:
	GameManager.current_chapter_index = 4 # The Whispering Forest
	dialogue_manager = DialogueManager.new()
	add_child(dialogue_manager)
	
	_setup_sculpted_terrain_materials()
	
	if split_screen_manager and bruno and milo:
		split_screen_manager.assign_targets(bruno, milo)
		
	_connect_events()
	start_beat_1_entrance()

func _setup_sculpted_terrain_materials() -> void:
	var terrain_model = get_node_or_null("World/SculptedTerrain")
	if terrain_model:
		var terrain_mesh = terrain_model.get_node_or_null("ForestTerrain")
		if terrain_mesh and terrain_mesh is MeshInstance3D:
			var mat = ShaderMaterial.new()
			mat.shader = preload("res://src/shaders/stylized_forest_floor.gdshader")
			mat.set_shader_parameter("soil_base_color", Color(0.20, 0.14, 0.09, 1.0))
			mat.set_shader_parameter("soil_wet_color", Color(0.12, 0.08, 0.05, 1.0))
			mat.set_shader_parameter("moss_color", Color(0.18, 0.46, 0.12, 1.0))
			mat.set_shader_parameter("pine_needle_col", Color(0.40, 0.25, 0.14, 1.0))
			mat.set_shader_parameter("moss_frequency", 0.20)
			mat.set_shader_parameter("moss_amount", 0.65)
			mat.set_shader_parameter("detail_frequency", 48.0)
			mat.set_shader_parameter("wetness_distance", 5.5)
			terrain_mesh.material_override = mat
	

func _play_dialogue(lines: Array[Dictionary]) -> void:
	if dialogue_manager:
		dialogue_manager.play_sequence(lines)

func _connect_events() -> void:
	# Listen for bark resonance at the ancient shrine
	EventBus.puppy_barked.connect(func(player_id, _pos, _radius):
		if current_beat == ForestBeat.BEAT_5_ANCIENT_SHRINE and not _shrine_unsealed:
			_handle_shrine_bark(player_id)
	)

func advance_to_beat(new_beat: ForestBeat) -> void:
	current_beat = new_beat
	emit_signal("beat_advanced", new_beat)
	
	match new_beat:
		ForestBeat.BEAT_2_STREAM_CROSSING:
			_start_beat_2_stream()
		ForestBeat.BEAT_3_HOLLOW_OAK_SEESAW:
			_start_beat_3_seesaw()
		ForestBeat.BEAT_4_BRIAR_ASCENT:
			_start_beat_4_ascent()
		ForestBeat.BEAT_5_ANCIENT_SHRINE:
			_start_beat_5_shrine()
		ForestBeat.CHAPTER_COMPLETED:
			_complete_chapter()

# --- SCENE 1: FOREST ENTRANCE ---
func start_beat_1_entrance() -> void:
	current_beat = ForestBeat.BEAT_1_ENTRANCE
	if beacon:
		beacon.global_position = Vector3(0.0, 1.2, 5.0) # Points toward the stream
		beacon.set_label("Rushing Stream Ahead")
		
	EventBus.objective_updated.emit("Enter The Whispering Forest", "Explore the trail to the mountain stream", "Follow Bruno down the wooded path")
	_play_dialogue([
		{"speaker": "Bruno", "text": "Woof! Smell that fresh pine and damp earth, Milo? The legendary Aura Bone must be deep in these woods!"},
		{"speaker": "Milo", "text": "Yip! The trail leads downhill toward that rushing river. Let's stick together!"}
	])

# --- SCENE 2: STREAM CROSSING ---
func _start_beat_2_stream() -> void:
	if beacon:
		beacon.global_position = Vector3(0.0, 1.0, 0.0)
		beacon.set_label("Stream Dam")
		
	EventBus.objective_updated.emit("Cross The Rushing Stream", "Dig out the riverbank dam [E/RT]", "Cross floating log & pull winch lever [Space/A]")
	_play_dialogue([
		{"speaker": "Bruno", "text": "The current is too swift to swim! But look—there's a log jammed in the mud embankment!"},
		{"speaker": "Milo", "text": "If you dig it loose, Bruno, it will float across into the rocks so I can reach the winch!"}
	])

func on_stream_dam_excavated() -> void:
	if current_beat == ForestBeat.BEAT_2_STREAM_CROSSING:
		# Animate the floating log sliding into the river
		if river_log:
			var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(river_log, "position", Vector3(0.0, 0.2, 0.0), 2.0)
		AudioManager.play_sfx("water_splash")
		EventBus.objective_updated.emit("Cross The River", "Wait for raft to reach near bank", "Cross the floating log & release raft")

func on_stream_raft_winched() -> void:
	if current_beat == ForestBeat.BEAT_2_STREAM_CROSSING:
		# Lower bark raft for Bruno
		if raft_mesh:
			var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			tween.tween_property(raft_mesh, "position", Vector3(-4.0, 0.15, 0.0), 1.5)
		AudioManager.play_sfx("mechanism_click")
		advance_to_beat(ForestBeat.BEAT_3_HOLLOW_OAK_SEESAW)

# --- SCENE 3: THE ANCIENT HOLLOW OAK ---
func _start_beat_3_seesaw() -> void:
	if beacon:
		beacon.global_position = Vector3(0.0, 2.5, -16.0)
		beacon.set_label("Hollow See-Saw Oak")
		
	EventBus.objective_updated.emit("Cross The Ravine", "Stand on log end as counterweight", "Scramble through hollow trunk to other side")
	_play_dialogue([
		{"speaker": "Milo", "text": "Whoa! A massive hollow trunk spans the chasm, but it tilts whenever I step on it!"},
		{"speaker": "Bruno", "text": "I'll stand on this end to hold it down with my weight! Squeeze through the knothole inside, Milo!"}
	])

func on_seesaw_counterweighted() -> void:
	if current_beat == ForestBeat.BEAT_3_HOLLOW_OAK_SEESAW:
		# Lock see-saw bridge level
		if seesaw_bridge:
			var tween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
			tween.tween_property(seesaw_bridge, "rotation:z", 0.0, 1.2)
		AudioManager.play_sfx("wood_thud")
		advance_to_beat(ForestBeat.BEAT_4_BRIAR_ASCENT)

# --- SCENE 4: BRIAR TRAVERSAL ASCENT ---
func _start_beat_4_ascent() -> void:
	if beacon:
		beacon.global_position = Vector3(0.0, 4.0, -28.0)
		beacon.set_label("Mossy Cliff Terrace")
		
	EventBus.objective_updated.emit("Ascend The Cliff", "Snout Boost Milo up to high ledge [Q/X]", "Sniff scent trail & navigate briars [F/Y]")
	_play_dialogue([
		{"speaker": "Milo", "text": "Sniff sniff... I smell an animal trail weaving safely around these prickly briars!"},
		{"speaker": "Bruno", "text": "The ledge above is too high to jump! Milo, hop on my nose—SNOUT BOOST incoming!"}
	])

func on_vine_ladder_dropped() -> void:
	if current_beat == ForestBeat.BEAT_4_BRIAR_ASCENT:
		if vine_ladder:
			var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			tween.tween_property(vine_ladder, "scale:y", 1.0, 1.2)
		AudioManager.play_sfx("ladder_drop")
		advance_to_beat(ForestBeat.BEAT_5_ANCIENT_SHRINE)

# --- SCENE 5: THE ANCIENT SHRINE CLIMAX ---
func _start_beat_5_shrine() -> void:
	if beacon:
		beacon.global_position = Vector3(0.0, 2.0, -38.0)
		beacon.set_label("The Whispering Shrine")
		
	EventBus.objective_updated.emit("Unseal The Aura Bone", "Bark in harmony at left monolith [Bark]", "Bark in harmony at right monolith [Bark]")
	_play_dialogue([
		{"speaker": "Bruno", "text": "Look at those monolithic canine statues! Sunlight is reflecting through the crystals!"},
		{"speaker": "Milo", "text": "The inscription says: 'Two voices in harmony shall unseal the light!' Let's bark together on three!"}
	])

func _handle_shrine_bark(player_id: int) -> void:
	if player_id == 1:
		_p1_bark_resonated = true
	elif player_id == 2:
		_p2_bark_resonated = true
		
	# If both puppies barked within a 1.5s harmonic window
	if _p1_bark_resonated and _p2_bark_resonated:
		_shrine_unsealed = true
		_unseal_aura_bone()
	else:
		# Reset resonance window after 1.5 seconds if companion didn't bark
		get_tree().create_timer(1.5).timeout.connect(func():
			if not _shrine_unsealed:
				_p1_bark_resonated = false
				_p2_bark_resonated = false
		)

func _unseal_aura_bone() -> void:
	AudioManager.play_sfx("shrine_harmony")
	EventBus.objective_updated.emit("Claim The Aura Bone!", "Retrieve the floating Aura Bone!", "Celebrate the triumph with Bruno!")
	if shrine_aura_bone:
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(shrine_aura_bone, "position:y", 2.2, 2.0)

func on_aura_bone_collected() -> void:
	advance_to_beat(ForestBeat.CHAPTER_COMPLETED)

func _complete_chapter() -> void:
	EventBus.objective_updated.emit("Vertical Slice Complete!", "The Whispering Forest conquered!", "All cooperative puzzles solved!")
	EventBus.chapter_completed.emit(4)
	emit_signal("chapter_completed")
	_play_dialogue([
		{"speaker": "Bruno", "text": "WE DID IT! The first Aura Bone is ours! What an incredible team we make, Milo!"},
		{"speaker": "Milo", "text": "High paws, Bruno! Onward to the next great adventure!"}
	])
