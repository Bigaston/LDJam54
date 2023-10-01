extends Control

signal choose_level(level: Level)

func _on_level_1_pressed():
	var level = load("res://ressources/levels/Level1.tres")
	
	choose_level.emit(level)
	


func _on_level_2_pressed():
	var level = load("res://ressources/levels/Level2.tres")

	choose_level.emit(level)

func _on_level_3_pressed():
#	var level = load("res://ressources/levels/Level3.tres")
#
#	go_to_level(level)
	pass
