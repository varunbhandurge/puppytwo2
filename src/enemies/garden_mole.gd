class_name GardenMoleEnemy extends EnemyBase

## Garden Mole Scout: Subterranean Critter Vulnerable to Booming Barks

@onready var mole_mesh: MeshInstance3D = get_node_or_null("MoleMesh")
@onready var stun_stars: CPUParticles3D = get_node_or_null("StunStars")

func _init() -> void:
	enemy_id = "enemy_garden_mole"
	move_speed = 2.0
	detection_radius = 6.0

func on_bark_sensed(player_id: int, pos: Vector3) -> void:
	# Booming bark stuns mole immediately
	apply_stun(3.5)
	if stun_stars:
		stun_stars.emitting = true
	EventBus.notification_displayed.emit("MOLE STUNNED!", "Bruno's bark startled the mole!", 1.5)
