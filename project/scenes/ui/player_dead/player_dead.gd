extends Control

@onready var loots_text_node = get_node("Loots")
@onready var title_text_node = get_node("Title")

# Called when the node enters the scene tree for the first time.
func _ready():
	var button = Button.new()
	button.name = "replay_butn"
	button.text = "Replay"
	button.pressed.connect(self._press_replay)
	add_child(button)
	button.position = Vector2(90, -10)
	pass # Replace with function body.


func _press_replay():
	print("reset game scene")
	get_node("/root/player_controllers").rest_game = true
	get_tree().change_scene_to_file("res://scenes/play_ground/play_ground.tscn")
	var camera = get_node("/root/PlayerDead/main_camera")
	var player_node = get_node("/root/player_controllers/Player")
	var player_dead = get_node("/root/PlayerDead")
	get_node("/root/player_controllers").change_camera(camera, player_dead, player_node)
	player_dead.queue_free()

func update_dead_info():
	var gold = get_node("../player_controllers/Player").gold
	var crystals = get_node("../player_controllers/Player").crystal
	title_text_node.text = "Sorry, you are dead."
	var loots_format_string = "Gold: %s\nCrystals: %s"
	loots_text_node.text = loots_format_string % [gold, crystals]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	pass
