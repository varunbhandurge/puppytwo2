class_name PuppyCoopLab extends Node3D

## Puppy Co-op Lab: Polish Vertical Slice Testbed for Two Puppies

@onready var split_screen_manager: SplitScreenManager = $SplitScreenManager
@onready var bruno: BrunoCharacter = $World/Characters/Bruno
@onready var milo: MiloCharacter = $World/Characters/Milo

@onready var puzzle_1: Puzzle1SunkenCrate = $World/Puzzles/Puzzle1_SunkenCrate
@onready var puzzle_2: Puzzle2ScentMaze = $World/Puzzles/Puzzle2_ScentMaze
@onready var puzzle_3: Puzzle3SprinklerBridge = $World/Puzzles/Puzzle3_SprinklerBridge
@onready var boss_whiskers: BossGardenCat = $World/Enemies/BossWhiskers
@onready var checkpoint_start: CheckpointZone = $World/Checkpoints/CheckpointStart
@onready var checkpoint_garden: CheckpointZone = $World/Checkpoints/CheckpointGarden
@onready var checkpoint_boss: CheckpointZone = $World/Checkpoints/CheckpointBoss

func _ready() -> void:
	# Configure split-screen cameras
	if split_screen_manager and bruno and milo:
		split_screen_manager.assign_targets(bruno, milo)
	
	# Initial welcome notification
	EventBus.notification_displayed.emit(
		"PUPPY CO-OP LAB",
		"Welcome! Press [T] to toggle Split-Screen. Explore & Cooperate!",
		4.0
	)
	
	# Register starting checkpoint
	if checkpoint_start:
		GameManager.active_checkpoint_position = checkpoint_start.global_position
		GameManager.active_checkpoint_id = checkpoint_start.checkpoint_id
	
	# Connect puzzle progression events
	if puzzle_1:
		puzzle_1.puzzle_completed.connect(func(_id):
			EventBus.notification_displayed.emit("GATE UNLOCKED!", "Proceed through the Garden Briars!", 3.0)
		)
	
	if puzzle_2:
		puzzle_2.puzzle_completed.connect(func(_id):
			EventBus.notification_displayed.emit("MAZE CLEARED!", "Approaching the Sprinkler Bridge!", 3.0)
		)
	
	if puzzle_3:
		puzzle_3.puzzle_completed.connect(func(_id):
			EventBus.notification_displayed.emit("WATER SECURED!", "Entering Whiskers' Greenhouse Arena!", 3.0)
		)
