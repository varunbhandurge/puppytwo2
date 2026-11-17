class_name PuzzleBase extends Node3D

## Reusable Data-Driven Cooperative Puzzle Base Class

enum PuzzleState {
	LOCKED,
	ACTIVE,
	STAGE_SUCCESS,
	SOLVED,
	RESETTING
}

@export var puzzle_id: String = "puzzle_00"
@export var puzzle_title: String = "Cooperative Puzzle"
@export var total_stages: int = 3

var current_state: PuzzleState = PuzzleState.LOCKED
var current_stage: int = 0

signal puzzle_stage_advanced(stage_idx: int)
signal puzzle_completed(id: String)
signal puzzle_failed_reset()

func _ready() -> void:
	EventBus.puzzle_registered.emit(puzzle_id)
	_setup_puzzle()

func _setup_puzzle() -> void:
	current_state = PuzzleState.ACTIVE

func complete_stage(stage_idx: int) -> void:
	if current_state == PuzzleState.SOLVED:
		return
		
	if stage_idx == current_stage + 1:
		current_stage = stage_idx
		current_state = PuzzleState.STAGE_SUCCESS
		EventBus.puzzle_stage_completed.emit(puzzle_id, current_stage)
		puzzle_stage_advanced.emit(current_stage)
		
		if current_stage >= total_stages:
			solve_puzzle()
		else:
			current_state = PuzzleState.ACTIVE

func solve_puzzle() -> void:
	current_state = PuzzleState.SOLVED
	EventBus.puzzle_solved.emit(puzzle_id)
	puzzle_completed.emit(puzzle_id)
	EventBus.notification_displayed.emit("PUZZLE SOLVED!", puzzle_title, 2.5)

func reset_puzzle() -> void:
	current_state = PuzzleState.RESETTING
	current_stage = 0
	EventBus.puzzle_reset.emit(puzzle_id)
	puzzle_failed_reset.emit()
	current_state = PuzzleState.ACTIVE
