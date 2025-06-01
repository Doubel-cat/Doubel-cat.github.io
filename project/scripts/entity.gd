extends CharacterBody2D
class_name Entity

# 导入骰子系统和判定系统
const DiceConfig = preload("res://scripts/dice_system.gd").DiceConfig
const CheckConfig = preload("res://scripts/check_system.gd").CheckConfig
const Autoload = preload("res://scripts/autoload.gd")

# 获取系统实例
var dice_system
var check_system

# what to do when this entity dies
var death_scene = load("res://scenes/entities/loot/gold/gold.tscn")
var player_dead_scene = load("res://scenes/ui/player_dead/player_dead.tscn")
var death_config = {}

var direction: Vector2 = Vector2()

var max_health: int = 100
var current_health: int = 100
var health_regen: int = 1
var armor: int = 0

var max_mana: int = 100
var current_mana: int = 100
var mana_regen: int = 5

var max_speed: float = 100
var current_speed: int = player_controllers.player_initial_speed
var acceleration: int = 4

var agility: int = 1

var global_cooldown = 30
var is_busy: bool = false
var last_ability: int = 0

var is_player : bool = false
var is_alive: bool = true

# 骰子系统相关
var dice_config: DiceConfig
var check_config: CheckConfig

func _ready():
	add_to_group("entity")
	
	# 等待一帧确保自动加载节点已经准备好
	await get_tree().process_frame
	
	# 从静态方法获取系统实例
	dice_system = Autoload.get_dice_system()
	check_system = Autoload.get_check_system()
	
	# 确保系统已初始化
	if dice_system == null or check_system == null:
		push_error("Dice system or check system not found! Please ensure autoload.gd is properly registered in Project Settings -> AutoLoad.")
		return
	
	# 初始化骰子配置
	if is_player:
		dice_config = dice_system.get_default_player_dice()
		check_config = check_system.create_default_player_check_config()
	else:
		dice_config = dice_system.get_default_enemy_dice()
		check_config = check_system.create_default_enemy_check_config()


func get_state():
	return{
		"dirention": direction,
		"max_health": max_health,
		"current_health": current_health,
		"health_regen": health_regen,
		"armor": armor,
		"max_mana": max_mana,
		"current_mana": current_mana,
		"mana_regen": mana_regen,
		"max_speed": max_speed,
		"current_speed": current_speed,
		"acceleration": acceleration,
		"agility": agility,
		"global_cooldown": global_cooldown,
		"is_busy": is_busy,
		"last_ability": last_ability,
		"is_player": is_player,
	}


func get_enemies():
	var enemy_group = "friend"
	var enemies = get_tree().get_nodes_in_group(enemy_group)
	return enemies


func get_enemy_group():
	var enemy_group = "friend"
	if is_player:
		enemy_group = "foe"
	return enemy_group


func find_nearest_enemy():
	return get_enemies()[0]


func get_aim_position():
	if is_player:
		return get_global_mouse_position()
	else:
		return find_nearest_enemy().global_position


func regen_health():
	if (current_health < max_health):
		if ((health_regen + current_health) > max_health):
			current_health = max_health
		else:
			current_health += health_regen


func regen_mana():
	if (current_mana < max_mana):
		if ((mana_regen + current_mana) > max_mana):
			current_mana = max_mana
		else:
			current_mana += mana_regen


func modify_mana(amount):
	var new_mana = current_mana + amount
	if (new_mana < 0):
		current_mana = 0
	if (new_mana > max_mana):
		current_mana = max_mana
	else:
		current_mana += amount


func can_cast_ability(mana_cost):
	if (current_mana - mana_cost) >= 0:
		modify_mana(-mana_cost)
		return true
	else:
		print("no enough mana")
		return false


func apply_damage(amount, attacker = null):
	if attacker:
		# 使用骰子系统进行判定
		var roll_result = dice_system.roll_dice(attacker.dice_config, attacker.check_config)
		amount = roll_result.final_damage
		
		# 创建并显示伤害HUD
		var damage_hud = load("res://scenes/ui/damage_hud/damage_hud.tscn").instantiate()
		damage_hud.position = global_position + Vector2(0, -50)  # 在实体上方显示
		get_tree().root.add_child(damage_hud)
		damage_hud.setup(roll_result.individual_rolls, roll_result.check_result, amount, current_health - amount)
	
	if (armor > 0):
		amount = amount * ((100 - armor) * .01)
	if (current_health > amount):
		current_health -= amount
	else:
		current_health = 0
		if (!is_player):
			_generate_loot()
			self.queue_free()
		else:
			if !get_node("/root/player_controllers").camera_changed:
				var player_dead = player_dead_scene.instantiate()
				get_node("/root").add_child(player_dead)
				var dead_postion = get_node("../Player").global_position
				player_dead.global_position = dead_postion
				player_dead.update_dead_info()
				var camera = get_node("../Player/main_camera")
				var player_node = get_node("/root/player_controllers/Player")
				get_node("/root/player_controllers").change_camera(camera, player_node, player_dead)


func _generate_loot():
	var loot = death_scene.instantiate()
	loot.position = self.global_position
	loot.config = self.death_config
	loot.scale_factor = 3 - 2 * exp(-0.02 * (loot.config["gold"]["amount"] - 5))
	get_node("/root").add_child(loot)


func _physics_process(delta):
	last_ability += 1
	if (player_controllers.count % 60 == 0):
		regen_health()
		regen_mana() 

		
func load_ability(ability_name):
	var scene = load("res://scenes/ability/" + ability_name + "/" + ability_name + ".tscn")
	var sceneNode = scene.instantiate()
	add_child(sceneNode)
	return sceneNode
