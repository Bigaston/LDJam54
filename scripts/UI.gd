extends Control

signal furniture_choosed(furniture: Furniture)

func _on_add_furniture_pressed(type: String):
	if type == "commode":
		var commode = load("res://objects/furnitures/Commode.tscn").instantiate()
		
		furniture_choosed.emit(commode)
	elif type == "bed":
		var bed = load("res://objects/furnitures/Bed.tscn").instantiate()
		
		furniture_choosed.emit(bed)
