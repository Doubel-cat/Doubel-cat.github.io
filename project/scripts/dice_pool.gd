extends Node

# 导入骰子系统
const DiceSystem = preload("res://scripts/dice_system.gd")
const DiceConfig = preload("res://scripts/dice_system.gd").DiceConfig

# 获取骰子系统实例
var dice_system

# 骰子池类
class DicePool:
	var dice_sets: Array[DiceConfig] = []  # 存储骰子配置
	var disabled_dice_indices: Array[int] = []  # 被禁用的骰子索引
	
	func _init():
		dice_sets = []
		disabled_dice_indices = []
	
	# 添加骰子配置
	func add_dice_set(dice_config: DiceConfig) -> void:
		dice_sets.append(dice_config)
	
	# 移除骰子配置
	func remove_dice_set(index: int) -> void:
		if index >= 0 and index < dice_sets.size():
			dice_sets.remove_at(index)
			# 更新禁用索引
			for i in range(disabled_dice_indices.size() - 1, -1, -1):
				if disabled_dice_indices[i] == index:
					disabled_dice_indices.remove_at(i)
				elif disabled_dice_indices[i] > index:
					disabled_dice_indices[i] -= 1
	
	# 禁用骰子
	func disable_dice(index: int) -> void:
		if index >= 0 and index < dice_sets.size() and not disabled_dice_indices.has(index):
			disabled_dice_indices.append(index)
	
	# 启用骰子
	func enable_dice(index: int) -> void:
		disabled_dice_indices.erase(index)
	
	# 获取所有可用的骰子配置
	func get_active_dice_sets() -> Array[DiceConfig]:
		var active_sets: Array[DiceConfig] = []
		for i in range(dice_sets.size()):
			if not disabled_dice_indices.has(i):
				active_sets.append(dice_sets[i])
		return active_sets
	
	# 获取骰子总数
	func get_total_dice_count() -> int:
		var total = 0
		for i in range(dice_sets.size()):
			if not disabled_dice_indices.has(i):
				total += dice_sets[i].dice_count
		return total
	
	# 检查是否有可用的骰子
	func has_active_dice() -> bool:
		return get_active_dice_sets().size() > 0

# 单例实例
static var instance: Node

# 存储不同实体的骰子池
var entity_dice_pools: Dictionary = {}

# 创建实体的骰子池
func create_entity_dice_pool(entity_id: String) -> DicePool:
	var pool = DicePool.new()
	entity_dice_pools[entity_id] = pool
	return pool

# 获取实体的骰子池
func get_entity_dice_pool(entity_id: String) -> DicePool:
	if not entity_dice_pools.has(entity_id):
		return create_entity_dice_pool(entity_id)
	return entity_dice_pools[entity_id]

# 移除实体的骰子池
func remove_entity_dice_pool(entity_id: String) -> void:
	entity_dice_pools.erase(entity_id)

# 创建默认的玩家骰子池
func create_default_player_dice_pool() -> DicePool:
	var pool = DicePool.new()
	# 添加3个固定D6
	pool.add_dice_set(dice_system.create_standard_dice_config(DiceSystem.DiceType.D6, 3))
	# 添加3个可分配D6
	pool.add_dice_set(dice_system.create_standard_dice_config(DiceSystem.DiceType.D6, 3))
	return pool

# 创建默认的敌人骰子池
func create_default_enemy_dice_pool() -> DicePool:
	var pool = DicePool.new()
	# 添加2个D6
	pool.add_dice_set(dice_system.create_standard_dice_config(DiceSystem.DiceType.D6, 2))
	return pool

func _ready():
	instance = self
	dice_system = get_node("/root/DiceSystem")
