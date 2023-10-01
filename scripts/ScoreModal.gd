extends Panel

@export var label_settings: LabelSettings
@export var time_between_line = 2.0

signal back_level()

func _ready():
	visible = false
	$Container/BackToMenu.visible = false

func display_score(normal_case, normal_case_score, super_case, super_case_score, score):
	visible = true
	await get_tree().create_timer(time_between_line).timeout
	
	var normal_case_label = Label.new()
	normal_case_label.text = "Simple Space Empty: " + str(normal_case) + " * " + str(normal_case_score) + " = " + str(normal_case * normal_case_score)
	normal_case_label.label_settings = label_settings
	normal_case_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	$Container.add_child(normal_case_label)
	$Container.move_child(normal_case_label, $Container/ScoreTitle.get_index() + 1)
	
	await get_tree().create_timer(time_between_line).timeout
	
	var super_case_label = Label.new()
	super_case_label.text = "Super Space Empty: " + str(super_case) + " * " + str(super_case_score) + " = " + str(super_case * super_case_score)
	super_case_label.label_settings = label_settings
	super_case_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	$Container.add_child(super_case_label)
	$Container.move_child(super_case_label, normal_case_label.get_index() + 1)
	
	await get_tree().create_timer(time_between_line).timeout
	
	var total_label = Label.new()
	total_label.text = "Total: " + str(score)
	total_label.label_settings = label_settings
	total_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	$Container.add_child(total_label)
	$Container.move_child(total_label, super_case_label.get_index() + 1)
	
	await get_tree().create_timer(time_between_line).timeout

	$Container/BackToMenu.visible = true	


func _on_back_to_menu_pressed():
	back_level.emit()
