class_name CrawlTunnel extends Node3D

## Low-Clearance Pipeline Accessible Exclusively by Milo When Crawling

@export var tunnel_id: String = "tunnel_01"
@export var entrance_prompt: String = "Press [Crawl] to slip inside!"

@onready var trigger_zone: Area3D = $TriggerZone

func _ready() -> void:
	if trigger_zone:
		trigger_zone.body_entered.connect(_on_body_entered)
		trigger_zone.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body is MiloCharacter:
		EventBus.interaction_available.emit(2, "Narrow Pipe", entrance_prompt)
		if not (body as MiloCharacter).is_crawling:
			(body as MiloCharacter).toggle_low_crawl(true)
	elif body is BrunoCharacter:
		EventBus.interaction_available.emit(1, "Narrow Pipe", "Too small for Bruno! Milo can crawl through.")

func _on_body_exited(body: Node3D) -> void:
	if body is MiloCharacter:
		EventBus.interaction_cleared.emit(2)
		# Restore normal stance upon exit if desired
	elif body is BrunoCharacter:
		EventBus.interaction_cleared.emit(1)
