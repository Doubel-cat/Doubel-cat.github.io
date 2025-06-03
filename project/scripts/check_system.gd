extends Node

# 单例实例
static var instance: Node

# 判定结果枚举
enum CheckResult {
	CRITICAL_FAILURE,  # 大失败
	FAILURE,          # 失败
	SUCCESS,          # 成功
	CRITICAL_SUCCESS  # 大成功
}

# 判定范围配置
class CheckRange:
	var min_value: int  # 最小值
	var max_value: int  # 最大值
	var critical_failure_threshold: int  # 大失败阈值
	var failure_threshold: int  # 失败阈值
	var success_threshold: int  # 成功阈值
	
	func _init(min_val: int, max_val: int):
		min_value = min_val
		max_value = max_val
		
		# 计算实际可能值的范围
		var possible_values = max_val - min_val + 1
		
		# 设置判定阈值（值越大越好）
		# 大失败：最低10%的数值
		critical_failure_threshold = min_val + int(possible_values * 0.1)
		# 失败：最低50%的数值
		failure_threshold = min_val + int(possible_values * 0.5)
		# 成功：最低90%的数值
		success_threshold = min_val + int(possible_values * 0.9)
	
	# 获取判定结果
	func get_check_result(value: int) -> int:
		if value <= critical_failure_threshold:
			return CheckResult.CRITICAL_FAILURE
		elif value <= failure_threshold:
			return CheckResult.FAILURE
		elif value <= success_threshold:
			return CheckResult.SUCCESS
		else:
			return CheckResult.CRITICAL_SUCCESS

# 判定系统配置
class CheckConfig:
	var check_range: CheckRange
	var critical_success_multiplier: float = 1.4  # 大成功伤害倍率
	var critical_failure_multiplier: float = 0.0  # 大失败伤害倍率（0表示未命中）
	var success_multiplier: float = 1.0  # 成功伤害倍率
	var failure_multiplier: float = 0.0  # 失败伤害倍率
	
	func _init(range_config: CheckRange,
			   crit_success_mult: float = 1.4,
			   crit_fail_mult: float = 0.0,
			   success_mult: float = 1.0,
			   fail_mult: float = 0.5):
		check_range = range_config
		critical_success_multiplier = crit_success_mult
		critical_failure_multiplier = crit_fail_mult
		success_multiplier = success_mult
		failure_multiplier = fail_mult

# 全局判定配置存储
var entity_check_configs: Dictionary = {}

# 注册实体的判定配置
func register_entity_check_config(entity_id: String, config: CheckConfig) -> void:
	entity_check_configs[entity_id] = config

# 更新实体的判定配置
func update_entity_check_config(entity_id: String, config: CheckConfig) -> void:
	if entity_check_configs.has(entity_id):
		entity_check_configs[entity_id] = config

# 获取实体的判定配置
func get_entity_check_config(entity_id: String) -> CheckConfig:
	if entity_check_configs.has(entity_id):
		return entity_check_configs[entity_id]
	return null

# 创建默认的玩家判定配置
func create_default_player_check_config() -> CheckConfig:
	# 获取玩家的骰子池
	var dice_pool = get_parent().get_node("dice_pool")
	
	# 获取当前场景中的玩家实体
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return CheckConfig.new(CheckRange.new(0, 0))
	
	# 使用玩家的entity_id获取骰子池
	var player_pool = dice_pool.get_entity_dice_pool(player.entity_id)
	
	# 计算最小和最大可能值
	var min_value = 0
	var max_value = 0

	# 遍历所有激活的骰子配置
	for dice_config in player_pool.get_active_dice_sets():
		# 获取每个面的实际值
		var min_face_value = dice_config.faces[0].value
		var max_face_value = dice_config.faces[0].value
		for face in dice_config.faces:
			min_face_value = min(min_face_value, face.value)
			max_face_value = max(max_face_value, face.value)
		
		# 累加最小和最大值
		min_value += min_face_value * dice_config.dice_count
		max_value += max_face_value * dice_config.dice_count
	
	# 创建判定范围配置
	var range_config = CheckRange.new(min_value, max_value)
	return CheckConfig.new(range_config)

# 创建默认的敌人判定配置
func create_default_enemy_check_config() -> CheckConfig:
	# 获取敌人的骰子池
	var dice_pool = get_parent().get_node("dice_pool")
	
	# 获取当前场景中的敌人实体
	var enemy = get_tree().get_first_node_in_group("foe")
	if not enemy:
		return CheckConfig.new(CheckRange.new(0, 0))
	
	# 使用敌人的entity_id获取骰子池
	var enemy_pool = dice_pool.get_entity_dice_pool(enemy.entity_id)
	
	# 计算最小和最大可能值
	var min_value = 0
	var max_value = 0
	
	# 遍历所有激活的骰子配置
	for dice_config in enemy_pool.get_active_dice_sets():
		# 获取每个面的实际值
		var min_face_value = dice_config.faces[0].value
		var max_face_value = dice_config.faces[0].value
		for face in dice_config.faces:
			min_face_value = min(min_face_value, face.value)
			max_face_value = max(max_face_value, face.value)
		
		# 累加最小和最大值
		min_value += min_face_value * dice_config.dice_count
		max_value += max_face_value * dice_config.dice_count
	
	# 创建判定范围配置
	var range_config = CheckRange.new(min_value, max_value)
	return CheckConfig.new(range_config)

# 应用判定结果到伤害
func apply_check_result_to_damage(base_damage: float, check_result: int, config: CheckConfig) -> float:
	match check_result:
		CheckResult.CRITICAL_SUCCESS:
			return base_damage * config.critical_success_multiplier
		CheckResult.SUCCESS:
			return base_damage * config.success_multiplier
		CheckResult.FAILURE:
			return base_damage * config.failure_multiplier
		CheckResult.CRITICAL_FAILURE:
			return base_damage * config.critical_failure_multiplier
	return base_damage  # 默认返回基础伤害

func _ready():
	instance = self 
