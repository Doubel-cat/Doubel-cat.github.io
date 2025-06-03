extends Control

@onready var health_bar = $HealthBar

var monster: Node2D

func _ready():
	# 设置血条颜色为红色
	health_bar.add_theme_color_override("fg_color", Color(1, 0, 0))

func setup(monster_node: Node2D):
	monster = monster_node
	update_health(monster.current_health, monster.max_health)
	
	# 连接怪物的信号
	monster.health_changed.connect(_on_health_changed)
	monster.tree_exiting.connect(_on_monster_died)
	
	# 获取敌人高度
	var height = 0.0
	
	# 如果没有texture，尝试获取CollisionShape2D
	if monster.has_node("CollisionShape2D"):
		var shape = monster.get_node("CollisionShape2D").shape
		if shape is RectangleShape2D:
			height = shape.size.y
		elif shape is CircleShape2D:
			height = shape.radius * 2
	
	# 如果都没有获取到，使用默认值
	if height == 0:
		height = 32.0
	
	# 设置血条位置在怪物上方
	position = Vector2(0, -height/2 - 20)  # 在怪物上方10像素

func update_health(current_health: float, max_health: float):
	health_bar.max_value = max_health
	health_bar.value = current_health

func _on_health_changed(current_health: float, max_health: float):
	update_health(current_health, max_health)

func _on_monster_died():
	queue_free() 
