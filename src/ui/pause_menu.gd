class_name PauseMenuController extends Control

## Comprehensive Master Pause & Settings Hub
## Includes: Resolution Adjustment, Sound On/Off & Volume Sliders, Level Select,
## Character Customization & Naming, Manual Save/Load Slots, Maps and Objectives

@onready var tab_container: TabContainer = get_node_or_null("Margin/Panel/VBox/TabContainer")
@onready var resume_button: Button = get_node_or_null("Margin/Panel/VBox/Footer/ResumeButton")
@onready var quit_button: Button = get_node_or_null("Margin/Panel/VBox/Footer/QuitButton")

# Options & Sound controls
@onready var resolution_option: OptionButton = get_node_or_null("Margin/Panel/VBox/TabContainer/Settings/VBox/ResHBox/ResolutionOption")
@onready var window_mode_option: OptionButton = get_node_or_null("Margin/Panel/VBox/TabContainer/Settings/VBox/WindowModeHBox/WindowModeOption")
@onready var vsync_check: CheckBox = get_node_or_null("Margin/Panel/VBox/TabContainer/Settings/VBox/VsyncHBox/VsyncCheck")
@onready var sound_toggle_check: CheckBox = get_node_or_null("Margin/Panel/VBox/TabContainer/Settings/VBox/SoundToggleHBox/SoundCheck")
@onready var master_slider: HSlider = get_node_or_null("Margin/Panel/VBox/TabContainer/Settings/VBox/MasterVolHBox/MasterSlider")
@onready var music_slider: HSlider = get_node_or_null("Margin/Panel/VBox/TabContainer/Settings/VBox/MusicVolHBox/MusicSlider")
@onready var sfx_slider: HSlider = get_node_or_null("Margin/Panel/VBox/TabContainer/Settings/VBox/SfxVolHBox/SfxSlider")
@onready var split_toggle_btn: Button = get_node_or_null("Margin/Panel/VBox/TabContainer/Settings/VBox/SplitHBox/SplitModeButton")

# Character Customization controls
@onready var p1_name_edit: LineEdit = get_node_or_null("Margin/Panel/VBox/TabContainer/Puppies/VBox/HBox/BrunoCol/P1NameEdit")
@onready var p1_collar_option: OptionButton = get_node_or_null("Margin/Panel/VBox/TabContainer/Puppies/VBox/HBox/BrunoCol/P1CollarOption")
@onready var p1_tag_option: OptionButton = get_node_or_null("Margin/Panel/VBox/TabContainer/Puppies/VBox/HBox/BrunoCol/P1TagOption")
@onready var p1_fur_option: OptionButton = get_node_or_null("Margin/Panel/VBox/TabContainer/Puppies/VBox/HBox/BrunoCol/P1FurOption")

@onready var p2_name_edit: LineEdit = get_node_or_null("Margin/Panel/VBox/TabContainer/Puppies/VBox/HBox/MiloCol/P2NameEdit")
@onready var p2_collar_option: OptionButton = get_node_or_null("Margin/Panel/VBox/TabContainer/Puppies/VBox/HBox/MiloCol/P2CollarOption")
@onready var p2_tag_option: OptionButton = get_node_or_null("Margin/Panel/VBox/TabContainer/Puppies/VBox/HBox/MiloCol/P2TagOption")
@onready var p2_fur_option: OptionButton = get_node_or_null("Margin/Panel/VBox/TabContainer/Puppies/VBox/HBox/MiloCol/P2FurOption")
@onready var apply_custom_btn: Button = get_node_or_null("Margin/Panel/VBox/TabContainer/Puppies/VBox/ApplyCustomButton")

# Level Select controls
@onready var level_list: VBoxContainer = get_node_or_null("Margin/Panel/VBox/TabContainer/Levels/Scroll/LevelList")

