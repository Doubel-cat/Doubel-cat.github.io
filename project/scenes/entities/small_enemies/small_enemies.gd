extends Entity

var shoot = load_ability("shoot")
var dash = load_ability("dash")
var crush = load_ability("crush")


var aggro_range = 200
var min_firing_range = 100
var nearest_player = null
var crush_damage = 15
var crush_cool_down = 30
var collision_count: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	add_to_group("foe")
	self.global_cooldown = 120
	self.max_speed = 50
	self.current_speed = 50
	self.current_health = 40
	self.max_health = 40
	self.health_regen = 0
	self.death_config = {
		"gold":{
			"amount": 5
		}
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
							collider.apply_damage(crush_damage)
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
