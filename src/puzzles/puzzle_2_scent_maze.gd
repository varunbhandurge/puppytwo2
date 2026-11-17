class_name Puzzle2ScentMaze extends PuzzleBase

## Puzzle 2: The Bramble Maze & Scent Trail (Stealth, Scent & Crawl Tunnel)

@export var scent_trail: ScentParticleTrail = null
@export var crawl_tunnel: CrawlTunnel = null
@export var drawbridge_lever: Area3D = null
@export var bramble_gate: Node3D = null

func _setup_puzzle() -> void:
	puzzle_id = "puzzle_02_scent_maze"
	puzzle_title = "The Bramble Maze & Scent Trail"
	total_stages = 3
	super._setup_puzzle()
	
	EventBus.puppy_scent_toggled.connect(func(pid, active):
		if pid == 2 and active and current_stage == 0:
			complete_stage(1)
	)
	
	EventBus.puppy_crawl_toggled.connect(func(pid, is_crawling):
		if pid == 2 and is_crawling and current_stage == 1:
			complete_stage(2)
	)
	
	if drawbridge_lever:
		drawbridge_lever.body_entered.connect(func(body):
			if body is MiloCharacter and current_stage == 2:
				complete_stage(3)
		)

func solve_puzzle() -> void:
	super.solve_puzzle()
	if bramble_gate:
		var tw = create_tween()
		tw.tween_property(bramble_gate, "position:y", bramble_gate.position.y - 3.0, 1.4)