# Save/Load Slot labels & buttons
@onready var slot1_label: Label = get_node_or_null("Margin/Panel/VBox/TabContainer/SaveLoad/VBox/Slot1HBox/Slot1Label")
@onready var slot1_save_btn: Button = get_node_or_null("Margin/Panel/VBox/TabContainer/SaveLoad/VBox/Slot1HBox/Slot1SaveBtn")
@onready var slot1_load_btn: Button = get_node_or_null("Margin/Panel/VBox/TabContainer/SaveLoad/VBox/Slot1HBox/Slot1LoadBtn")

@onready var slot2_label: Label = get_node_or_null("Margin/Panel/VBox/TabContainer/SaveLoad/VBox/Slot2HBox/Slot2Label")
@onready var slot2_save_btn: Button = get_node_or_null("Margin/Panel/VBox/TabContainer/SaveLoad/VBox/Slot2HBox/Slot2SaveBtn")
@onready var slot2_load_btn: Button = get_node_or_null("Margin/Panel/VBox/TabContainer/SaveLoad/VBox/Slot2HBox/Slot2LoadBtn")

@onready var slot3_label: Label = get_node_or_null("Margin/Panel/VBox/TabContainer/SaveLoad/VBox/Slot3HBox/Slot3Label")
@onready var slot3_save_btn: Button = get_node_or_null("Margin/Panel/VBox/TabContainer/SaveLoad/VBox/Slot3HBox/Slot3SaveBtn")
@onready var slot3_load_btn: Button = get_node_or_null("Margin/Panel/VBox/TabContainer/SaveLoad/VBox/Slot3HBox/Slot3LoadBtn")

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(3840, 2160),
	Vector2i(2560, 1440),
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1280, 720)
]

