extends Node3D
class_name Furniture

func is_placement_valid():
	return !$Area3D.has_overlapping_areas()
