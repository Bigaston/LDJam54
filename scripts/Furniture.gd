extends Node3D
class_name Furniture

@export var display_name = ""
@export var characteristics: Array[Level.FurnitureType] = []

func is_placement_valid():	
	var areas = $Area3D.get_overlapping_areas()
	
	areas = areas.filter(func(area: Area3D): return !area.get_collision_layer_value(4))
	
	return !areas.size() > 0

func get_markers():
	var areas = $Area3D.get_overlapping_areas()
	
	areas = areas.filter(func(area: Area3D): return area.get_collision_layer_value(4))

	return areas