const COLLAR_COLORS: Dictionary = {
	"Ruby Red": Color(0.88, 0.22, 0.18, 1),
	"Ocean Blue": Color(0.18, 0.44, 0.88, 1),
	"Golden Amber": Color(1.0, 0.78, 0.2, 1),
	"Emerald Green": Color(0.2, 0.75, 0.35, 1),
	"Royal Purple": Color(0.65, 0.28, 0.85, 1),
	"Coral Pink": Color(0.95, 0.45, 0.55, 1),
	"Midnight Black": Color(0.15, 0.15, 0.18, 1)
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_footer_buttons()
	_setup_options_tab()
	_setup_customization_tab()
	_setup_level_select_tab()
	_setup_saveload_tab()

func _setup_footer_buttons() -> void:
	if resume_button:
		resume_button.pressed.connect(func():
			GameManager.toggle_pause()
		)
	if quit_button:
		quit_button.pressed.connect(func():
			get_tree().paused = false
			get_tree().change_scene_to_file("res://src/ui/chapter_select_menu.tscn")
		)

func _setup_options_tab() -> void:
	# Resolution Option
	if resolution_option:
		resolution_option.clear()
		for res in RESOLUTIONS:
			resolution_option.add_item("%d x %d" % [res.x, res.y])
		resolution_option.selected = 2 # 1080p
		resolution_option.item_selected.connect(_on_resolution_selected)
		
	# Window Mode Option
	if window_mode_option:
		window_mode_option.clear()
		window_mode_option.add_item("Windowed")
		window_mode_option.add_item("Borderless Windowed")
		window_mode_option.add_item("Exclusive Fullscreen")
		window_mode_option.selected = 0
		window_mode_option.item_selected.connect(_on_window_mode_selected)
		
	# V-Sync Check
	if vsync_check:
		vsync_check.button_pressed = true
		vsync_check.toggled.connect(func(pressed):
			var vsync_mode = DisplayServer.VSYNC_ENABLED if pressed else DisplayServer.VSYNC_DISABLED
			DisplayServer.window_set_vsync_mode(vsync_mode)
		)
		
	# Sound On/Off
	if sound_toggle_check:
		sound_toggle_check.button_pressed = AudioManager.is_sound_enabled()
		sound_toggle_check.toggled.connect(func(pressed):
			AudioManager.set_sound_enabled(pressed)
		)
		
	# Volume Sliders
	if master_slider:
		master_slider.value = AudioManager.master_volume * 100.0
		master_slider.value_changed.connect(func(val): AudioManager.set_master_volume(val / 100.0))
	if music_slider:
		music_slider.value = AudioManager.music_volume * 100.0
		music_slider.value_changed.connect(func(val): AudioManager.set_music_volume(val / 100.0))
	if sfx_slider:
		sfx_slider.value = AudioManager.sfx_volume * 100.0
		sfx_slider.value_changed.connect(func(val): AudioManager.set_sfx_volume(val / 100.0))
		
	# Split Screen Toggle
	if split_toggle_btn:
		_update_split_btn_label()
		split_toggle_btn.pressed.connect(func():
			GameManager.toggle_split_screen_orientation()
			_update_split_btn_label()
		)

func _update_split_btn_label() -> void:
	if split_toggle_btn:
		var mode = "Side-by-Side (Vertical)" if GameManager.split_is_vertical else "Top-and-Bottom (Horizontal)"
		split_toggle_btn.text = "Split Mode: %s" % mode

func _on_resolution_selected(index: int) -> void:
	if index >= 0 and index < RESOLUTIONS.size():
		var res = RESOLUTIONS[index]
		get_window().size = res

func _on_window_mode_selected(index: int) -> void:
	match index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

# ------------------------------------------------------------------------------
# Character Customization Setup
# ------------------------------------------------------------------------------

func _setup_customization_tab() -> void:
	var custom_data = SaveManager.get_customization()
	
	if p1_name_edit:
		p1_name_edit.text = custom_data.get("p1_name", "Bruno")
	if p2_name_edit:
		p2_name_edit.text = custom_data.get("p2_name", "Milo")
		
	# Collar color dropdowns
	if p1_collar_option:
		p1_collar_option.clear()
		for col_name in COLLAR_COLORS.keys():
			p1_collar_option.add_item(col_name)
		p1_collar_option.selected = 0 # Ruby Red
		
	if p2_collar_option:
		p2_collar_option.clear()
		for col_name in COLLAR_COLORS.keys():
			p2_collar_option.add_item(col_name)
		p2_collar_option.selected = 1 # Ocean Blue
		
	# Tag dropdowns
	if p1_tag_option:
		p1_tag_option.clear()
		p1_tag_option.add_item("Golden Bone")
		p1_tag_option.add_item("Silver Star")
		p1_tag_option.add_item("Brass Bell")
		p1_tag_option.add_item("Golden Heart")
		
	if p2_tag_option:
		p2_tag_option.clear()
		p2_tag_option.add_item("Brass Bell")
		p2_tag_option.add_item("Golden Bone")
		p2_tag_option.add_item("Silver Star")
		p2_tag_option.add_item("Golden Heart")
		
	if apply_custom_btn:
		apply_custom_btn.pressed.connect(_on_apply_customization)

func _on_apply_customization() -> void:
	var p1_name = p1_name_edit.text if p1_name_edit else "Bruno"
	var p2_name = p2_name_edit.text if p2_name_edit else "Milo"
	
	var col_names = COLLAR_COLORS.keys()
	var p1_col_name = col_names[p1_collar_option.selected] if p1_collar_option else "Ruby Red"
	var p2_col_name = col_names[p2_collar_option.selected] if p2_collar_option else "Ocean Blue"
	var p1_color: Color = COLLAR_COLORS[p1_col_name]
	var p2_color: Color = COLLAR_COLORS[p2_col_name]
	
	var custom_dict = {
		"p1_name": p1_name,
		"p1_collar_color": [p1_color.r, p1_color.g, p1_color.b, p1_color.a],
		"p1_tag_type": p1_tag_option.get_item_text(p1_tag_option.selected) if p1_tag_option else "Golden Bone",
		"p2_name": p2_name,
		"p2_collar_color": [p2_color.r, p2_color.g, p2_color.b, p2_color.a],
		"p2_tag_type": p2_tag_option.get_item_text(p2_tag_option.selected) if p2_tag_option else "Brass Bell"
	}
	
	SaveManager.save_customization(custom_dict)
	EventBus.customization_updated.emit(custom_dict, custom_dict)
	AudioManager.play_procedural_chime(523.25, 0.4)
	EventBus.notification_displayed.emit("PUPPY CUSTOMIZATION", "Names & Collar colors applied in real-time!", 2.5)

# ------------------------------------------------------------------------------
# Level Select Setup
# ------------------------------------------------------------------------------

func _setup_level_select_tab() -> void:
	if not level_list:
		return
	for c in level_list.get_children():
		c.queue_free()
		
	var all_chapters = ChapterProgression.get_all_chapters()
	for ch in all_chapters:
		var btn = Button.new()
		var idx = ch["index"]
		var is_unlocked = ChapterProgression.is_chapter_unlocked(idx)
		btn.custom_minimum_size = Vector2(0, 42)
		
		if is_unlocked:
			btn.text = "%s — %s (Boss: %s)" % [ch["title"], ch["subtitle"], ch["boss"]]
			btn.pressed.connect(func():
				get_tree().paused = false
				ChapterProgression.load_chapter(get_tree(), idx)
			)
		else:
			btn.text = "🔒 %s (Complete previous chapters)" % ch["title"]
			btn.disabled = true
			btn.modulate = Color(0.6, 0.6, 0.6, 0.7)
			
		level_list.add_child(btn)

# ------------------------------------------------------------------------------
# Multi-Slot Save/Load Setup
# ------------------------------------------------------------------------------

func _setup_saveload_tab() -> void:
	_refresh_save_slots()
	
	if slot1_save_btn:
		slot1_save_btn.pressed.connect(func(): _save_to_slot(1))
	if slot1_load_btn:
		slot1_load_btn.pressed.connect(func(): _load_from_slot(1))
		
	if slot2_save_btn:
		slot2_save_btn.pressed.connect(func(): _save_to_slot(2))
	if slot2_load_btn:
		slot2_load_btn.pressed.connect(func(): _load_from_slot(2))
		
	if slot3_save_btn:
		slot3_save_btn.pressed.connect(func(): _save_to_slot(3))
	if slot3_load_btn:
		slot3_load_btn.pressed.connect(func(): _load_from_slot(3))

func _refresh_save_slots() -> void:
	_update_slot_ui(1, slot1_label, slot1_load_btn)
	_update_slot_ui(2, slot2_label, slot2_load_btn)
	_update_slot_ui(3, slot3_label, slot3_load_btn)

func _update_slot_ui(slot_idx: int, label: Label, load_btn: Button) -> void:
	var info = SaveManager.get_slot_summary(slot_idx)
	if label:
		if info.get("exists", false):
			label.text = "Slot %d: %s | Bones: %d/64 | %s & %s (%s)" % [
				slot_idx, info.get("chapter_title", "Chapter"), info.get("golden_bones", 0),
				info.get("p1_name", "Bruno"), info.get("p2_name", "Milo"), info.get("time_str", "")
			]
		else:
			label.text = "Slot %d: [ Empty Save Slot ]" % slot_idx
	if load_btn:
		load_btn.disabled = not info.get("exists", false)

func _save_to_slot(slot_idx: int) -> void:
	var ok = SaveManager.save_slot(slot_idx)
	if ok:
		AudioManager.play_procedural_chime(659.25, 0.4)
		EventBus.notification_displayed.emit("SAVED", "Game saved to Slot %d!" % slot_idx, 2.5)
		_refresh_save_slots()

func _load_from_slot(slot_idx: int) -> void:
	var ok = SaveManager.load_slot(slot_idx)
	if ok:
		AudioManager.play_procedural_chime(523.25, 0.5)
		EventBus.notification_displayed.emit("LOADED", "Loading Slot %d..." % slot_idx, 2.5)
		get_tree().paused = false
		var ch_idx = SaveManager.current_save_data.get("chapter_index", 1)
		ChapterProgression.load_chapter(get_tree(), ch_idx)
