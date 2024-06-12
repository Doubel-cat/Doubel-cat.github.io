extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func execute(s, target_position):
	var direct_to_target = target_position - s.global_position
	var norm_direction = -direct_to_target.normalized()
	player_controllers.force_back_direction = norm_direction
	player_controllers.force_back = true

