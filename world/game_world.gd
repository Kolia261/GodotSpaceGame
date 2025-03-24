class_name GameWorld
extends Node2D

@export var radius := 8000.0

@export var iron_amount_balance_level := 100.0
@export var refresh_threshold_range := 25.0

var _spawned_positions := []
var _world_objects := []
var _iron_clusters := {}

@onready var rng := RandomNumberGenerator.new()

@onready var station_spawner: StationSpawner = $StationSpawner
@onready var asteroid_spawner: AsteroidSpawner = $AsteroidSpawner
@onready var pirate_spawner: PirateSpawner = $PirateSpawner


func _ready() -> void:
	await owner.ready
	setup()


func setup() -> void:
	rng.randomize()

	Events.upgrade_chosen.connect(_on_Events_upgrade_chosen)
	asteroid_spawner.cluster_depleted.connect(_on_AsteroidSpawner_cluster_depleted)

	station_spawner.spawn_station(rng)
	asteroid_spawner.spawn_asteroid_clusters(rng, iron_amount_balance_level, radius)
	pirate_spawner.spawn_pirate_group(
		rng, 0, radius, _find_largest_inoccupied_asteroid_cluster().global_position
	)


func _find_largest_inoccupied_asteroid_cluster() -> AsteroidCluster:
	var target_cluster: AsteroidCluster

	var target_cluster_iron_amount := -INF
	for cluster in asteroid_spawner.get_children():
		assert(cluster is AsteroidCluster)
		if cluster.is_occupied:
			continue
		if cluster.iron_amount > target_cluster_iron_amount:
			target_cluster = cluster
			target_cluster_iron_amount = cluster.iron_amount
	if target_cluster:
		target_cluster.is_occupied = true
	return target_cluster


func _on_Events_upgrade_chosen(_choice) -> void:
	var target_cluster := _find_largest_inoccupied_asteroid_cluster()
	if target_cluster:
		pirate_spawner.spawn_pirate_group(rng, 0, radius, target_cluster.global_position)


func _on_AsteroidSpawner_cluster_depleted(iron_left: float) -> void:
	if iron_left < refresh_threshold_range:
		asteroid_spawner.spawn_asteroid_clusters(rng, iron_amount_balance_level, radius)
