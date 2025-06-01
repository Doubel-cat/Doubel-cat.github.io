extends Node

# 单例实例
static var instance: Node

# 导入check_system以使用其类型
const CheckConfig = preload("res://scripts/check_system.gd").CheckConfig
const CheckResult = preload("res://scripts/check_system.gd").CheckResult

# 骰子类型枚举
enum DiceType {
	D6 = 6,
	D8 = 8,
	D10 = 10,
	D12 = 12,
	D20 = 20,
	D22 = 22  # 添加22面骰子
}

# 骰子面配置结构
class DiceFace:
	var value: int  # 面的数值
	var weight: float = 1.0  # 权重，用于调整概率
	
	func _init(v: int, w: float = 1.0):
		value = v
		weight = w

# 骰子配置结构
class DiceConfig:
	var faces: Array[DiceFace]  # 骰子面的配置
	var dice_count: int  # 骰子数量
	var multiplier: float = 1.0  # 伤害倍率
	
	func _init(faces_array: Array, count: int, mult: float = 1.0):
		faces = faces_array
		dice_count = count
		multiplier = mult
	
	# 获取最小可能值
	func get_min_value() -> int:
		var min_value = faces[0].value
		for face in faces:
			min_value = min(min_value, face.value)
		return min_value * dice_count
	
	# 获取最大可能值
	func get_max_value() -> int:
		var max_value = faces[0].value
		for face in faces:
			max_value = max(max_value, face.value)
		return max_value * dice_count
	
	# 获取所有可能值的总和
	func get_total_possible_values() -> int:
		var total = 0
		for face in faces:
			total += face.value
		return total * dice_count
	
	# 获取所有可能值的数量
	func get_possible_values_count() -> int:
		return faces.size() * dice_count

# 骰子结果结构
class DiceResult:
	var check_result: int  # 判定结果
	var total_value: int   # 总点数
	var individual_rolls: Array  # 每个骰子的点数
	var final_damage: float  # 最终伤害
	
	func _init():
		individual_rolls = []
		total_value = 0
		final_damage = 0.0

# 单次骰子投掷
func roll_dice(config: DiceConfig, check_config: CheckConfig) -> DiceResult:
	var result = DiceResult.new()
	
	# 使用数组操作一次性生成所有骰子的结果
	result.individual_rolls = Array(range(config.dice_count)).map(
		func(_x): 
			# 根据权重选择面
			var total_weight = 0.0
			for face in config.faces:
				total_weight += face.weight
			
			var roll = randf() * total_weight
			var current_weight = 0.0
			
			for face in config.faces:
				current_weight += face.weight
				if roll <= current_weight:
					return face.value
			
			return config.faces[0].value  # 默认返回第一个面的值
	)
	
	result.total_value = result.individual_rolls.reduce(
		func(a, b): return a + b, 0
	)
	
	# 使用判定系统获取判定结果
	result.check_result = check_config.check_range.get_check_result(result.total_value)
	
	# 计算基础伤害
	var base_damage = result.total_value * config.multiplier
	
	# 获取判定系统实例并应用判定结果到伤害
	var check_system = get_parent().get_node("check_system")
	result.final_damage = check_system.apply_check_result_to_damage(base_damage, result.check_result, check_config)

	
	return result

# 并发处理多个目标的骰子判定
func process_multiple_targets(attacker_config: DiceConfig, check_config: CheckConfig, targets: Array) -> Array:
	var results = []
	var roll_result = roll_dice(attacker_config, check_config)
	
	# 对每个目标应用相同的骰子结果
	for target in targets:
		var target_result = DiceResult.new()
		target_result.check_result = roll_result.check_result
		target_result.total_value = roll_result.total_value
		target_result.individual_rolls = roll_result.individual_rolls.duplicate()
		target_result.final_damage = roll_result.final_damage
		results.append(target_result)
	
	return results

# 创建标准骰子面配置
func create_standard_dice_faces(sides: int) -> Array[DiceFace]:
	var faces: Array[DiceFace] = []
	for i in range(1, sides + 1):
		faces.append(DiceFace.new(i))
	return faces

# 获取默认的玩家骰子配置
func get_default_player_dice() -> DiceConfig:
	return DiceConfig.new(create_standard_dice_faces(DiceType.D6), 2)

# 获取默认的敌人骰子配置
func get_default_enemy_dice() -> DiceConfig:
	return DiceConfig.new(create_standard_dice_faces(DiceType.D6), 1)

func _ready():
	instance = self 
