extends Control

var show_debug_text: bool = true
var debug_text = ""
@onready var debug_text_node = get_node("layer_1/debug/debug_text")

# 添加对血条和法力条的引用
@onready var health_bar = get_node("layer_1/health_bar")
@onready var mana_bar = get_node("layer_1/mana_bar")
@onready var num_info_node = get_node("layer_1/num_info")

# Called when the node enters the scene tree for the first time.
func _ready():
	update_ui()
	pass # Replace with function body.

func update_ui():
	# 获取父节点上的状态和相关数据
	var parent_node = get_parent()
	debug_text = parent_node.get_state()
	var gold = parent_node.gold
	var crystals = parent_node.crystal
	
	# 更新血条和法力条
	update_health_bar(debug_text.current_health, debug_text.max_health)
	update_mana_bar(debug_text.current_mana, debug_text.max_mana)
	
	# 格式化调试信息字符串
	var format_string = "[font_size=22][center]Health: %s / %s [/center][/font_size]\n[font_size=22][center]Mana: %s / %s[/center][/font_size]\n[font_size=22][left]Gold: %s[/left][/font_size]\n[font_size=22][left]Crystals: %s[/left][/font_size]"

	var actual_string = format_string % [debug_text.current_health, debug_text.max_health, debug_text.current_mana, debug_text.max_mana, gold, crystals]
	
	if show_debug_text:
		num_info_node.text = actual_string
	else:
		num_info_node.text = ""

func update_health_bar(current_health, max_health):
	# 更新血条
	health_bar.max_value = max_health
	health_bar.value = current_health

func update_mana_bar(current_mana, max_mana):
	# 更新法力条
	mana_bar.max_value = max_mana
	mana_bar.value = current_mana

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ((player_controllers.count % 10) == 0):
		update_ui()
	pass
