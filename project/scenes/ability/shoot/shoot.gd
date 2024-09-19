extends Node

var controller = null
var mana_count = null
var f_node = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func execute(s, type):
	controller = s
	if type == "normal":
		mana_count = player_controllers.normal_shooting_mana_cost
		var f = load("res://scenes/ability/shoot/shoot_projectile.tscn")
		f_node = f.instantiate()
	elif type == "ability_1":
		mana_count = player_controllers.fireball_shooting_mana_cost
		var f = load("res://scenes/ability/shoot/fireball.tscn")
		f_node = f.instantiate()
	var is_able_to_cast = controller.can_cast_ability(mana_count)
	if !is_able_to_cast:
		return
	
	# instantiate the shooting project
	f_node.controller = controller
	f_node.position = controller.global_position
	f_node.add_collision_exception_with(controller)
	get_node("/root").add_child(f_node)
