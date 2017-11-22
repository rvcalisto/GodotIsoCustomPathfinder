extends Node2D

#drawing process that illustrates the path and cursor


#all the information
var curtgt = Vector2() #to be parsed
var grid = {} #dictionary to be parsed
var path = [] #pathfinder generated route


func _ready():
	
	#create a instruction label
	var label = Label.new()
	label.text = "Mouse Middle Btn: Block/Unblock Cell \nMouse R Btn: Generate Path \nMouse L Btn: Teleport"
	label.rect_position = Vector2(-5,-45)
	label.rect_scale = Vector2(.5,.5) #camera zoom is doubled, correct scale 
	get_viewport().call_deferred("add_child", label)
	
	set_physics_process(true)


func _physics_process(delta):
	update() #draw each physics frame


func _draw():
	
	var color = Color(.5,0,.5)
	var line = 3
	var p = Vector2(30,15) #cell size
	
	#drawn cursor cell selector if avaliable
	if grid.has(curtgt):
		
		#circle square
		draw_line(curtgt+Vector2(0,-p.y), curtgt+Vector2(-p.x,0), color, line)
		draw_line(curtgt+Vector2(0,-p.y), curtgt+Vector2(p.x,0), color, line)
		draw_line(curtgt+Vector2(0,p.y), curtgt+Vector2(-p.x,0), color, line)
		draw_line(curtgt+Vector2(0,p.y), curtgt+Vector2(p.x,0), color, line)

	#draw route
	if path.size() >= 1:
		
		for pos in path:
			draw_circle(pos, line, color)



