extends CharacterBody2D

@onready var aim_pos = null
@onready var self_pos = null

var damage = 20
var speed = 200
var controller = null


# Called when the node enters the scene tree for the first time.
func _ready():
	self_pos = self.global_position
	aim_pos = controller.get_aim_position()
	velocity = self_pos.direction_to(aim_pos) * speed
	z_index = 99
	
	await get_tree().create_timer(2).timeout
	_explode()
	pass # Replace with function body.


func _explode():
	self.queue_free()
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_and_slide()
	var collision = get_last_slide_collision()
	if (collision && collision.get_collider()):
		var collider = collision.get_collider()
		
		# if it is NPC, we try apply damage
		if collider is TileMap:
			_explode()
		elif collider.get_groups().size() && collider.get_groups().has("entity"):
			var enemy_group = controller.get_enemy_group()
			
			# only deal damage to enemies
			if collider.get_groups().size() && collider.get_groups().has(enemy_group):
				collider.apply_damage(damage)
				_explode()
		else:
			_explode()
	
	pass
