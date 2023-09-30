extends Node3D

const RAY_LENGTH = 10

@export var size_x = 6
@export var size_y = 4

@onready var selector = $Selector

var selected_case = Vector2(0, 0)
var furniture_to_place = null

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
			furniture_to_place.position = Vector3(selected_case.x, 1, selected_case.y)
		else:
			furniture_to_place.visible = false
			
	# Rotation
	if Input.is_action_just_pressed("furniture_rotate"):
		furniture_to_place.rotation.y += deg_to_rad(90)

func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var cam = $CameraAnchor/OrbitCamera
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
