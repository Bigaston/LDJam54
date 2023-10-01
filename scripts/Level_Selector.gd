extends Control


func _on_level_1_pressed():
	var level = load("res://ressources/levels/Level1.tres")
	
	go_to_level(level)


func _on_level_2_pressed():
	var level = load("res://ressources/levels/Level1.tres")

	go_to_level(level)

func _on_level_3_pressed():
	var level = load("res://ressources/levels/Level1.tres")
	
	go_to_level(level)

func go_to_level(level: Level):
	pass
	
