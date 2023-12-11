extends CharacterBody3D
class_name Joueur

@export var speed = 5.0
@export var acceleration = 4.0
@export var jump_speed = 8.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
var camera_pos = 0

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
	if (Input.is_action_just_pressed("TurnLeft")):
		move_camera(true)
	elif (Input.is_action_just_pressed("TurnRight")):
		move_camera(false)
	move_and_slide()

## Bouge la caméra vers la gauche ou la droite 
## du joueur, dépend du booléen donnée en paramètre 
## [(0,5), (5,0), (0,-5), (-5,0)]
func move_camera(left):
	if (left):
		camera.rotate_y(deg_to_rad(-90))
		match camera_pos:
			0:
				camera.position.x = -5
				camera.position.z = 0
				camera_pos = 3
			3:
				camera.position.x = 0
				camera.position.z = -5
				camera_pos = 2
			2:
				camera.position.x = 5
				camera.position.z = 0
				camera_pos = 1
			1:
				camera.position.x = 0
				camera.position.z = 5
				camera_pos = 0
		#print(str(camera.position.x), " ", str(camera.position.z), " ", str(camera_pos))
	else:
		camera.rotate_y(deg_to_rad(90))
		match camera_pos:
			0:
				camera.position.x = 5
				camera.position.z = 0
				camera_pos = 1
			1:
				camera.position.x = 0
				camera.position.z = -5
				camera_pos = 2
			2:
				camera.position.x = -5
				camera.position.z = 0
				camera_pos = 3
			3:
				camera.position.x = 0
				camera.position.z = 5
				camera_pos = 0
			
			
