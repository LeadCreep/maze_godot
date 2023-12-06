extends CharacterBody3D
class_name Joueur

@export var speed = 5.0
@export var acceleration = 4.0
@export var jump_speed = 8.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D

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
	move_and_slide()
	
