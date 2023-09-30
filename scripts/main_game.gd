extends Node3D

const RAY_LENGTH = 10

@onready var selector = $Selector
@onready var level = $Level1

@export var transparent_mat: ShaderMaterial
@export var transparent_error_mat: ShaderMaterial

var selected_case = Vector2(0, 0)
var furniture_to_place = null
var current_rotation = 0
var last_frame_correct_status = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
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
		if furniture_to_place != null:
			var mesh = furniture_to_place.get_children()
			set_material_of_furniture(mesh[0], null)
			
			furniture_to_place = null
			last_frame_correct_status = null
		
	# Check if position is correct
	if furniture_to_place != null && selected_case != null:
		if check_if_furniture_correct():
			if last_frame_correct_status != true:
				last_frame_correct_status = true
				
				var mesh = furniture_to_place.get_children()
				
				set_material_of_furniture(mesh[0], transparent_mat)
		else:
			if last_frame_correct_status != false:
				last_frame_correct_status = false
				
				var mesh = furniture_to_place.get_children()
				set_material_of_furniture(mesh[0], transparent_error_mat)
		
func check_if_furniture_correct():
	# TODO : Remplacer par la detection native de godot
	if furniture_to_place == null or selected_case == null:
		return
	
	var rotated_size = Vector2(furniture_to_place.size_x, furniture_to_place.size_y)
	
	if current_rotation == 0:
		rotated_size = Vector2(rotated_size.x - 1, rotated_size.y - 1)
	elif current_rotation == 90:
		rotated_size = Vector2(rotated_size.y - 1, -rotated_size.x + 1)
	elif current_rotation == 180:
		rotated_size = Vector2(-rotated_size.x + 1, rotated_size.y - 1)
	elif current_rotation == 270:
		rotated_size = Vector2(rotated_size.y - 1, rotated_size.x - 1)
	
	if (selected_case.x + rotated_size.x < level.size_x 
		and selected_case.y + rotated_size.y < level.size_y
		and selected_case.y + rotated_size.y >= 0
		and selected_case.x + rotated_size.x >= 0):
		return true
	else:
		return false 

func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var cam = $Level1/CameraAnchor/OrbitCamera
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		selected_case = null
	else:
		var found_position = result.get("position", Vector3(1000,0,1000))
		
		selected_case = Vector2(round(found_position.x), round(found_position.z))		

func _on_ui_furniture_choosed(furniture):
	cancel_furniture_placement()
	
	furniture_to_place = furniture
	add_child(furniture_to_place)

func cancel_furniture_placement():
	if furniture_to_place != null:
		last_frame_correct_status = null
		
		furniture_to_place.queue_free()
		furniture_to_place = null

func set_material_of_furniture(mesh, material):
	var nb_materials = mesh.get_surface_override_material_count()
	
	for mat in range(0, nb_materials):
		(mesh as MeshInstance3D).set_surface_override_material(mat, material)
