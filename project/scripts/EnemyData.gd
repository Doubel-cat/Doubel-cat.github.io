extends Node

var enemies = {
	"small_enemies": 
		{"aggro_range": 200,
		 "min_firing_range": 100,
		 "crush_damage": 15,
		 "global_cooldown": 120,
		 "max_speed": 50,
		 "current_speed": 50,
		 "current_health": 40,
		 "max_health": 40,
		 "health_regen": 0,
		 "gould_amount":5,
		 "generation_freq": 100,
		 "generation_freq_min": 30,
		 "generation_freq_decay": 10,
		 "generaion_checker": 0
		},
	
}

func get_enemies_info(enemies_name):
	if enemies.has(enemies_name):
		return enemies[enemies_name]
	else:
		return {}

func set_enemies_info(enemies_name, info):
	enemies[enemies_name] = info










# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
