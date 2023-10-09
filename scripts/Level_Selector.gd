extends Control

signal choose_level(level: Level)

@export var completed_texture: Texture2D

@onready var LevelCompleted := get_node("/root/LevelCompleted")
@onready var map := $Map

func _ready():
	var level1 = map.get_node("Level1")
	var level2 = map.get_node("Level2")
	var level3 = map.get_node("Level3")
	var level4 = map.get_node("Level4")
	
	level2.visible = false
	level3.visible = false
	level4.visible = false
	
	level1.uv_pos = Vector2(level1.position.x / map.size.x, level1.position.y / map.size.y)
	level2.uv_pos = Vector2(level2.position.x / map.size.x, level2.position.y / map.size.y)
	level3.uv_pos = Vector2(level3.position.x / map.size.x, level3.position.y / map.size.y)
	level4.uv_pos = Vector2(level4.position.x / map.size.x, level4.position.y / map.size.y)
	
	if LevelCompleted.level_completed.find(1) != -1:
		level2.visible = true
		level1.texture_normal = completed_texture
		
	if LevelCompleted.level_completed.find(2) != -1:
		level3.visible = true
		level2.texture_normal = completed_texture
		
	if LevelCompleted.level_completed.find(3) != -1:
		level4.visible = true		
		level3.texture_normal = completed_texture
		
	if LevelCompleted.level_completed.find(4) != -1:
		level4.texture_normal = completed_texture
		
func _process(delta):
	for marker in map.get_children():
		# uv_pos est une propriété custom
		# Merci tanguy
		marker.position = map.position + marker.uv_pos * map.size
	

func _on_level_1_pressed():
	var level = preload("res://ressources/levels/Level1.tres")
	
	choose_level.emit(level)

func _on_level_2_pressed():
	var level = preload("res://ressources/levels/Level2.tres")

	choose_level.emit(level)

func _on_level_3_pressed():
	var level = preload("res://ressources/levels/Level3.tres")

	choose_level.emit(level)


func _on_level_4_pressed():
	var level = preload("res://ressources/levels/Level4.tres")

	choose_level.emit(level)
