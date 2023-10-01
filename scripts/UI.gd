extends Control

signal furniture_choosed(furniture: Furniture)
signal check_level()

func add_available_furniture(furniture: Furniture):
	var container = $VBoxContainer
	
	var button = Button.new()
	button.text = furniture.display_name
	button.name = furniture.display_name
	
	button.pressed.connect(_on_add_furniture_pressed.bind(furniture))
	
	container.add_child(button)
	
func remove_available_furniture(name: String):
	var button = $VBoxContainer.get_node(name)
	
	button.queue_free()

func _on_add_furniture_pressed(furniture: Furniture):
	furniture_choosed.emit(furniture)

func add_needs(need: String):
	var text = Label.new()
	text.text = need
	text.label_settings = load("res://ressources/fonts/text.tres")
	
	$ScrollContainer/TaskContainer.add_child(text)
	$ScrollContainer/TaskContainer.move_child(text, $ScrollContainer/TaskContainer/Title.get_index() + 1)

func _on_button_pressed():
	check_level.emit()
