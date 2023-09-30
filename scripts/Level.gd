extends Node3D
class_name Level

@export var available_furnitures: Array[PackedScene]
@export var needed_furnitures: Array[PackedScene]
@export_file var map

func get_camera_anchor():
	return $CameraAnchor
