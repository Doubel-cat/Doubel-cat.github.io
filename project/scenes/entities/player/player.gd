extends Entity

var gold: int = 0
var crystal: int = 0
var force_back_count: int = 0
var auto_attack_timer: float = 0.0
var auto_attack_interval: float = 0.5  # 0.5秒的攻击间隔


func _ready():
	super._ready()
	add_to_group("player")
	add_to_group("friend")
	z_index = 100
	pass


# abilities
var move = load_ability("move")
var shoot = load_ability("shoot")
#var inventory = load_ability("inventory")


# state
func _get_collisions():
	var c = get_last_slide_collision()
	if (c && c.get_collider()):
		return c.get_collider()
	else:
		return null


func interact():
	var c = _get_collisions()
	if c && (c.get_groups().size() && c.get_groups().has("interactable")):
		c.interact()


func _read_input():
	look_at(get_global_mouse_position())
	var movement = []
	
	if Input.is_action_pressed("move_up"):
		movement.append("up")
	if Input.is_action_pressed("move_down"):
		movement.append("down")
	if Input.is_action_pressed("move_left"):
		movement.append("left")
	if Input.is_action_pressed("move_right"):
		movement.append("right")
	move.execute(self, movement)
	
	# 自动攻击逻辑
	auto_attack_timer += get_physics_process_delta_time()  # 使用物理帧的delta time
	if auto_attack_timer >= auto_attack_interval:
		shoot.execute(self, "normal")
		auto_attack_timer = 0.0
	
	if last_ability > global_cooldown:
		if Input.is_action_pressed("interact"):
			interact()
			last_ability = 0
		if Input.is_action_pressed("ability_1"):
			shoot.execute(self, "ability_1")
			last_ability = 0


func _physics_process(delta):
	super._physics_process(delta)
	if player_controllers.force_back:
		if force_back_count == player_controllers.force_back_time:
			player_controllers.force_back = false
			force_back_count = 0
			self.current_speed = player_controllers.player_initial_speed
		else:
			force_back_count +=1
			self.velocity = player_controllers.force_back_direction
			self.current_speed = player_controllers.force_back_speed
			self.velocity = self.velocity.normalized() * self.current_speed
			self.move_and_slide()
	else:
		_read_input()
	
	
	
	
