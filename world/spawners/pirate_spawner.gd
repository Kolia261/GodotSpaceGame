class_name PirateSpawner
extends Node2D

@export var pirate_scene: PackedScene = null
@export var count_min := 1
@export var count_max := 5
@export var spawn_radius := 150.0


func spawn_pirate_group(
	rng: RandomNumberGenerator, _choice: int, world_radius: float, cluster_position: Vector2
) -> void:
	var spawn_position := cluster_position.normalized() * world_radius * 1.25

	var pirates_in_cluster := []
	for _i in range(rng.randi_range(count_min, count_max)):
		var pirate := pirate_scene.instantiate()
		pirate.position = (
			spawn_position
			+ Vector2.UP.rotated(rng.randf_range(0, PI * 2)) * spawn_radius
		)
		pirates_in_cluster.append(pirate)
	for p in pirates_in_cluster:
		p.setup_squad(
			p == pirates_in_cluster[0], pirates_in_cluster[0], cluster_position, pirates_in_cluster
		)
		p.setup_faction(get_tree().get_nodes_in_group("Pirates"))
		add_child(p)
		Events.pirate_spawned.emit(p)
