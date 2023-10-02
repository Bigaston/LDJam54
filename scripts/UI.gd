extends Control

signal furniture_choosed(furniture: Furniture, button: Button)
signal finish_level()
signal back_level()

func add_available_furniture(furniture: Furniture):
	var container = $ScrollContainer2/VBoxContainer
	
	var button = Button.new()
	button.text = furniture.display_name
	button.name = furniture.display_name
	
	button.pressed.connect(_on_add_furniture_pressed.bind(furniture, button))
	
	container.add_child(button)

func _on_add_furniture_pressed(furniture: Furniture, button: Button):
	furniture_choosed.emit(furniture, button)

func add_needs(need: String):
	var text = Label.new()
	text.text = "❌" + need
	text.name = "need_" + need
	text.label_settings = load("res://ressources/fonts/text.tres")
	
	$ScrollContainer/TaskContainer.add_child(text)
	$ScrollContainer/TaskContainer.move_child(text, $ScrollContainer/TaskContainer/Title.get_index() + 1)

func set_need_fullfill(need: String, filled: bool):
	var text = $ScrollContainer/TaskContainer.get_node("need_" + need)
	
	if filled:
		text.text = "✔️" + need
	else:
		text.text = "❌" + need
		
func set_level_finishable(value: bool):
	$ScrollContainer/TaskContainer/FinishLevelButton.disabled = !value


func _on_finish_level_button_pressed():
	finish_level.emit()
	
func display_score(normal_case, normal_case_score, super_case, super_case_score, score):
	$ScoreModal.display_score(normal_case, normal_case_score, super_case, super_case_score, score)


func _on_score_modal_back_level():
	back_level.emit()
