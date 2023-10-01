extends Resource
class_name Level

enum FurnitureType {BED, TABLE, SIT, STORAGE}

@export var available_furnitures: Array[PackedScene]
@export var needed_furnitures: Array[FurnitureType]
@export_file var map
