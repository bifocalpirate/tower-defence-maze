extends Node2D

const N = 1
const E = 2
const S = 4
const W = 8

var cell_walls = {Vector2(0,-1):N,
				  Vector2(1,0):E,
				  Vector2(0,1):S,
				  Vector2(-1,0):W}
				
var width = 30
var height = 10
var solution = []
var CAMERA_ZOOM = Vector2(2,2)
const FLAG_OFFSET = Vector2(32,35)
#fraction of wall to remove
var erase_fraction  = 0.2
var tileSet:TileSet = null
onready var Map = $Navigation2D/TileMap
onready var line = $Line2D
onready var startPosition = $StartPosition
onready var endPosition = $EndPosition
onready var navigation2D: Navigation2D = $Navigation2D
onready var path2D: Path2D = $Path2D
onready var pathFollow2D: PathFollow2D = $Path2D/PathFollow2D
onready var alien: KinematicBody2D = $SpaceInvader


func update_path():		
	solution = navigation2D.get_simple_path(startPosition.position, endPosition.position)			
	line.width = 0		
	for p in solution:		
		line.add_point(p)
		yield(get_tree(), "idle_frame")
	
	
func get_vector_for_direction(direction):
	if direction == N:
		return Vector2(0,-1)
	if direction == S:
		return Vector2(0,1)
	if direction == E:
		return Vector2(1,0)
	if direction == W:
		return Vector2(-1, 0)
	return null
	
func _ready():
	$Camera2D.zoom = CAMERA_ZOOM
	$Camera2D.position = Map.map_to_world(Vector2(width/2, height/2))			
	randomize()
	seed(randi())		
	make_maze()
	#erase_walls()	
	set_start_and_end()
	update_path()	
	
	alien.navigation2d = navigation2D
	alien.target = endPosition

func get_unvisited_for_cell(cell, unvisited):
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell+n)
	return list			
		
func make_maze():	
	var unvisited = []
	var stack = []
	#the map is first filled with solid blocks
	Map.clear()
	for x in range(width):
		for y in range(height):
			unvisited.append((Vector2(x,y)))
			Map.set_cellv(Vector2(x,y), N|E|S|W)				
	#pick a start cell
	var current = Vector2(0,0)
	unvisited.erase(current)
	#now we cut into these blocks
	while unvisited:
		var neighbours = get_unvisited_for_cell(current, unvisited)			
		if neighbours.size() > 0:
			var next = neighbours[randi() % neighbours.size()]
			stack.append(current)
			#remove walls from both cells
			var dir = next - current
			var current_walls = Map.get_cellv(current) - cell_walls[dir]
			var next_walls = Map.get_cellv(next) - cell_walls[-dir]			
			Map.set_cellv(current, current_walls)
			Map.update_dirty_quadrants()			
			Map.set_cellv(next, next_walls)						
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()	
	#yield(get_tree(), "idle_frame")

func set_start_and_end():	
	startPosition.position = Map.map_to_world(Vector2(0,0), true) + FLAG_OFFSET #+ FLAG_OFFSET
	alien.position = FLAG_OFFSET
	endPosition.position = Map.map_to_world(Vector2(randi() % width,randi() % height), true) + FLAG_OFFSET	

func is_reachable(cell_value, direction):	
	return cell_value & direction != direction

func get_reachable_by_cell(cell):
	var list = []		
	var target = cell + get_vector_for_direction(N)
	if is_reachable(Map.get_cellv(target), S) and is_reachable(Map.get_cellv(cell), N):		
		list.append(target)	
		
	target = cell + get_vector_for_direction(S)
	if is_reachable(Map.get_cellv(target), N) and is_reachable(Map.get_cellv(cell), S):		
		list.append(target)	
			
	target = cell + get_vector_for_direction(E)
	if is_reachable(Map.get_cellv(target), W) and is_reachable(Map.get_cellv(cell), E):		
		list.append(target)	
	
	target = cell + get_vector_for_direction(W)
	if is_reachable(Map.get_cellv(target), E) and is_reachable(Map.get_cellv(cell), W):		
		list.append(target)	
	return list
	
func solve_maze(start, end):	
	print("Start ", start)
	print("End ", end)			
			

func erase_walls():
	#randomly remove walls
	for i in range(int(width * height * erase_fraction)):
		var x = int(rand_range(1, width-1))
		var y = int(rand_range(1, height-1))
		var cell = Vector2(x,y)
		#pick ranom neight
		var neighbour = cell_walls.keys()[randi() % cell_walls.size()]
		if Map.get_cellv(cell) & cell_walls[neighbour]:
			var walls = Map.get_cellv(cell) - cell_walls[neighbour]
			var n_walls = Map.get_cellv(cell+neighbour) - cell_walls[-neighbour]
			Map.set_cellv(cell, walls)
			Map.set_cellv(cell+neighbour, n_walls)
		#yield(get_tree(), "idle_frame")
		

