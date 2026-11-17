class_name SteamManagerSingleton extends Node

## Steamworks SDK Integration & Cloud Save Manager
## Handles Steam Achievements, Rich Presence, Steam Cloud saves,
## and gracefully falls back to DRM-free offline mode when Steam is unavailable.

const STEAM_APP_ID: int = 2854000 # Two Puppies: The Great Adventure Steam ID (Fallback 480)

var is_steam_initialized: bool = false
var steam_username: String = "Puppy Adventurer"
var steam_user_id: int = 0
var unlocked_achievements: Dictionary = {}

const ACHIEVEMENTS: Dictionary = {
	"ACH_CHAPTER_1_COMPLETE": {"name": "Backyard Breakout", "desc": "Escaped the backyard into the great wide world."},
	"ACH_CHAPTER_2_COMPLETE": {"name": "Greenhouse Scramble", "desc": "Traversed the overgrown garden and befriended Whiskers."},
	"ACH_CHAPTER_3_COMPLETE": {"name": "Kitchen Countertop", "desc": "Tamed the Appliance Golem and opened the screen door."},
	"ACH_CHAPTER_4_COMPLETE": {"name": "Canopy Connoisseur", "desc": "Outwitted Corvus the Crow King in the giant redwoods."},
	"ACH_CHAPTER_5_COMPLETE": {"name": "Rapid Rafting", "desc": "Navigated the whitewater flumes of the Riverlands."},
	"ACH_CHAPTER_6_COMPLETE": {"name": "Clockwork Champion", "desc": "Disarmed the giant Clockwork Titan in the toy factory."},
	"ACH_CHAPTER_7_COMPLETE": {"name": "Cavern Chimes", "desc": "Earned the Mole King's respect and rode the steam elevator."},
	"ACH_CAMPAIGN_COMPLETE": {"name": "The Aura Bone", "desc": "Reached the mountain summit and found true forever home."},
	"ACH_BONE_COLLECTOR_HALF": {"name": "Bone Seeker", "desc": "Collected 32 Golden Bone artifacts."},
	"ACH_BONE_COLLECTOR_ALL": {"name": "Golden Hoarder", "desc": "Collected all 64 Golden Bone artifacts!"},
	"ACH_FETCH_CHAMPION": {"name": "Fetch Master", "desc": "Retrieved 5 consecutive tennis balls in squeaky ball fetch."},
	"ACH_FRIENDS_FOREVER": {"name": "Unbreakable Bond", "desc": "Selflessly offered the mountain wish to your brother."}
}

signal achievement_unlocked(achievement_id: String)
signal cloud_save_synced(success: bool)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_steam()
	_connect_event_bus()

func _init_steam() -> void:
	# Check for GDExtension Steam singleton if available in production export
	if Engine.has_singleton("Steam"):
		var steam = Engine.get_singleton("Steam")
		var init_res = steam.steamInit(false)
		if init_res.get("status", 1) == 0:
			is_steam_initialized = true
			steam_username = steam.getPersonaName()
			steam_user_id = steam.getSteamID()
			print(">>> Steamworks initialized for user: %s (ID: %d)" % [steam_username, steam_user_id])
			return

	# Offline / Standalone Fallback Mode
	is_steam_initialized = false
	steam_username = "Local Puppy"
	print(">>> Steamworks running in DRM-free Offline/Standalone Mode.")

func _connect_event_bus() -> void:
	EventBus.golden_bone_collected.connect(_on_golden_bone_collected)

func unlock_achievement(ach_id: String) -> bool:
	if not ACHIEVEMENTS.has(ach_id):
		push_warning("Unknown achievement requested: " + ach_id)
		return false
		
	if unlocked_achievements.get(ach_id, false):
		return true # Already unlocked
		
	unlocked_achievements[ach_id] = true
	var ach_meta = ACHIEVEMENTS[ach_id]
	
	if is_steam_initialized and Engine.has_singleton("Steam"):
		var steam = Engine.get_singleton("Steam")
		steam.setAchievement(ach_id)
		steam.storeStats()
		
	achievement_unlocked.emit(ach_id)
	EventBus.notification_displayed.emit("ACHIEVEMENT UNLOCKED: " + ach_meta["name"], ach_meta["desc"], 4.5)
	AudioManager.play_procedural_chime(880.0, 1.2)
	return true

func is_achievement_unlocked(ach_id: String) -> bool:
	return unlocked_achievements.get(ach_id, false)

func set_rich_presence(status_text: String) -> void:
	if is_steam_initialized and Engine.has_singleton("Steam"):
		var steam = Engine.get_singleton("Steam")
		steam.setRichPresence("status", status_text)
		steam.setRichPresence("steam_display", "#StatusWithoutScore")

func sync_cloud_save() -> bool:
	# Synchronize user://saves/savegame.dat with Steam Remote Storage if active
	if is_steam_initialized and Engine.has_singleton("Steam"):
		var steam = Engine.get_singleton("Steam")
		if FileAccess.file_exists(SaveManager.SAVE_FILE_PATH):
			var file = FileAccess.open(SaveManager.SAVE_FILE_PATH, FileAccess.READ)
			if file:
				var data = file.get_as_text()
				file.close()
				var written = steam.fileWrite("savegame.dat", data.to_utf8_buffer())
				cloud_save_synced.emit(written)
				return written
	
	cloud_save_synced.emit(true)
	return true

func _on_golden_bone_collected(_bone_id: String, total_count: int) -> void:
	if total_count >= 32:
		unlock_achievement("ACH_BONE_COLLECTOR_HALF")
	if total_count >= 64:
		unlock_achievement("ACH_BONE_COLLECTOR_ALL")
