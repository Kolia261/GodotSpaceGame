class_name PlayerState
extends State

var ship: PlayerShip


func _ready() -> void:
	super()
	ship = owner
