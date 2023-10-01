extends Node3D

class_name Marker

enum MarkerType {GROUND, GROUND_SUPER, WALL}

var type: MarkerType
var grid_position: Vector2
var occuped = false
