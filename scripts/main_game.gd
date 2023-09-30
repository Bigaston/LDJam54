extends Node3D

const RAY_LENGTH = 10

@export var size_x = 6
@export var size_y = 4

@onready var selector = $Selector

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var cam = $CameraAnchor/OrbitCamera
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	var found_position = result.get("position", Vector3(1000,0,1000))
	
	selector.position = Vector3(round(found_position.x), 1, round(found_position.z))
	
	

#func _input(event):
#	if event is InputEventMouseButton:
#		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
#			var space_state = get_world_3d().direct_space_state
#			var cam = $CameraAnchor/OrbitCamera
#			var mousepos = get_viewport().get_mouse_position()
#
#			var origin = cam.project_ray_origin(mousepos)
#			var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
#			var query = PhysicsRayQueryParameters3D.create(origin, end)
#			query.collide_with_areas = true
#
#			var result = space_state.intersect_ray(query)
#
#			print(result)
