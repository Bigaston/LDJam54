extends Control

signal furniture_choosed(furniture: Furniture, button: TextureButton)
signal finish_level()
signal back_level()

func add_available_furniture(furniture: Furniture):
	var container = $ScrollContainer2/VBoxContainer
	
	var button := TextureButton.new()
	button.texture_normal = furniture.cover
	button.name = furniture.display_name
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.custom_minimum_size = Vector2(0, 300)
	
	button.pressed.connect(_on_add_furniture_pressed.bind(furniture, button))
	
	container.add_child(button)

func _on_add_furniture_pressed(furniture: Furniture, button: TextureButton):
	furniture_choosed.emit(furniture, button)

func add_needs(need: String):
	var text := RichTextLabel.new()
	text.text = "[img]res://ressources/images/x.png[/img] " +need
	text.name = "need_" + need
	text.theme = preload("res://ressources/fonts/text_label.tres")
	text.bbcode_enabled = true
	text.custom_minimum_size = Vector2(0, 40)
	
	$ScrollContainer/TaskContainer.add_child(text)
	$ScrollContainer/TaskContainer.move_child(text, $ScrollContainer/TaskContainer/Title.get_index() + 1)

func set_need_fullfill(need: String, filled: bool):
	var text = $ScrollContainer/TaskContainer.get_node("need_" + need)
	
	if filled:
		text.text = "[img]res://ressources/images/check.png[/img] " +need
	else:
		text.text = "[img]res://ressources/images/x.png[/img] " +need
		
func set_level_finishable(value: bool):
	$ScrollContainer/TaskContainer/FinishLevelButton.disabled = !value


func _on_finish_level_button_pressed():
	finish_level.emit()
	
func display_score(normal_case, normal_case_score, super_case, super_case_score, score):
	$ScoreModal.display_score(normal_case, normal_case_score, super_case, super_case_score, score)


func _on_score_modal_back_level():
	back_level.emit()
