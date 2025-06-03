extends Node

# 使用静态变量存储系统实例
static var dice_system_instance
static var check_system_instance
static var dice_pool_instance

func _init():
	# 确保这个节点被命名为 "autoload"
	name = "autoload"

func _ready():
	# 创建并添加骰子系统
	dice_system_instance = load("res://scripts/dice_system.gd").new()
	dice_system_instance.name = "dice_system"
	add_child(dice_system_instance)
	
	# 创建并添加判定系统
	check_system_instance = load("res://scripts/check_system.gd").new()
	check_system_instance.name = "check_system"
	add_child(check_system_instance)
	
	# 创建并添加骰子池系统
	dice_pool_instance = load("res://scripts/dice_pool.gd").new()
	dice_pool_instance.name = "dice_pool"
	add_child(dice_pool_instance)
	
	# 确保系统被正确初始化
	if dice_system_instance == null or check_system_instance == null or dice_pool_instance == null:
		print("Failed to initialize systems!")
		
	# 等待一帧确保系统完全初始化
	await get_tree().process_frame

# 提供静态访问方法
static func get_dice_system():
	return dice_system_instance

static func get_check_system():
	return check_system_instance

static func get_dice_pool():
	return dice_pool_instance
