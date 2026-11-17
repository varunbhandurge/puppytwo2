class_name ChapterSelectMenu extends Control

## Chapter Select & Campaign Hub UI
## Allows two players to inspect campaign chapters, view collected Golden Bones,
## adjust split-screen settings, open options & sound, and embark on any unlocked adventure.

@onready var chapter_list_container: VBoxContainer = get_node_or_null("MarginContainer/VBoxContainer/ScrollContainer/ChapterList")
@onready var total_bones_label: Label = get_node_or_null("MarginContainer/VBoxContainer/HeaderBar/BonesLabel")
@onready var split_toggle_button: Button = get_node_or_null("MarginContainer/VBoxContainer/FooterBar/SplitToggleButton")
@onready var back_button: Button = get_node_or_null("MarginContainer/VBoxContainer/FooterBar/BackButton")
@onready var options_button: Button = get_node_or_null("MarginContainer/VBoxContainer/FooterBar/OptionsButton")
@onready var pause_hub: Control = get_node_or_null("PauseMenu")

signal chapter_selected(chapter_index: int)

func _ready() -> void:
	_update_header()
	_populate_chapters()
	if split_toggle_button:
		split_toggle_button.pressed.connect(_on_split_toggle_pressed)
		_update_split_button_text()
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	if options_button and pause_hub:
		options_button.pressed.connect(func():
			pause_hub.visible = !pause_hub.visible
		)

func _update_header() -> void:
	if total_bones_label:
		total_bones_label.text = "🏆 Total Golden Bones: %d / %d" % [GameManager.golden_bones_collected, GameManager.total_golden_bones]

func _update_split_button_text() -> void:
	if split_toggle_button:
		var mode = "Side-by-Side (Vertical)" if GameManager.split_is_vertical else "Top-and-Bottom (Horizontal)"
		split_toggle_button.text = "Split: %s" % mode

func _populate_chapters() -> void:
	if not chapter_list_container:
		return
		
	# Clear placeholder children
	for c in chapter_list_container.get_children():
		c.queue_free()
		
	var all_chapters = ChapterProgression.get_all_chapters()
	for ch in all_chapters:
		var btn = Button.new()
		var idx = ch["index"]
		var is_unlocked = ChapterProgression.is_chapter_unlocked(idx)
		
		btn.custom_minimum_size = Vector2(0, 48)
		if is_unlocked:
			btn.text = "%s — %s (Boss: %s)" % [ch["title"], ch["subtitle"], ch["boss"]]
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
			btn.pressed.connect(func(): _on_chapter_button_pressed(idx))
		else:
			btn.text = "🔒 %s (Locked — Complete Previous Chapter)" % ch["title"]
			btn.disabled = true
			btn.modulate = Color(0.6, 0.6, 0.6, 0.8)
			
		chapter_list_container.add_child(btn)

func _on_chapter_button_pressed(idx: int) -> void:
	AudioManager.play_procedural_chime(523.25, 0.3)
	chapter_selected.emit(idx)
	ChapterProgression.load_chapter(get_tree(), idx)

func _on_split_toggle_pressed() -> void:
	GameManager.toggle_split_screen_orientation()
	_update_split_button_text()

func _on_back_pressed() -> void:
	ChapterProgression.load_chapter(get_tree(), 1)
