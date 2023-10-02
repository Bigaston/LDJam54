extends Control

signal choose_level(level: Level)

@export var completed_texture: Texture2D

@onready var LevelCompleted := get_node("/root/LevelCompleted")

func _ready():
	var map = $VBoxContainer/Map
	
	map.get_node("Level2").visible = false
	map.get_node("Level3").visible = false
	map.get_node("Level4").visible = false
	
	if LevelCompleted.level_completed.find(1) != -1:
		map.get_node("Level2").visible = true
		(map.get_node("Level1") as TextureButton).texture_normal = completed_texture
		
	if LevelCompleted.level_completed.find(2) != -1:
		map.get_node("Level3").visible = true
		(map.get_node("Level2") as TextureButton).texture_normal = completed_texture
		
	if LevelCompleted.level_completed.find(3) != -1:
		map.get_node("Level4").visible = true		
		(map.get_node("Level3") as TextureButton).texture_normal = completed_texture
		
	if LevelCompleted.level_completed.find(4) != -1:
		(map.get_node("Level4") as TextureButton).texture_normal = completed_texture			

func _on_level_1_pressed():
	var level = load("res://ressources/levels/Level1.tres")
	
	choose_level.emit(level)

func _on_level_2_pressed():
	var level = load("res://ressources/levels/Level2.tres")

	choose_level.emit(level)

func _on_level_3_pressed():
	var level = load("res://ressources/levels/Level3.tres")

	choose_level.emit(level)


func _on_level_4_pressed():
	var level = load("res://ressources/levels/Level4.tres")

	choose_level.emit(level)
