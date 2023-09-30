extends Node3D

const RAY_LENGTH = 100

@onready var selector = $Selector

@export var transparent_mat: ShaderMaterial
@export var transparent_error_mat: ShaderMaterial
@export var debug_case: PackedScene

var selected_case = Vector2(0, 0)
var furniture_to_place = null
var current_rotation = 0
var last_frame_correct_status = null
var cam
var level

var placed_furniture: Array[Furniture] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	load_level(load("res://scenes/levels/Level1.tscn"))
	
func load_level(p_level: PackedScene):
	level = p_level.instantiate()
	
	add_child(level)
	add_camera()
	
	var ui = $UI
	
	for furniture_scene in level.available_furnitures:
		var furniture = furniture_scene.instantiate() 
		ui.add_available_furniture(furniture)
	
func add_camera():
	var camera_anchor = level.get_camera_anchor()
	
	cam = OrbitCamera.new(camera_anchor)
	camera_anchor.add_child(cam)
	
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
		furniture_to_place.rotation.y += deg_to_rad(90)
		current_rotation = (current_rotation+90) % 360
		
	if Input.is_action_just_pressed("furniture_cancel"):
		cancel_furniture_placement()
		
	if Input.is_action_just_pressed("furniture_place"):
		if furniture_to_place != null and furniture_to_place.is_placement_valid():
			set_material_of_furniture(furniture_to_place.get_node("Model"), null)
			
			for child in furniture_to_place.get_children():
				if child is Area3D:
					child.set_collision_layer_value(1, true)
			
			$UI.remove_available_furniture(furniture_to_place.name)
			
			placed_furniture.append(furniture_to_place)
			
			furniture_to_place = null
			last_frame_correct_status = null
			
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
			
			$UI.add_available_furniture(furniture.duplicate())
			
			placed_furniture = placed_furniture.filter(func(fur): return fur != furniture)			
			
			print(placed_furniture)
			
			furniture.queue_free()
		
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

func _on_ui_furniture_choosed(furniture):
	cancel_furniture_placement()
	
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

func _on_ui_check_level():
	print(is_level_completed())
	check_level_cases()

func check_level_cases():
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
			
			add_child(case)
			
			if char == "*":
				pass

func is_level_completed():
	var need_string = []
	
	for needed_furniture in level.needed_furnitures:
		var state = needed_furniture.get_state() as SceneState
		
		for i in range(0, state.get_node_property_count(0)):
			if state.get_node_property_name(0, i) == "display_name":
				need_string.append(state.get_node_property_value(0, i))
				
	var placed_string = []
	
	for placed in placed_furniture:
		placed_string.append(placed.display_name)
	
	need_string.sort()
	placed_string.sort()
	
	if need_string.size() != placed_string.size():
		return false
		
	for i in range(0, need_string.size()):
		if need_string[i] != placed_string[i]:
			return false
			
	return true
