extends Node3D

const RAY_LENGTH = 10

@onready var selector = $Selector
@onready var level = $Level1

var selected_case = Vector2(0, 0)
var furniture_to_place = null
var current_rotation = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	# Visible position of the furniture
	if furniture_to_place == null:
		if selected_case != null:
			selector.visible = true
			selector.position = Vector3(selected_case.x + 0.5, 1, selected_case.y + 0.5)		
		else:
			selector.visible = false
	else:
		selector.visible = false
		
		if selected_case != null:
			furniture_to_place.visible = true
			furniture_to_place.position = Vector3(selected_case.x + 0.5, 0.5, selected_case.y + 0.5)
		else:
			furniture_to_place.visible = false
			
	# Rotation
	if Input.is_action_just_pressed("furniture_rotate"):
		furniture_to_place.rotation.y += deg_to_rad(90)
		current_rotation = (current_rotation+90) % 360
		
	# Check if position is correct
	if furniture_to_place != null && selected_case != null:
		print(check_if_furniture_outside())
		
func check_if_furniture_outside():
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
	
	print(str(current_rotation) + " " + str(rotated_size.x) + " " + str(rotated_size.y))
	
	if (selected_case.x + rotated_size.x <= level.size_x 
		and selected_case.y + rotated_size.y <= level.size_y
		and selected_case.y + rotated_size.y >= 0
		and selected_case.x + rotated_size.x >= 0):
		return false
	else:
		return true 

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
	print(furniture)
	
	furniture_to_place = furniture
	add_child(furniture_to_place)
