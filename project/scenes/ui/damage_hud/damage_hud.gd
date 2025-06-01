extends Node2D

@onready var label = $Label

func _ready():
	# 设置标签的默认属性
	label.modulate = Color(0.8, 0.2, 0.8)  # 深紫色
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# 创建动画
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)  # 1秒内淡出
	tween.tween_callback(queue_free)  # 动画结束后删除节点

func setup(dice_rolls: Array, check_result: int, final_damage: float, remaining_health: int):
	# 构建显示文本
	var result_text = ""
	match check_result:
		0: result_text = "大失败"
		1: result_text = "失败"
		2: result_text = "成功"
		3: result_text = "大成功"
	
	var display_text = "骰子: %s\n%s\n伤害: %.0f\n剩余生命: %d" % [
		str(dice_rolls),
		result_text,
		final_damage,
		remaining_health
	]
	
	label.text = display_text 
