extends Area2D

var config: Dictionary = {}
var collider = null
var scale_factor = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	scaling()
	add_to_group("pickable_items")
	add_to_group("interactable")
	z_index = 98
	pass
	

func interact():
	var colliders = get_overlapping_bodies()
	for c in colliders:
		if c && (c.get_groups().size() && c.get_groups().has("player")):
			collider = c
			return true
		else:
			pass
	return false


func scaling():
	var gold_texture = get_node("Gold")
	var gold_collision = get_node("CollisionShape2D")
	gold_texture.scale *= scale_factor
	gold_collision.scale *= scale_factor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if interact():
		self.queue_free()
		collider.gold += config["gold"]["amount"]
	pass
