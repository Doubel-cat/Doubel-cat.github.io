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
		0: result_text = "Big_loss"
		1: result_text = "loss"
		2: result_text = "success"
		3: result_text = "Big_success"
	
	var display_text = "Dice: %s\n%s\nDamage: %.0f\nLife: %d" % [
		str(dice_rolls),
		result_text,
		final_damage,
		remaining_health
	]
	
	label.text = display_text 
