extends Node3D
class_name Furniture

@export var size_x = 1
@export var size_y = 1

func is_placement_valid():
	
	return !$Area3D.has_overlapping_areas()
