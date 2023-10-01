extends Node3D
class_name Furniture

@export var display_name = ""
@export var characteristics: Array[Level.FurnitureType] = []

func is_placement_valid():
	return !$Area3D.has_overlapping_areas()
