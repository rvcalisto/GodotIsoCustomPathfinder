extends TileMap

#this tilemap serve as an navigation tilemap.
#all tiles are later appended to a dictionary where they can be referenced
#
#Storing tile data on a dictionary empowers the data that can be efficiently
#stored. EX: grid.has(), grid[position], grid[postion][0], etc. 



var grid = {} #to be tile world locations
var curtgt = Vector2() #cursor pick

#references
var player
var draw_node 
var pathfinder


func _ready():
	
	#get used cells into an array (not real world pos)
	var tiles = get_used_cells()
	
	#get cell world pos, centralize it and append to grid array
	for pos in tiles:
		var tgt = map_to_world(pos,false) #get world pos
		tgt = Vector2(tgt.x,tgt.y+15) #offset to centralize tile
		
		#grid is matrix, first value is empty/blocked
		grid[tgt] = ["empty"] #used to skip pathfinder inclusions
	
	#defines references
	player = get_tree().get_nodes_in_group('player')[0]
	draw_node = get_tree().get_nodes_in_group('draw')[0]
	pathfinder = get_tree().get_nodes_in_group('pathfinder')[0]
	
	#parse grid to be drawn
	draw_node.grid = grid 
	
	set_process(true) #player interactions
	set_process_input(true) #also player interactions



func _process(delta):
	
	#get map tile pos relative to mouse
	var tgt_cell = world_to_map(get_global_mouse_pos())
	
	#if tgt_cell is a valid cell (!= -1), sets it to curtgt
	if get_cell(tgt_cell.x, tgt_cell.y) != -1:
		#get world position and centralize offset tile 
		curtgt =  map_to_world(tgt_cell)+Vector2(0,15) 
	else:
		curtgt = Vector2() #unable it
	
	draw_node.curtgt = curtgt #parse cursor target to be drawn





func _input(event):
	
	
	if event.is_action_pressed("mouse_act_left"):
		#if cursor cell is valid in the grid
		if grid.has(curtgt):
			
			#teleport the pawn
			player.set_pos(curtgt)


	if event.is_action_pressed("mouse_act_right"):
		
		if grid.has(curtgt):
			var path = pathfinder.search(player.get_pos(), curtgt)
			draw_node.path = path

