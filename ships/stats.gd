class_name Stats
extends Resource

signal stat_changed(stat, old_value, new_value)

var _stats_list := _get_stats_list()
var _modifiers := {}
var _cache := {}


func _init() -> void:
	for stat in _stats_list:
		_modifiers[stat] = []
		_cache[stat] = 0.0


func initialize() -> void:
	_update_all()


func get_stat(stat_name := "") -> float:
	assert(stat_name in _stats_list)
	return _cache[stat_name]


func add_modifier(stat_name: String, modifier: float) -> int:
	assert(stat_name in _stats_list)
	_modifiers[stat_name].append(modifier)
	_update(stat_name)
	return len(_modifiers)


func remove_modifier(stat_name: String, id: int) -> void:
	assert(stat_name in _stats_list)
	_modifiers[stat_name].erase(id)
	_update(stat_name)


func pop_modifier(stat_name: String) -> void:
	assert(stat_name in _stats_list)
	_modifiers[stat_name].pop_back()
	_update(stat_name)


func reset() -> void:
	_modifiers = {}
	_update_all()


func _update(stat: String = "") -> void:
	var value_start: float = self.get(_stats_list[stat])
	var value = value_start
	for modifier in _modifiers[stat]:
		value += modifier
	_cache[stat] = value
	stat_changed.emit(stat, value_start, value)


func _update_all() -> void:
	for stat in _stats_list:
		_update(stat)

func _get_stats_list() -> Dictionary:
	var ignore := [
		"resource_scene_unique_id",
		"resource_local_to_scene",
		"resource_name",
		"resource_path",
		"script",
		"_stats_list",
		"_modifiers",
		"_cache"
	]
	var stats := {}
	for p in get_property_list():
		if p.name[0].capitalize() == p.name[0]:
			continue
		if p.name in ignore:
			continue
		if p.name.ends_with(".gd"):
			continue
		stats[p.name.lstrip("_")] = p.name
	return stats
