extends CharacterBody2D
class_name Entity

# 导入骰子系统和判定系统
const DiceConfig = preload("res://scripts/dice_system.gd").DiceConfig
const CheckConfig = preload("res://scripts/check_system.gd").CheckConfig
const Autoload = preload("res://scripts/autoload.gd")

# 获取系统实例
var dice_system
var check_system
var dice_pool

# 实体ID，用于在骰子池中标识
var entity_id: String

# what to do when this entity dies
var death_scene = load("res://scenes/entities/loot/gold/gold.tscn")
var player_dead_scene = load("res://scenes/ui/player_dead/player_dead.tscn")
var death_config = {}

var direction: Vector2 = Vector2()

# 使用 @onready 延迟初始化这些变量
@onready var max_health = PlayerData.base_stats["max_health"]
@onready var current_health = PlayerData.base_stats["current_health"]
@onready var health_regen = PlayerData.base_stats["health_regen"]
@onready var armor = PlayerData.base_stats["armor"]

@onready var max_mana = PlayerData.base_stats["max_mana"]
@onready var current_mana = PlayerData.base_stats["current_mana"]
@onready var mana_regen = PlayerData.base_stats["mana_regen"]

@onready var max_speed = PlayerData.base_stats["max_speed"]
@onready var current_speed = PlayerData.base_stats["current_speed"]
@onready var acceleration = PlayerData.base_stats["acceleration"]
@onready var agility = PlayerData.base_stats["agility"]

@onready var global_cooldown = PlayerData.base_stats["global_cooldown"]

var is_busy: bool = false
var last_ability: int = 0

var is_player : bool = false
var is_alive: bool = true

# 判定配置
var check_config: CheckConfig

# HUD相关
var health_hud = null

signal health_changed(current_health: float, max_health: float)

func _ready():
	add_to_group("entity")
	
	# 生成唯一实体ID
	entity_id = str(get_instance_id())
	
	# 等待一帧确保自动加载节点已经准备好
	await get_tree().process_frame
	
	# 从静态方法获取系统实例
	dice_system = Autoload.get_dice_system()
	check_system = Autoload.get_check_system()
	dice_pool = Autoload.get_dice_pool()
	
	# 确保系统已初始化
	if dice_system == null or check_system == null or dice_pool == null:
		print("Systems not found! Please ensure autoload.gd is properly registered in Project Settings -> AutoLoad.")
		return
	
	# 初始化骰子池和判定配置
	if is_player:
		var player_pool = dice_pool.create_default_player_dice_pool()
		dice_pool.entity_dice_pools[entity_id] = player_pool
		check_config = check_system.create_default_player_check_config()
	else:
		var enemy_pool = dice_pool.create_default_enemy_dice_pool()
		dice_pool.entity_dice_pools[entity_id] = enemy_pool
		check_config = check_system.create_default_enemy_check_config()
		
		# 为非玩家实体创建血条HUD
		var hud_scene = load("res://scenes/ui/monster_hud/monster_hud.tscn")
		health_hud = hud_scene.instantiate()
		add_child(health_hud)
		health_hud.setup(self)


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
		# 获取攻击者的骰子池
		var attacker_pool = dice_pool.get_entity_dice_pool(attacker.entity_id)
		if attacker_pool and attacker_pool.has_active_dice():
			# 获取所有可用的骰子配置
			var active_dice = attacker_pool.get_active_dice_sets()
			
			# 使用数组操作一次性处理所有骰子配置
			var roll_results = active_dice.map(
				func(dice_config): 
					return dice_system.roll_dice(dice_config, attacker.check_config)
			)
			
			# 收集所有点数
			var all_rolls = roll_results.reduce(
				func(acc, result): return acc + result.individual_rolls, []
			)
			
			# 计算总点数
			var total_value = all_rolls.reduce(
				func(acc, value): return acc + value, 0
			)
			
			# 获取判定结果
			var check_result = attacker.check_config.check_range.get_check_result(total_value)
			
			# 计算基础伤害
			var base_damage = total_value
			
			# 应用判定结果到伤害
			amount = check_system.apply_check_result_to_damage(base_damage, check_result, attacker.check_config)
			
			# 是否记录详细骰子结果
			var should_log_rolls = true
			if should_log_rolls:
				print("Dice rolls: ", all_rolls)
				print("Total value: ", total_value)
				print("Check result: ", check_result)
				print("Final damage: ", amount)
				# 添加阈值信息
				print("CheckRange thresholds:")
				print("- Critical Failure: ", attacker.check_config.check_range.critical_failure_threshold)
				print("- Failure: ", attacker.check_config.check_range.failure_threshold)
				print("- Success: ", attacker.check_config.check_range.success_threshold)
				print("- Min value: ", attacker.check_config.check_range.min_value)
				print("- Max value: ", attacker.check_config.check_range.max_value)
				# 添加调试信息
				print("Debug info:")
				print("- Attacker entity_id: ", attacker.entity_id)
				print("- Attacker pool exists: ", attacker_pool != null)
				if attacker_pool:
					print("- Active dice sets: ", attacker_pool.get_active_dice_sets().size())
					for dice_config in attacker_pool.get_active_dice_sets():
						print("  - Dice config: ", dice_config.dice_count, "d", dice_config.faces.size())
						print("  - Face values: ", dice_config.faces.map(func(face): return face.value))
			
			# 创建并显示伤害HUD
			var damage_hud = load("res://scenes/ui/damage_hud/damage_hud.tscn").instantiate()
			damage_hud.position = global_position + Vector2(0, -50)  # 在实体上方显示
			get_tree().root.add_child(damage_hud)
			damage_hud.setup(all_rolls, check_result, amount, current_health - amount)
	
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
	
	# 发送血量变化信号
	health_changed.emit(current_health, max_health)


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
