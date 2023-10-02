extends Node3D

const RAY_LENGTH = 100

signal return_level_choice()

@onready var selector = $Selector

@export var transparent_mat: ShaderMaterial
@export var transparent_error_mat: ShaderMaterial
@export var debug_case: PackedScene
@export var ground: PackedScene
@export var ground_super: PackedScene
@export var current_level: Level

@export_category("Score Value")
@export var SCORE_NORMAL_EMPTY = 50
@export var SCORE_SUPER_EMPTY = 100

var selected_case = Vector2(0, 0)
var furniture_to_place = null
var furniture_to_plate_button = null
var current_rotation = 0
var last_frame_correct_status = null
var cam
var level: Level

var placed_markers = []

var placed_furniture: Array[Furniture] = []

var initialized_from_code = false

# Called when the node enters the scene tree for the first time.
func initialise(level: Level):
	load_level(level)
	initialized_from_code = true

func _ready():
	if !initialized_from_code:
		load_level(current_level)
	
func load_level(p_level: Level):
	level = p_level
	
	# Add Furniture to UI
	var ui = $UI
	
	for furniture_scene in level.available_furnitures:
		var furniture = furniture_scene.instantiate() 
		ui.add_available_furniture(furniture)
		
	# Load level informations
	var file_access = FileAccess.open(level.map, FileAccess.READ)
	print(file_access.get_as_text())
	
	var lines = file_access.get_as_text().split("\n")
	
	for line in range(0, lines.size()):
		if lines[line] == "":
			continue
		
		var columns = lines[line].split("")
		
		for col in range(0, columns.size()):
			var char = columns[col]
			
			var case = debug_case.instantiate()
			
			case.position.x = col
			case.position.y = 0.5
			case.position.z = line
			case.grid_position = Vector2(col, line)
			
			add_child(case)
			
			placed_markers.append(case)
			
			if char == "*":
				case.type = Marker.MarkerType.GROUND
				
				var ground_instance = ground.instantiate()
			
				ground_instance.position = Vector3(col, 0, line)
				
				add_child(ground_instance)
			elif char == "$":
				case.type = Marker.MarkerType.GROUND_SUPER
				
				var ground_instance = ground_super.instantiate()
			
				ground_instance.position = Vector3(col, 0, line)
				
				add_child(ground_instance)
			elif char == "x":
				case.get_node("Area3D").set_collision_layer_value(3, true)
				case.get_node("Area3D").set_collision_layer_value(4, false)
				case.type = Marker.MarkerType.WALL
	
	# Camera
	var camera_anchor_parent = Node3D.new()
	
	camera_anchor_parent.position = Vector3(lines.size() / 2, 0.5, lines[0].split("").size() / 2)
	
	add_child(camera_anchor_parent)
	
	var camera_anchor = Node3D.new()
	
	camera_anchor.rotation.x = deg_to_rad(-60)
		
	camera_anchor_parent.add_child(camera_anchor)
		
	cam = OrbitCamera.new(camera_anchor)
	camera_anchor.add_child(cam)
	
	# Needs
	var needed_characs := {}
	
	for charac in level.needed_furnitures:
		if needed_characs.has(charac):
			needed_characs[charac] += 1
		else:
			needed_characs[charac] = 1
			
	for key in needed_characs.keys():
		$UI.add_needs(get_need_string(key, needed_characs[key]))
	
func get_need_string(furniture_type, number):
	var string = ""
	if number > 1:
		string = str(number) + " " + Level.FurnitureTypeNamePlural[furniture_type]
	else:
		string = str(number) + " " + Level.FurnitureTypeName[furniture_type]
		
	return string
			
func _process(delta):
	# Visible position of the furniture
	if furniture_to_place == null:
		if selected_case != null:
			selector.visible = true
			selector.position = Vector3(selected_case.x, 1, selected_case.y)		
		else:
			selector.visible = false
	else:
		selector.visible = false
		
		if selected_case != null:
			furniture_to_place.visible = true
			furniture_to_place.position = Vector3(selected_case.x, 0.5, selected_case.y)
		else:
			furniture_to_place.visible = false
			
	# Inputs
	if Input.is_action_just_pressed("furniture_rotate"):
		if furniture_to_place == null:
			return
		
		furniture_to_place.rotation.y += deg_to_rad(90)
		current_rotation = (current_rotation+90) % 360
		
	if Input.is_action_just_pressed("furniture_cancel"):
		cancel_furniture_placement()
		
	if Input.is_action_just_pressed("furniture_place"):
		if selected_case == null:
			return
		
		if furniture_to_place != null and furniture_to_place.is_placement_valid():
			set_material_of_furniture(furniture_to_place.get_node("Model"), null)
			
			for child in furniture_to_place.get_children():
				if child is Area3D:
					child.set_collision_layer_value(1, true)
			
			furniture_to_plate_button.queue_free()
			
			placed_furniture.append(furniture_to_place)
			
			var markers = furniture_to_place.get_markers()
			
			for marker in markers:
				marker.get_parent().occuped = true
			
			furniture_to_place = null
			last_frame_correct_status = null
			
			update_completed_goal()
			
	if Input.is_action_just_pressed("furniture_delete"):
		var space_state = get_world_3d().direct_space_state
		var mousepos = get_viewport().get_mouse_position()

		var origin = cam.project_ray_origin(mousepos)
		var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end, 0b00000000_00000000_00000000_00000001)
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)
		
		if !result.is_empty():
			var collider = result.collider as Area3D
			var furniture = collider.get_parent()
			
			var markers = furniture.get_markers()
			
			for marker in markers:
				marker.get_parent().occuped = true
			
			$UI.add_available_furniture(furniture.duplicate())
			
			placed_furniture = placed_furniture.filter(func(fur): return fur != furniture)			
			
			furniture.queue_free()
			update_completed_goal()
		
	# Check if position is correct
	if furniture_to_place != null && selected_case != null:
		if furniture_to_place.is_placement_valid():
			if last_frame_correct_status != true:
				last_frame_correct_status = true
				
				set_material_of_furniture(furniture_to_place.get_node("Model"), transparent_mat)
		else:
			if last_frame_correct_status != false:
				last_frame_correct_status = false
				
				set_material_of_furniture(furniture_to_place.get_node("Model"), transparent_error_mat)
		
