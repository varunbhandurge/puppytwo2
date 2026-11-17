class_name Puzzle3SprinklerBridge extends PuzzleBase

## Puzzle 3: The Mechanical Sprinkler Bridge (Timing, Switch Activation & Pressure Plates)

@export var shutoff_pedal: PressurePlate = null
@export var brass_valve: Area3D = null
@export var water_hazard_particles: CPUParticles3D = null
@export var window_duration: float = 8.0

var window_timer: Timer = null
var is_window_open: bool = false

func _setup_puzzle() -> void:
	puzzle_id = "puzzle_03_sprinkler_bridge"
	puzzle_title = "The Sprinkler Bridge"
	total_stages = 3
	super._setup_puzzle()
	
	window_timer = Timer.new()
	window_timer.one_shot = true
	window_timer.wait_time = window_duration
	window_timer.timeout.connect(_on_window_timeout)
	add_child(window_timer)
	
	EventBus.pressure_plate_activated.connect(_on_pedal_activated)
	
	if brass_valve:
		brass_valve.body_entered.connect(_on_valve_reached)

func _on_pedal_activated(pid: String, active: bool) -> void:
	if shutoff_pedal and pid == shutoff_pedal.plate_id:
		if active and current_stage == 0:
			open_timing_window()
			complete_stage(1)

func open_timing_window() -> void:
	is_window_open = true
	if water_hazard_particles:
		water_hazard_particles.emitting = false
	if window_timer and window_timer.is_inside_tree():
		window_timer.start()
	EventBus.notification_displayed.emit("WATER SUPPRESSED!", "Milo, sprint across! (8s)", 2.0)

func _on_window_timeout() -> void:
	is_window_open = false
	if current_stage < 3:
		if water_hazard_particles:
			water_hazard_particles.emitting = true
		reset_puzzle()
		EventBus.notification_displayed.emit("WATER RESTORED", "Timing expired! Try again.", 1.5)

func _on_valve_reached(body: Node3D) -> void:
	if body is MiloCharacter and current_stage == 1 and is_window_open:
		complete_stage(2)
		complete_stage(3)

func solve_puzzle() -> void:
	super.solve_puzzle()
	window_timer.stop()
	if water_hazard_particles:
		water_hazard_particles.emitting = false
	EventBus.water_valve_closed.emit("valve_sprinkler_01")
