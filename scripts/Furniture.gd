extends Node3D
class_name Furniture

@export var display_name = ""

func is_placement_valid():
	return !$Area3D.has_overlapping_areas()
