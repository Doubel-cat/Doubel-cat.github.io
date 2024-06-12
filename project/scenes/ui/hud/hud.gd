extends Control

var show_debug_text: bool = true
var debug_text = ""
@onready var debug_text_node = get_node("layer_1/debug/debug_text")


# Called when the node enters the scene tree for the first time.
func _ready():
	get_debug_text()
	pass # Replace with function body.


func get_debug_text():
	debug_text = get_parent().get_state()
	var gold = get_parent().gold
	var crystals = get_parent().crystal
	var format_string = "Health: %s / %s \nMana: %s / %s \nGold: %s\nCrystals: %s"
	var actual_string = format_string % [debug_text.current_health, debug_text.max_health, debug_text.current_mana, debug_text.max_mana, gold, crystals]
	debug_text_node.text = actual_string


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ((player_controllers.count % 10) == 0):
		get_debug_text()
	pass
