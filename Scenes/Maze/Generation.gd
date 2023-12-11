@tool
extends Node3D

@onready var grid_map : GridMap = $GridMap

@export var start : bool = false : set = set_start
@warning_ignore("unused_parameter")
func set_start(val:bool)->void:
	var maze_tmp = generate()
	var maze = update_maze(maze_tmp)
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
	for i in range(MAZE_SIZE * 3):
		for j in range(MAZE_SIZE * 3):
			var cel = maze[i][j]
			x = j
			y = 0
			z = i
			if cel == 0:
				tile = 0
				y = -1
			if cel == 1:
				tile = 1
			if cel == 2:
				tile = 2
				y = -1
			if cel == 3:
				tile = 3
				y = -1
			grid_map.set_cell_item(Vector3(x, y, z), tile)

func in_maze(x : int, y : int) -> bool:
	return 0 <= x and x < MAZE_SIZE and 0 <= y and y < MAZE_SIZE

func create_room(maze : Array, x : int, y : int, size_x : int, size_y : int):
	for i in range(y, y + size_y):
		for j in range(x, x + size_x):
			if in_maze(j, i) and maze[i * MAZE_SIZE + j] == 1:
				maze[i * MAZE_SIZE + j] = 3

func cpt_true(tab : Array):
	var cpt = 0
	for i in tab:
		if i:
			cpt += 1
	return cpt

func verif_true(maze : Array, elem : Array):
	var tab_dir = [[-1, 0], [0, -1], [1, 0], [0, 1]]
	for ind_i in range(tab_dir.size()):
		var i = tab_dir[ind_i]
		var x = elem[0] + i[0] * 2
		var y = elem[1] + i[1] * 2
		var verif = true
		if in_maze(x, y) and maze[y * MAZE_SIZE + x] == 1:
			for ind_j in range(tab_dir.size()):
				var j = tab_dir[ind_j]
				var new_x = x + j[0]
				var new_y = y + j[1]
				if (ind_i == 0 and ind_j != 2) and (ind_i == 1 and ind_j!= 3) and (ind_i == 2 and ind_j != 0) and (ind_i == 3 and ind_j != 1):
					if in_maze(new_x, new_x) and maze[new_y * MAZE_SIZE + new_x] != 1:
						verif = false
			if verif:
				elem[2][ind_i] = true
		else:
			if elem[2][ind_i]:
				elem[2][ind_i] = false

func avancer(maze : Array, walls : Array):
	var rng = RandomNumberGenerator.new()
	var tab_dir = [[-1, 0], [0, -1], [1, 0], [0, 1]]
	var valide = []
	verif_true(maze, walls[walls.size()-1])
	for ind in range(walls[walls.size()-1][2].size()):
		var i = walls[walls.size()-1][2][ind]
		if i:
			valide.append(ind)
	if valide.size() != 0:
		var ind = rng.randi_range(0, valide.size()-1)
		var dir = tab_dir[valide[ind]]
		var x_1 = walls[-1][0] + dir[0]
		var y_1 = walls[-1][1] + dir[1]
		var x_2 = walls[-1][0] + dir[0] + dir[0]
		var y_2 = walls[-1][1] + dir[1] + dir[1]
		if in_maze(x_1, y_1) and in_maze(x_2, y_2):
			maze[y_1 * MAZE_SIZE + x_1] = 0
			maze[y_2 * MAZE_SIZE + x_2] = 0
		
		var elem = [x_2, y_2, [false, false, false, false]]
		verif_true(maze, elem)
		walls.append(elem)
		avancer(maze, walls)
	if walls.size() != 0 and cpt_true(walls[walls.size()-1][2]) == 0:
		reculer(maze, walls)

func reculer(maze : Array, walls : Array):
	while walls.size() != 0 and cpt_true(walls[walls.size()-1][2]) == 0:
		walls.pop_back()
		if walls.size() > 0:
			verif_true(maze, walls[walls.size()-1])
	
	if walls.size() > 0 and cpt_true(walls[walls.size()-1][2]) != 0:
		avancer(maze, walls)
 
