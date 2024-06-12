extends Node2D

var count_check: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	player_controllers.spawn_current_player()
	pass # Replace with function body.


func reset_game():
	var enemies = get_tree().get_nodes_in_group("foe")
	for enemie in enemies:
		enemie.queue_free()
	
	var items = get_tree().get_nodes_in_group("pickable_items")
	for item in items:
		item.queue_free()
	
	var player = get_node("/root/player_controllers/Player")
	player.gold = 0
	player.crystal = 0
	player.current_health = 100
	player.current_mana = 0
	player.global_position = Vector2(0, 0)
	get_node("/root/player_controllers").camera_changed = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_node = get_node("../player_controllers/Player")
	if (player_controllers.count % (60 *3) == 0) && (count_check != player_controllers.count):
		player_controllers.spawn_enemies(player_node)
		count_check = player_controllers.count
	
	if get_node("/root/player_controllers").rest_game:
		self.reset_game()
		get_node("/root/player_controllers").rest_game = false
	
	pass
	
