class_name EventBusSingleton extends Node

## Global Decoupled Signal Bus for Two Puppies: The Great Adventure

# Character & Ability Signals
signal puppy_moved(player_id: int, global_pos: Vector3)
signal puppy_jumped(player_id: int)
signal puppy_landed(player_id: int)
signal puppy_barked(player_id: int, global_pos: Vector3, radius: float)
signal puppy_dug(player_id: int, global_pos: Vector3)
signal puppy_scent_toggled(player_id: int, is_active: bool)
signal puppy_crawl_toggled(player_id: int, is_crawling: bool)
signal snout_boost_initiated(booster_id: int, boosted_id: int)
signal snout_boost_completed(booster_id: int, boosted_id: int)
signal puppy_stunned(player_id: int, duration: float)
signal puppy_revived(player_id: int)
signal puppy_emotion_changed(player_id: int, emotion_name: String)

# Narrative & Cinematic Signals
signal cutscene_started(cutscene_id: String)
signal cutscene_ended(cutscene_id: String)
signal dialogue_line_started(speaker: String, text: String, emotion_icon: String)
signal dialogue_sequence_ended()
signal music_duck_requested(duck_db: float, duration: float)

# Interaction & Environment Signals
signal interaction_available(player_id: int, interactable_name: String, prompt_text: String)
signal interaction_cleared(player_id: int)
signal interaction_triggered(player_id: int, interactable_id: String)
signal pressure_plate_activated(plate_id: String, is_active: bool)
signal switch_toggled(switch_id: String, state: bool)
signal water_valve_closed(valve_id: String)

# Puzzle Signals
signal puzzle_registered(puzzle_id: String)
signal puzzle_state_changed(puzzle_id: String, new_state: int)
signal puzzle_stage_completed(puzzle_id: String, stage_index: int)
signal puzzle_solved(puzzle_id: String)
signal puzzle_reset(puzzle_id: String)

# Enemy & Boss Signals
signal enemy_alerted(enemy_id: String, target_player_id: int)
signal boss_phase_changed(boss_id: String, new_phase: int)
signal boss_attack_telegraphed(boss_id: String, attack_type: String, target_pos: Vector3, warning_time: float)
signal boss_hit(boss_id: String, damage: int, remaining_health: int)
signal boss_defeated(boss_id: String)

# System & Camera Signals
signal checkpoint_reached(checkpoint_id: String, safe_position: Vector3)
signal request_respawn(player_id: int)
signal split_orientation_toggled(is_vertical: bool)
signal camera_distance_changed(distance: float)
signal golden_bone_collected(bone_id: String, total_count: int)
signal notification_displayed(title: String, subtitle: String, duration: float)
signal objective_updated(main_objective: String, bruno_task: String, milo_task: String)
signal customization_updated(p1_custom: Dictionary, p2_custom: Dictionary)
signal game_pause_toggled(is_paused: bool)
