@tool
extends Node3D

@onready var grid_map : GridMap = $GridMap

@export var start : bool = false : set = set_start
func set_start(val:bool)->void:
	var maze = generate()
	display_maze(maze)

@export var MAZE_SIZE : int = 51 : set = set_maze_size
@export var CENTER : int = 19 : set = set_center
@export var NB_ROOM : int = 10: set = set_nb_room
@export var ROOM_MIN : int = 5: set = set_room_min
@export var ROOM_MAX : int = 9: set = set_room_max

func set_maze_size(val : int)->void:
	MAZE_SIZE = val
	
func set_center(val : int)->void:
	CENTER = val
	
func set_nb_room(val : int)->void:
	NB_ROOM = val
	
func set_room_min(val : int)->void:
	ROOM_MIN = val
	
func set_room_max(val : int)->void:
	ROOM_MAX = val

func display_maze(maze : Array):
	grid_map.clear()
	var tile
	var x
	var y
	var z
	for i in range(MAZE_SIZE):
		for j in range(MAZE_SIZE):
			var cel = maze[i * MAZE_SIZE + j]
			x = j
			y = 0
			z = i
			if cel == 0:
				tile = 0
				y = -1
			if cel == 1:
				tile = 3
			if cel == 2:
				tile = 2
				y = -1
			if cel == 3:
				tile = 1
				y = -1
			grid_map.set_cell_item(Vector3(x, y, z), tile)

func in_maze(x : int, y : int) -> bool:
	return 0 <= x and x <= MAZE_SIZE and 0 <= y and y <= MAZE_SIZE

func create_room(maze : Array, x : int, y : int, size_x : int, size_y : int):
	for i in range(y, y + size_y):
		for j in range(x, x + size_x):
			if in_maze(j, i) and maze[i * MAZE_SIZE + j] == 1:
				maze[i * MAZE_SIZE + j] = 3

func generate() -> Array:
	print("generate ...")
	var rng = RandomNumberGenerator.new()
	#rng.randi_range(0, 3)
	var maze = []
	for i in range(MAZE_SIZE):
		for j in range(MAZE_SIZE):
			maze.append(1)
			
	# Créer la zone central
	for i in range(CENTER, MAZE_SIZE - CENTER):
		for j in range(CENTER, MAZE_SIZE - CENTER):
			maze[i * MAZE_SIZE + j] = 2
	
	# Créer les murs
	var rooms = []
	var size_x
	var size_y
	var x
	var y
	for nb in range(NB_ROOM):
		size_y = rng.randi_range(ROOM_MIN, ROOM_MAX)
		size_x = rng.randi_range(ROOM_MIN, ROOM_MAX)
		x = rng.randi_range(1, MAZE_SIZE-2-size_x)
		y = rng.randi_range(1, MAZE_SIZE-2-size_y)
		while maze[y * MAZE_SIZE + x] != 1 or ((CENTER - size_x) <= x and x <= (MAZE_SIZE - CENTER) and y <= (MAZE_SIZE - CENTER)):
			x = rng.randi_range(1, MAZE_SIZE-2-size_x)
			y = rng.randi_range(1, MAZE_SIZE-2-size_y)
		rooms.append([x, y, size_x, size_y])
		create_room(maze, x, y, size_x, size_y)
		
	
	
	
	return maze
