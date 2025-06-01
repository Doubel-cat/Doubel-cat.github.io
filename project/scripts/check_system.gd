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
	var critical_failure_threshold: float  # 大失败阈值（百分比）
	var failure_threshold: float  # 失败阈值（百分比）
	var success_threshold: float  # 成功阈值（百分比）
	var critical_success_threshold: float  # 大成功阈值（百分比）
	
	func _init(min_val: int, max_val: int, 
			   crit_fail: float = 0.1,  # 默认10%概率大失败
			   fail: float = 0.4,       # 默认40%概率失败
			   success: float = 0.4,    # 默认40%概率成功
			   crit_success: float = 0.1):  # 默认10%概率大成功
		min_value = min_val
		max_value = max_val
		critical_failure_threshold = crit_fail
		failure_threshold = fail
		success_threshold = success
		critical_success_threshold = crit_success
	
	# 验证阈值是否合法
	func validate_thresholds() -> bool:
		var total = critical_failure_threshold + failure_threshold + success_threshold + critical_success_threshold
		return abs(total - 1.0) < 0.001  # 允许0.1%的误差
	
	# 获取判定结果
	func get_check_result(value: int) -> int:
		var range_size = max_value - min_value
		var normalized_value = float(value - min_value) / range_size
		
		if normalized_value <= critical_failure_threshold:
			return CheckResult.CRITICAL_FAILURE
		elif normalized_value <= (critical_failure_threshold + failure_threshold):
			return CheckResult.FAILURE
		elif normalized_value <= (critical_failure_threshold + failure_threshold + success_threshold):
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
	var range_config = CheckRange.new(2, 12)  # 2d6的范围
	return CheckConfig.new(range_config)

# 创建默认的敌人判定配置
func create_default_enemy_check_config() -> CheckConfig:
	var range_config = CheckRange.new(1, 6)  # 1d6的范围
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
