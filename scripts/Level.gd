extends Node3D
class_name Level

@export var available_furnitures: Array[PackedScene]

func get_camera_anchor():
	return $CameraAnchor
