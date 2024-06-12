extends Area2D

var config: Dictionary = {}
var gold_value = 10
var collider = null


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("pickable_items")
	add_to_group("interactable")
	z_index = 98
	pass # Replace with function body.


func interact():
	var colliders = get_overlapping_bodies()
	for c in colliders:
		if c && (c.get_groups().size() && c.get_groups().has("player")):
			collider = c
			return true
		else:
			pass
	return false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if interact():
		self.queue_free()
		collider.gold += gold_value
	pass
