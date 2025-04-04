class_name StatsCargo
extends Stats

@export var _max_cargo := 100.0
@export var _mining_rate := 10.0
@export var _unload_rate := 35.0

var cargo := 0.0: set = set_cargo


func _init() -> void:
	super()
	_update_all()


func get_max_cargo() -> float:
	return get_stat("max_cargo")


func get_mining_rate() -> float:
	return get_stat("mining_rate")


func get_unload_rate() -> float:
	return get_stat("unload_rate")


func set_cargo(value: float) -> void:
	cargo = clamp(value, 0.0, get_max_cargo())
	_update("cargo")
