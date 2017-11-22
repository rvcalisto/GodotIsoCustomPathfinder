# ============================== Path Finder ==============================
extends Node

#This node generates a path between origin and target based on parsed
#grid, start_point and target_point.

#It is really powerful as it can be changed to adapt to specific situations
#and favor certain routes above other possible ones if 'COST' is calculated
#differently, and so on.


#path finding

#get grid reference
onready var grid = get_tree().get_nodes_in_group("nav")[0].grid 
var locked = [] #array of vect2 points, return final route
var queue_list = {} #Queue used in the A* search algorithm




#===================== Queue functions =====================

#assign position and respective priority to queue
func Queue_put(pos, priority):
	queue_list[pos] = priority

#gets highest priority (most efficient) position in queue
func Queue_get():
	
	#temporary array for pos cost
	var priority = []
	
	#for costs in queue
	for x in queue_list.values():
		priority.append(x)
	
	#sort in natural order and cut down to 1 item
	priority.sort(); priority.resize(1)
	
	#pops most efficient position
	for pos in queue_list:
		if queue_list[pos] == priority[0]:
			var requested_pos = pos
			queue_list.erase(requested_pos)
			return requested_pos

#===================== End Queue functions =====================




#A* search
func search(start_pos, target_pos):
	
	
	#if start_pos == target_pos, return empty array
	if start_pos == target_pos:
		return []
	
	#resets path A* 
	locked = []
	queue_list = {}
	
	#sets initial considerations
	Queue_put(start_pos, 0)
	var current
	var came_from = {} #dictionary for parent pos
	var cost_so_far = {} #dictionary with pos cost
	came_from[start_pos] = start_pos
	cost_so_far[start_pos] = 0

	#============================= main loop =============================  

	#while there are pos in queue list
	while !queue_list.empty():
		
		#current node is highest priority node in queue 
		current = Queue_get()
		
		#has current node found it's target?
		if current == target_pos:
			#print ('path found')
			break
		
		#for neighbours of current
		for pos in get_neighbors(current):
			
			#defines cost (cost acumulated + cost to neighbour cell)
			var new_cost = cost_so_far[current] + int(current.distance_to(pos))
			
			#if pos hasn't been calculated before, or its more effective than before
			if !cost_so_far.has(pos) or new_cost < cost_so_far[pos]:
				
				#catalogue its cost
				cost_so_far[pos] = new_cost
				
				#defines its priority
				var priority = new_cost + int(target_pos.distance_to(pos))
				
				#put into queue
				Queue_put(pos, priority)
				
				#define parent position
				came_from[pos] = current
	
	#=========================== main loop end ===========================
	
	#if array doesn't have tgt_pos, failed, return empty array
	if !came_from.has(target_pos):
		#print("failed")
		return []
	
	#================  retrace route and return best path ================ 
	
	#path array is target position
	locked = [current]
	
	#while current position isn't start position
	while current != start_pos:
		current = came_from[current] #retrace last cell
		locked.insert(0, current) #insert at the start of the array
	
	#removes start_pos from path
	locked.remove(0);
	
	return locked




#get "pos" valid neighbor nodes
func get_neighbors(pos):
	
	#array to hold all possible neighbours of current 'pos'
	var neighbors = []
	
	#minimum distance between cells
	var next = Vector2(30,15) 
	
	#vector directions
	var up = Vector2(1,-1); var down = Vector2(-1,1)
	var right = Vector2(1,1); var left = Vector2(-1,-1)
	
#	#diagonal vector directions (activate it if you want it)
#	var w = Vector2(0,2); var s = Vector2(0,-2)
#	var d = Vector2(2,0); var a = Vector2(-2,0)
	
	#array of possible neighbors, yet to be validated
	var check = [up,down,right,left] #only horizontal movement
#	var check = [up,down,right,left,w,a,s,d] #with diagonal movement
	
	#if neighbour exists in grid and is "empty", append
	for neighbor in check:
		
		#(direction * minimum_distance) + pos = relative_neighbour
		neighbor = neighbor * next + pos
		
		#skip if cell is blocked
		if grid.has(neighbor):
			
			#skip condition, off by default
			var skip_tile = false 
			
			
			#you may want this if you're using diagonal movement
#			#====== prevents movement between diagonally blocked tiles ======
#			#check how many non diagonal neighbours the origin tile has
#			var i = 0; for neigh in [up, down, left, right]:
#				var g = neigh * next + pos
#				if grid.has(g): i += 1 if grid[g][0] == "empty" else 0
#
#			if i < 4: #if origin tile is possibly a corner
#				for neigh in [w,a,s,d]: #check if movement is diagonal
#					if !skip_tile && neighbor == neigh * next + pos:
#						skip_tile = true #skip tile
#			#===============================================================
			
			
			if grid[neighbor][0] == "empty" && !skip_tile:
				neighbors.append(neighbor)
	
	#return array
	return neighbors



