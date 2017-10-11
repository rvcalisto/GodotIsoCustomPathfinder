# ============================== Path Finder ==============================
extends Node2D

#This node generate routes between origin and target based on parsed
#grid, start_point and target_point.
#
#It is really powerfull as it can be changed to adapt to specific situations
#and favor certain routes above other possible ones if 'COST' is calculated
#differently, and so on.



#instances
var player

#path finding
var grid = Dictionary() #all avaliable positions as keys
var locked = Vector2Array() #vect2 array of final route
var queue_list = {} #Queue used in the A* search algorithm


func _ready():
	pass



#===================== Queue functions =====================

#is queue empty?
func Queue_empty():
	return queue_list.size() == 0

#assign position and respective priority to queue
func Queue_put(pos, priority):
	queue_list[pos] = priority

#gets highest priority (most efficient) position in queue
func Queue_get():
	
	#temporary array for pos cost
	var priority = Array()
	
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
	
	#updates grid for any possible changes
	grid = get_tree().get_nodes_in_group("nav")[0].grid
	
	#if start_pos == target_pos, return empty array
	if start_pos == target_pos:
		return Vector2Array()
	
	#resets path A* 
	locked = Vector2Array()
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
	while !Queue_empty():
		
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
				
				#catalogues its cost
				cost_so_far[pos] = new_cost
				
				#defines its priority
				var priority = new_cost + int(target_pos.distance_to(pos))
				
				#put into queue
				Queue_put(pos, priority)
				
				#defines parent position
				came_from[pos] = current
	
	#=========================== main loop end ===========================
	
	#if array doesn't have tgt_pos, failed, return empty array
	if !came_from.has(target_pos):
		#print("failed")
		return Vector2Array()
	
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




#get valid neighbor nodes from relative pos
func get_neighbors(pos):
	
	#array to hold all possible neighbours of current 'pos'
	var neighbors = Array()
	
	#minimum distance between pos
	var next = Vector2(30,15)
	
	#vector directions * next
	var up = Vector2(1,-1) * next
	var down = Vector2(-1,1) * next
	var right = Vector2(1,1) * next
	var left = Vector2(-1,-1) * next
	
	#if neighbour exists and is empty
	if grid.has(up+pos):
		if grid[up+pos][0] == "empty":
			neighbors.append(up+pos)
	if grid.has(down+pos):
		if grid[down+pos][0] == "empty":
			neighbors.append(down+pos)
	if grid.has(right+pos):
		if grid[right+pos][0] == "empty":
			neighbors.append(right+pos)
	if grid.has(left+pos):
		if grid[left+pos][0] == "empty":
			neighbors.append(left+pos)
	
	#print(neighbors)
	return neighbors



