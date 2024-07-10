extends Node2D

var player_node = null
var entity_info = null
var entity_scene = null
var generation_freq_decay = null


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


func enemies_generation_logic(generation_frequncy, declay_frequncy,enemy_type):
	# Get all the scen
	player_node = get_node("../player_controllers/Player")
	entity_info = EnemyData.get_enemies_info(enemy_type)
	entity_scene = load("res://scenes/entities/" + enemy_type + "/" + enemy_type + ".tscn")
	generation_freq_decay = EnemyData.get_enemies_info(enemy_type)["generation_freq_decay"]
	
	# Generate one enemy once
	if (player_controllers.count % generation_frequncy == 0) && (EnemyData.get_enemies_info(enemy_type)["generaion_checker"] != player_controllers.count):
		player_controllers.spawn_enemies(player_node, entity_scene)
		EnemyData.get_enemies_info(enemy_type)["generaion_checker"] = player_controllers.count
	
	# Generation time decay checking
	if (player_controllers.count % declay_frequncy == 0) && (EnemyData.get_enemies_info(enemy_type)["generation_freq"] > EnemyData.get_enemies_info(enemy_type)["generation_freq_min"]):
		EnemyData.get_enemies_info(enemy_type)["generation_freq"] -= generation_freq_decay

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	enemies_generation_logic(EnemyData.get_enemies_info("small_enemies")["generation_freq"], (60*10), "small_enemies")
	enemies_generation_logic(EnemyData.get_enemies_info("big_enemies")["generation_freq"], (60*10), "big_enemies")
	if get_node("/root/player_controllers").rest_game:
		self.reset_game()
		get_node("/root/player_controllers").rest_game = false
	
	pass
	
