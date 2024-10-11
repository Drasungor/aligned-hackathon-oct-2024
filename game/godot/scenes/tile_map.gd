extends TileMapLayer

var hover_tile := Vector2i(-1, -1) # Keep track of the last hovered tile
var last_hover_tile_type := Vector2i(-1, -1)

func _process(_delta: float) -> void:
	var tile_pos := local_to_map(get_local_mouse_position())

	if tile_pos != hover_tile:
		# Reset opacity of the previous tile (if needed)
		if hover_tile != Vector2i(-1, -1):
			_reset_tile(hover_tile)
		
		# Set new tile opacity
		_set_tile_alternative(tile_pos)
		hover_tile = tile_pos


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		# Convert local coordinates to tilemap grid position
		var tile_pos: Vector2i = local_to_map(get_local_mouse_position())

		if get_cell_tile_data(tile_pos) != null:
			print("Clicked TileMap: ", name)
			print("Tile coordinates: ", tile_pos)



func _set_tile_alternative(tile_pos: Vector2i) -> void:
	if get_cell_tile_data(tile_pos) != null:
		set_alternative_cell(tile_pos, Vector2i(5, 0))

func _reset_tile(tile_pos: Vector2i) -> void:
    # Reset the opacity back to normal
	set_alternative_cell(tile_pos, last_hover_tile_type)

func set_alternative_cell(tile_pos: Vector2i, atlas_coord: Vector2i) -> void:
    # Set modulate property for a specific cell/tile
	var tile := get_cell_tile_data(tile_pos)
	if tile:
		last_hover_tile_type = get_cell_atlas_coords(tile_pos)
		set_cell(tile_pos, 1, atlas_coord)
