extends Node

var count: int = 0
var player_node = null
var hud_node = null
var is_player_spamed = false
var index = null
var force_back_speed: int = 400 # parameter when enemies crush on layer to push player move back
var force_back = false
var force_back_direction = null
var force_back_time = 8
var player_initial_speed = 100
var camera_changed = false
var rest_game = false
var map_x_min = -1575
var map_y_min = -775
var map_x_max = 1575
var map_y_max = 775
var enemy_generate_distance = 400


func get_current_player():
	if (player_node): 
		return player_node
	else:
		return null


func spawn_current_player():
	if (is_player_spamed):
		return
	
	# create player
	var player = load("res://scenes/entities/player/player.tscn")
	player_node = player.instantiate()
	player_node.is_player = true
	var pos_x = 0
	var pos_y = 0
	player_node.position = Vector2(pos_x, pos_y)
	
	# creat camera
	var camera = Camera2D.new()
	camera.name = "main_camera"
	camera.is_current()
	camera.zoom = Vector2(1.5, 1.5)
	
	
	# add both to scene
	add_child(player_node)
	player_node.add_child(camera)
	
	var hud = load("res://scenes/ui/hud/hud.tscn")
	hud_node = hud.instantiate()
	player_node.add_child(hud_node)
	
	is_player_spamed = true
	return player_node
	
	
func spawn_other_palyers():
	pass
	

func spawn_enemies(player_node, enemies_scene):
	randomize()
	var enemies = enemies_scene
	var player = player_node
	var enemies_node = enemies.instantiate()
	enemies_node.z_index = player.z_index
	
	var enemy_position = Vector2()
	var player_position = player.global_position
	while true:
		enemy_position.x = randf_range(map_x_min,map_x_max)
		enemy_position.y = randf_range(map_y_min,map_y_max)
		if enemy_position.distance_to(player_position) >= enemy_generate_distance:
			break
	
	enemies_node.global_position = enemy_position
	add_child(enemies_node)
	pass


func change_camera(camera_node, previous_attached_node, target_node):
	previous_attached_node.remove_child(camera_node)
	camera_node.name = "main_camera"
	target_node.add_child(camera_node)
	camera_node.is_current()
	self.camera_changed = true



func _physics_process(delta):
	count += 1
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
