extends KinematicBody2D

var navigation2d:Navigation2D setget set_navigation
var target:Position2D setget set_target
var path = []
export (int) var AlienSpeed

func set_navigation(value):	
	navigation2d = value	

func set_target(value):
	target = value	
	update_path()

func update_path():		
	path = navigation2d.get_simple_path(position, target.position)	
	if path.size() == 0: #can't find a route
		queue_free()
	
# Called when the node enters the scene tree for the first time.
func _ready():	
	set_process(true)		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	
		
	if path.size() >1:		
		var d = position.distance_to(path[0])
		
		if d > 2:						
			position = position.linear_interpolate(path[0], (AlienSpeed * delta)/d)						
			var j=0
			for k in range(path.size()-1):				
				draw_line(path[k], path[j+1], Color.black,5.0)	
				j =+ 1
		else:			
			path.remove(0)			
	else:
		queue_free()
	
	
