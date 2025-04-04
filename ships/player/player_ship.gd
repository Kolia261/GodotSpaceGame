class_name PlayerShip
extends CharacterBody2D

signal died

@export var stats: Resource = preload("res://ships/player/player_stats.tres")
@export var projectile_mask := 0
@export var ExplosionEffect: PackedScene
@export var map_icon: Resource

var dockables := []

@onready var shape := $CollisionShape3D
@onready var agent: GSAISteeringAgent = $StateMachine/Move.agent
@onready var camera_transform := $CameraTransform
@onready var timer := $MapTimer
@onready var cargo := $Cargo
@onready var move_state := $StateMachine/Move
@onready var gun := $Gun
@onready var laser_gun := $LaserGun
@onready var vfx := $VFX


func _ready() -> void:
	stats.initialize()
	Events.damaged.connect(_on_damaged)
	Events.upgrade_chosen.connect(_on_upgrade_chosen)
	stats.health_depleted.connect(die)
	gun.collision_mask = projectile_mask
	laser_gun.collision_mask = projectile_mask


func _toggle_map(map_up: bool, tween_time: float) -> void:
	if not map_up:
		timer.start(tween_time)
		await timer.timeout
	camera_transform.update_position = not map_up


func die() -> void:
	var effect := ExplosionEffect.instantiate()
	effect.global_position = global_position
	ObjectRegistry.register_effect(effect)

	died.emit()
	Events.player_died.emit()

	queue_free()


func grab_camera(camera: Camera2D) -> void:
	camera_transform.remote_path = camera.get_path()


func _on_damaged(target: Node, amount: int, _origin: Node) -> void:
	if not target == self:
		return

	stats.health -= amount


func _on_upgrade_chosen(choice: int) -> void:
	match choice:
		Events.UpgradeChoices.HEALTH:
			stats.add_modifier("max_health", 25.0)
		Events.UpgradeChoices.SPEED:
			stats.add_modifier("linear_speed_max", 125.0)
		Events.UpgradeChoices.CARGO:
			cargo.stats.add_modifier("max_cargo", 50.0)
		Events.UpgradeChoices.MINING:
			cargo.stats.add_modifier("mining_rate", 10.0)
			cargo.stats.add_modifier("unload_rate", 5.0)
		Events.UpgradeChoices.WEAPON:
			gun.stats.add_modifier("damage", 3.0)
			if gun.stats.get_stat("cooldown") > 0.2:
				gun.stats.add_modifier("cooldown", -0.05)
