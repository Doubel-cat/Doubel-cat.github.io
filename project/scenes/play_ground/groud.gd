extends TileMap

@export var bush_count: int = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var map_size = get_used_rect()
	var tile1_positions = []
	tile1_positions = self.get_used_cells(0)
	
	for i in range(bush_count):
		var index = randi() % tile1_positions.size()
		var tile_position = tile1_positions[index]
		tile1_positions.remove_at(index)
		var tile_map_cell_atlas_coords = self.get_cell_atlas_coords(0, tile_position) 
		var tile_map_cell_alternative = self.get_cell_alternative_tile(0, tile_position)
		self.set_cell(0, tile_position, 4, tile_map_cell_atlas_coords, tile_map_cell_alternative)
	
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
