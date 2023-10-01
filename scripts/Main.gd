extends Node

var level_selector = preload("res://scenes/Level_Selector.tscn")
var play_level = preload("res://scenes/Play_Level.tscn")

func _ready():
	var level_selector_node = level_selector.instantiate()
	
	level_selector_node.choose_level.connect(_on_level_choosed)
	level_selector_node.name = "Level_Selector"
	
	add_child(level_selector_node)

func _on_level_choosed(level: Level):
	var play_level_node = play_level.instantiate()
	
	play_level_node.return_level_choice.connect(_on_back_level)
	play_level_node.name = "Play_Level"
	
	play_level_node.initialise(level)

	add_child(play_level_node)
	get_node("Level_Selector").queue_free()
	

func _on_back_level():
	var level_selector_node = level_selector.instantiate()
	
	level_selector_node.choose_level.connect(_on_level_choosed)
	level_selector_node.name = "Level_Selector"
	
	add_child(level_selector_node)
	get_node("Play_Level").queue_free()
	