func generate() -> Array:
	print("generate ...")
	var rng = RandomNumberGenerator.new()
	#rng.randi_range(0, 3)
	var maze = []
	for i in range(MAZE_SIZE):
		for j in range(MAZE_SIZE):
			maze.append(1)
			
	# Créer la zone central
	for i in range(CENTER + 1, MAZE_SIZE - CENTER):
		for j in range(CENTER, MAZE_SIZE - CENTER):
			maze[i * MAZE_SIZE + j] = 2
	
	# Créer les pièces
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
		
	# Replacer les murs
	for i in range(CENTER - 1, MAZE_SIZE - CENTER + 1):
		maze[i * MAZE_SIZE + CENTER -1] = 2
		maze[i * MAZE_SIZE + MAZE_SIZE - CENTER] = 2
	for j in range(CENTER - 1, MAZE_SIZE - CENTER + 1):
		maze[(CENTER) * MAZE_SIZE + j] = 2
		maze[(MAZE_SIZE - CENTER) * MAZE_SIZE + j] = 2
	for i in range(0, MAZE_SIZE):
		maze[i * MAZE_SIZE] = 1
		maze[i * MAZE_SIZE + MAZE_SIZE - 1] = 1
	for j in range(0, MAZE_SIZE):
		maze[j] = 1
		maze[(MAZE_SIZE - 1) * MAZE_SIZE + j] = 1
	
	# Créer le labyrinthe
	maze[CENTER * MAZE_SIZE + 51 / 2] = 0
	var walls = [[51 / 2, CENTER, [false, true, false, false]]]
	avancer(maze, walls)
	
	var test = [3, 1]
	for room in rooms:
		for i in range(room[1], room[1] + room[3]):
			if not (maze[i * MAZE_SIZE + room[0] - 1] in test and maze[i * MAZE_SIZE + room[0] + 1] in test):
				if not (maze[i * MAZE_SIZE + room[0] - 1] == -1 and maze[i * MAZE_SIZE + room[0] + 1] == -3):
					maze[i * MAZE_SIZE + room[0]] = 1
			if not (maze[i * MAZE_SIZE + room[0] + room[2] - 1 - 1] in test and maze[i * MAZE_SIZE + room[0] + room[2] - 1 + 1] in test):
				if not (maze[i * MAZE_SIZE + room[0] + room[2] - 1 - 1] == -3 and maze[i * MAZE_SIZE + room[0] + room[2] - 1 + 1] == -1):
					maze[i * MAZE_SIZE + room[0] + room[2] - 1] = 1
		for j in range(room[0], room[0] + room[2]):
			if not (maze[(room[1] - 1) * MAZE_SIZE + j] in test and maze[(room[1] + 1) * MAZE_SIZE + j] in test):
				maze[(room[1]) * MAZE_SIZE + j] = 1
			if not (maze[(room[1] + room[3] - 1 - 1) * MAZE_SIZE + j] in test and maze[(room[1] + room[3] - 1 + 1) * MAZE_SIZE + j] in test):
				maze[(room[1] + room[3] - 1) * MAZE_SIZE + j] = 1
	for i in range(CENTER - 1, MAZE_SIZE - CENTER + 1):
		maze[i * MAZE_SIZE + CENTER - 1] = 1
		maze[i * MAZE_SIZE + MAZE_SIZE - CENTER] = 1
	for j in range(CENTER - 1, MAZE_SIZE - CENTER + 1):
		if maze[(CENTER - 1) * MAZE_SIZE + j] != 0:
			maze[(CENTER - 1) * MAZE_SIZE + j] = 1
		maze[(MAZE_SIZE - CENTER) * MAZE_SIZE + j] = 1
	
	return maze
	
func update_maze(maze : Array) -> Array:
	var m = []
	for x in range(MAZE_SIZE * 3):
		var tmp = []
		for y in range(MAZE_SIZE * 3):
			tmp.append(-1)
		m.append(tmp)
	var dir = [[-1, -1], [0, -1], [1, -1], [-1, 0], [0, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]
	for x in range(MAZE_SIZE):
		for y in range(MAZE_SIZE):
			for d in dir:
				var new_x = x * 3 + d[0]
				var new_y = y * 3 + d[1]
				if in_maze(new_x / 3, new_y / 3):
					m[new_y][new_x] = maze[y * MAZE_SIZE + x]

	return m