func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end, 0b00000000_00000000_00000000_00000010)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		selected_case = null
	else:
		var found_position = result.get("position", Vector3(1000,0,1000))
		
		selected_case = Vector2(round(found_position.x), round(found_position.z))		

func _on_ui_furniture_choosed(furniture, button):
	cancel_furniture_placement()
	furniture_to_plate_button = button
	
	furniture_to_place = furniture.duplicate()
	
	for child in furniture_to_place.get_children():
		if child is Area3D:
			child.set_collision_layer_value(1, false)
	
	add_child(furniture_to_place)

func cancel_furniture_placement():
	if furniture_to_place != null:
		last_frame_correct_status = null
		
		furniture_to_place.queue_free()
		furniture_to_place = null

func set_material_of_furniture(model, material):
	for child in model.get_children():
		if child is MeshInstance3D:
			if child.get_child_count() > 0:
				set_material_of_furniture(child, material)
			
			var nb_materials = child.get_surface_override_material_count()
			
			for mat in range(0, nb_materials):
				child.set_surface_override_material(mat, material)

func _on_ui_finish_level():
	var nb_case_normal_empty = 0
	var nb_case_super_empty = 0
	var score = 0
	
	if update_completed_goal():
		for marker in placed_markers:
			if ((marker.type == Marker.MarkerType.GROUND or marker.type == Marker.MarkerType.GROUND_SUPER) 
				and !marker.occuped):
					
				for mark in placed_markers:
					if (
						(mark.grid_position.x == marker.grid_position.x - 1 
							and mark.grid_position.y == marker.grid_position.y)
						or (mark.grid_position.x == marker.grid_position.x + 1 
							and mark.grid_position.y == marker.grid_position.y)
						or (mark.grid_position.y == marker.grid_position.y - 1 
							and mark.grid_position.x == marker.grid_position.x)
						or (mark.grid_position.y == marker.grid_position.y + 1 
							and mark.grid_position.x == marker.grid_position.x)
						):
						if !mark.occuped && (mark.type == Marker.MarkerType.GROUND or mark.type == Marker.MarkerType.GROUND_SUPER):
							if marker.type == Marker.MarkerType.GROUND:
								score += SCORE_NORMAL_EMPTY
								nb_case_normal_empty+=1
							elif marker.type == Marker.MarkerType.GROUND_SUPER:
								score += SCORE_SUPER_EMPTY
								nb_case_super_empty+=1
								
							break

	$UI.display_score(nb_case_normal_empty, SCORE_NORMAL_EMPTY, nb_case_super_empty, SCORE_SUPER_EMPTY, score)


func update_completed_goal():
	var needed_characs := {}
	
	for charac in level.needed_furnitures:
		if needed_characs.has(charac):
			needed_characs[charac] += 1
		else:
			needed_characs[charac] = 1
			
	var placed_characs := {}
	
	for furniture in placed_furniture:
		for charac in furniture.characteristics:
			if placed_characs.has(charac):
				placed_characs[charac] += 1
			else:
				placed_characs[charac] = 1
	
	var number_of_fulfill = 0
	
	for key in needed_characs.keys():
		var string = get_need_string(key, needed_characs[key])
		
		if placed_characs.has(key) and placed_characs[key] >= needed_characs[key]:
			$UI.set_need_fullfill(string, true)
			
			number_of_fulfill+=1
		else:
			$UI.set_need_fullfill(string, false)
			
	var valide_level = number_of_fulfill >= needed_characs.keys().size()
	
	$UI.set_level_finishable(valide_level)
	
	return valide_level
	


func _on_ui_back_level():
	if get_node("/root/LevelCompleted").level_completed.find(level.level_index) == -1:
		get_node("/root/LevelCompleted").level_completed.append(level.level_index)
	return_level_choice.emit()
