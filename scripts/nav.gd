extends TileMap

#this tilemap serves as a navigation tilemap.
#all tiles are later appended to a dictionary where they can be referenced

#Storing tile data on a dictionary empowers the data that can be efficiently
#requested. EX: grid.has(position), grid[position], grid[postion][0], etc. 


var walkable = [0] #hold walkable cells index
var grid = {} #to be tile world locations
var curtgt = Vector2() #cursor pick

#references
var player #used as origin point 
var draw_node #node that draws route and cursor
var pathfinder #node that handles route generation


func _ready():
	
	#get used cells into an array (not real world pos)
	var tiles = get_used_cells()
	
	#get cell world pos, centralize it and append to grid array
	for pos in tiles:
		
		#get current cell index
		var idx = get_cell(pos.x,pos.y)
		
		#if idx is not in walkable cell idx dictionary
		if !walkable.has(idx):
			continue #skip to the next iteration
		
		#else
		var tgt = map_to_world(pos,false) #get world pos
		tgt = Vector2(tgt.x,tgt.y+15) #offset to centralize tile
		
		#grid is dictionary, make data array for each cell
		grid[tgt] = ["empty", null] #[empty/blocked, instance_refernce]
	
	
	#define references with groups
	player = get_tree().get_nodes_in_group('player')[0]
	draw_node = get_tree().get_nodes_in_group('draw')[0]
	pathfinder = get_tree().get_nodes_in_group('pathfinder')[0]
	
	#parse grid to be drawn
	draw_node.grid = grid 
	
	set_process(true) #cursor and player interactions
	set_process_input(true) #also cursor and player interactions



func _process(delta):
	
	#get map tile pos relative to mouse
	var tgt_cell = world_to_map( get_global_mouse_position() )
	
	
	#if tgt_cell is a valid cell (!= -1), sets it to curtgt
	if get_cell(tgt_cell.x, tgt_cell.y) != -1:
		#get world position and centralize offset tile 
		curtgt =  map_to_world(tgt_cell) + Vector2(0,15)
	else:
		curtgt = Vector2() #unable it
	
	#parse cursor target to be drawn
	draw_node.curtgt = curtgt




#features
func _input(event):

	#teleport player
	if event.is_action_pressed("mouse_act_left"):
		#if cursor cell is in the grid
		if grid.has(curtgt):
			#if cell is not blocked
			if grid[curtgt][0] == "empty":
				#teleport the pawn and cleans drawn path
				player.position = curtgt; draw_node.path = []

	#generate path
	if event.is_action_pressed("mouse_act_right"):
		#if cursor cell is in the grid
		if grid.has(curtgt):
			var path = pathfinder.search(player.position , curtgt)
			draw_node.path = path

	#blocks/unblock path
	if event.is_action_pressed("mouse_act_middle"):
		
		#if cursor cell is in the grid
		if grid.has(curtgt):
			
			#prevent user from blocking current player pos
			if player.position == curtgt:
				return
			
			#if cell is empty
			if grid[curtgt][0] == "empty":
				
				#create a block at the cell
				var spr = load("res://textures/X.png")
				var block = Sprite.new(); block.texture = spr
				block.offset = Vector2(0,1); block.position = curtgt
				add_child(block)
				
				#block the cell and store instance reference
				grid[curtgt][0] = "blocked"; grid[curtgt][1] = block
				
				#clean drawn path
				draw_node.path = []
			
			#if a block is blocking the way
			elif grid[curtgt][0] == "blocked":
				
				#delete block and empty the cell as well as the instance ref
				grid[curtgt][1].queue_free(); 
				grid[curtgt][0] = "empty"; grid[curtgt][1] = null
				
				#clean drawn path
				draw_node.path = []



