extends Control

signal furniture_choosed(furniture: Furniture)

func add_available_furniture(furniture: Furniture):
	var container = $VBoxContainer
	
	var button = Button.new()
	button.text = furniture.name
	button.name = furniture.name
	
	button.pressed.connect(_on_add_furniture_pressed.bind(furniture))
	
	container.add_child(button)
	
func remove_available_furniture(name: String):
	var button = $VBoxContainer.get_node(name)
	
	button.queue_free()

func _on_add_furniture_pressed(furniture: Furniture):
	furniture_choosed.emit(furniture)
