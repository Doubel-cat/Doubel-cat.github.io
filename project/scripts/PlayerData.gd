extends Node

# 单例实例
static var instance = null

# 玩家基础属性
var base_stats = {
	"max_health": 100,
	"current_health": 100,
	"health_regen": 1,
	"armor": 0,
	
	"max_mana": 100,
	"current_mana": 100,
	"mana_regen": 5,
	
	"max_speed": 100,
	"current_speed": 100,
	"acceleration": 4,
	"agility": 1,
	
	"global_cooldown": 30
}

# 玩家特有属性
var player_specific = {
	"gold": 0,
	"crystal": 0,
	"auto_attack_interval": 0.5
}

# 战斗相关数值
var combat_stats = {
	"shooting_projection_speed": 200,
	"normal_shooting_damage": 20,
	"normal_shooting_mana_cost": 0,
	"fireball_shooting_damage": 60,
	"fireball_shooting_mana_cost": 40
}

# 获取基础属性
static func get_base_stat(stat_name: String):
	if instance == null:
		push_error("PlayerData instance not initialized!")
		return null
	if instance.base_stats.has(stat_name):
		return instance.base_stats[stat_name]
	return null

# 获取玩家特有属性
static func get_player_specific(stat_name: String):
	if instance == null:
		push_error("PlayerData instance not initialized!")
		return null
	if instance.player_specific.has(stat_name):
		return instance.player_specific[stat_name]
	return null

# 获取战斗属性
static func get_combat_stat(stat_name: String):
	if instance == null:
		push_error("PlayerData instance not initialized!")
		return null
	if instance.combat_stats.has(stat_name):
		return instance.combat_stats[stat_name]
	return null

# 设置基础属性
static func set_base_stat(stat_name: String, value):
	if instance == null:
		push_error("PlayerData instance not initialized!")
		return
	if instance.base_stats.has(stat_name):
		instance.base_stats[stat_name] = value

# 设置玩家特有属性
static func set_player_specific(stat_name: String, value):
	if instance == null:
		push_error("PlayerData instance not initialized!")
		return
	if instance.player_specific.has(stat_name):
		instance.player_specific[stat_name] = value

# 设置战斗属性
static func set_combat_stat(stat_name: String, value):
	if instance == null:
		push_error("PlayerData instance not initialized!")
		return
	if instance.combat_stats.has(stat_name):
		instance.combat_stats[stat_name] = value

# 获取所有基础属性
static func get_all_base_stats():
	if instance == null:
		push_error("PlayerData instance not initialized!")
		return {}
	return instance.base_stats

# 获取所有玩家特有属性
static func get_all_player_specific():
	if instance == null:
		push_error("PlayerData instance not initialized!")
		return {}
	return instance.player_specific

# 获取所有战斗属性
static func get_all_combat_stats():
	if instance == null:
		push_error("PlayerData instance not initialized!")
		return {}
	return instance.combat_stats

func _ready():
	instance = self 
