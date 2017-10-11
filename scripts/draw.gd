extends Node2D

#serves as a drawing process that better ilustrates the behind the scenes
#all the information

var curtgt = Vector2() #to be parsed
var grid = {} #dictionary to be parsed
var path = Vector2Array() #pathfinder generated route


func _ready():
	
	#create a instruction label
	var label = Label.new()
	label.set_text("Mouse L Btn: Teleport \nMouse R Btn: Generate Path")
	label.set_pos(Vector2(30,10))
	label.set_scale(Vector2(.5,.5)) #camera zoom is doubled, correct scale 
	get_viewport().call_deferred("add_child", label)
	
	
	set_fixed_process(true)


func _fixed_process(delta):
	update() #drawn each frame


func _draw():
	
	var color = Color(.5,0,.5)
	var line = 3
	
	#drawn cursor cell selector if avaliable
	if grid.has(curtgt):
		
		#circle square
		draw_line(curtgt+Vector2(0,-15), curtgt+Vector2(-30,0), color, line)
		draw_line(curtgt+Vector2(0,-15), curtgt+Vector2(30,0), color, line)
		draw_line(curtgt+Vector2(0,15), curtgt+Vector2(-30,0), color, line)
		draw_line(curtgt+Vector2(0,15), curtgt+Vector2(30,0), color, line)

	#draw route
	if path.size() >= 1:
		
		for pos in path:
			draw_circle(pos, line, color)



