extends Entity

var shoot = load_ability("shoot")
var dash = load_ability("dash")
var crush = load_ability("crush")

var enemies_name = "big_enemies"
var entity_info = EnemyData.get_enemies_info(enemies_name)
var aggro_range = entity_info["aggro_range"]
var min_firing_range = entity_info["min_firing_range"]
var nearest_player = null
var crush_damage = entity_info["crush_damage"]
var crush_cool_down = entity_info["crush_cool_down"]
var collision_count: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	add_to_group("foe")
	self.global_cooldown = entity_info["global_cooldown"]
	self.max_speed = entity_info["max_speed"]
	self.current_speed = entity_info["current_speed"]
	self.current_health = entity_info["current_health"]
	self.max_health = entity_info["max_health"]
	self.health_regen = entity_info["health_regen"]
	self.armor = entity_info["armor"]
	self.acceleration = entity_info["acceleration"]
	self.agility = entity_info["agility"]
	self.death_config = {
		"gold":{
			"amount": entity_info["gould_amount"]
		},
	}
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (!nearest_player):
		nearest_player = player_controllers.get_current_player()
	else:
		if collision_count == get_slide_collision_count():
			act()
		else:
			var collision = get_last_slide_collision()
			if (collision && collision.get_collider()):
				var collider = collision.get_collider()
				if collider.get_groups().size() && collider.get_groups().has("entity"):
					var enemy_group = self.get_enemy_group()
					## only deal damage to enemies
					if collider.get_groups().size() && collider.get_groups().has(enemy_group):
						if last_ability > crush_cool_down:
							# 使用骰子系统进行伤害判定
							collider.apply_damage(crush_damage, self)
							crush.execute(collider, self.global_position)
							last_ability = 0
			collision_count = get_slide_collision_count()
	super._physics_process(delta)


func move_towards(p):
	dash.execute(self, p.global_position)
	pass


func act():
	move_towards(nearest_player)
	pass



#func act():
	#var dist = nearest_player.position.distance_to(self.position)
	#if (dist <= aggro_range) && (dist > min_firing_range):
		#move_towards(nearest_player)
	#elif (last_ability > global_cooldown) && (dist <= min_firing_range):
		#shoot.execute(self)
		#last_ability = 0
	#pass
