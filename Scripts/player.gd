extends CharacterBody3D
class_name Joueur

@export var speed = 5.0
@export var acceleration = 4.0
@export var jump_speed = 8.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
var camera_height = 8
var camera_pos = 0
var camera_lerp_time = 0
var camera_lerping = false
var camera_start = Vector3(0,camera_height,5)
var camera_end = Vector3(0,camera_height,5)

func _ready():
	camera.look_at(position)
	camera.position.y = camera_height

func get_move_input(delta):
	var vy = velocity.y
	velocity.y = 0
	var input = Input.get_vector("Left", "Right", "Forward", "Backward")
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, camera.rotation.y)
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	velocity.y = vy

func _physics_process(delta):
	velocity.y += -gravity * delta
	get_move_input(delta)
	if (!camera_lerping):
		if (Input.is_action_just_pressed("TurnLeft")):
			move_camera(true)
		elif (Input.is_action_just_pressed("TurnRight")):
			move_camera(false)
	else:
		if (camera_end == camera.position):
			camera_lerping = false
			camera_lerp_time = 0
			camera_start = camera_end
		elif (leave_body_protection(camera.position)):
			camera.position = camera_end
			camera_lerping = false
			camera_lerp_time = 0
			camera_start = camera_end
		else:
			lerp_camera(camera_start, camera_end, delta)
		camera.look_at(position)
	#print(camera.position)
	move_and_slide()

## Bouge la camera vers end en partant de start, deux Vecteur3
func lerp_camera(start, end, delta):
	camera_lerp_time += delta
	camera.position = start.lerp(end, camera_lerp_time)

func leave_body_protection(pos):
	if (pos.x > 5 or pos.x < -5):
		return true
	if (pos.z > 5 or pos.z < -5):
		return true
	return false

## Bouge la caméra vers la gauche ou la droite 
## du joueur, dépend du booléen donnée en paramètre 
## [(0,5), (5,0), (0,-5), (-5,0)]
func move_camera(left):
	if (left):
		match camera_pos:
			0:
				camera_end = Vector3(-5, camera_height, 0)
				camera_pos = 3
			3:
				camera_end = Vector3(0, camera_height, -5)
				camera_pos = 2
			2:
				camera_end = Vector3(5, camera_height, 0)
				camera_pos = 1
			1:
				camera_end = Vector3(0, camera_height, 5)
				camera_pos = 0
		#print(str(camera.position.x), " ", str(camera.position.z), " ", str(camera_pos))
	else:
		match camera_pos:
			0:
				camera_end = Vector3(5, camera_height, 0)
				camera_pos = 1
			1:
				camera_end = Vector3(0, camera_height, -5)
				camera_pos = 2
			2:
				camera_end = Vector3(-5, camera_height, 0)
				camera_pos = 3
			3:
				camera_end = Vector3(0, camera_height, 5)
				camera_pos = 0
	camera_lerping = true
