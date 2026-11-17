class_name Puzzle1SunkenCrate extends PuzzleBase

## Puzzle 1: The Sunken Bone Crate (Weight & Water / Digging & Boosting)

@export var dig_mound: DigMound = null
@export var seesaw_pressure_plate: PressurePlate = null
@export var crate_lid_trigger: Area3D = null
@export var wooden_ramp_gate: Node3D = null

func _setup_puzzle() -> void:
	puzzle_id = "puzzle_01_sunken_crate"
	puzzle_title = "The Sunken Bone Crate"
	total_stages = 3
	super._setup_puzzle()
	
	if dig_mound:
		dig_mound.excavated.connect(func(_id): complete_stage(1))
	
	if seesaw_pressure_plate:
		EventBus.pressure_plate_activated.connect(func(pid, active):
			if pid == seesaw_pressure_plate.plate_id and active and current_stage == 1:
				complete_stage(2)
		)
	
	if crate_lid_trigger:
		crate_lid_trigger.body_entered.connect(func(body):
			if body is MiloCharacter and current_stage == 2:
				complete_stage(3)
		)

func solve_puzzle() -> void:
	super.solve_puzzle()
	if wooden_ramp_gate:
		var tw = create_tween()
		tw.tween_property(wooden_ramp_gate, "rotation:x", deg_to_rad(75.0), 1.2)
