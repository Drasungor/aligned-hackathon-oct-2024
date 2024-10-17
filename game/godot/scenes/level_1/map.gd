extends TileMapLayer

const INITIAL_HOVER_TILE := Vector2i(-1, -1)

var hover_tile_pos := INITIAL_HOVER_TILE
var hover_tile_type: Vector2i
var hover_tile_type_bk := Vector2i(-1, -1)

func _process(_delta: float) -> void:
	var tile_pos := local_to_map(get_local_mouse_position())

	if tile_pos != hover_tile_pos:
		if hover_tile_pos != INITIAL_HOVER_TILE:
			_reset_tile_hover(hover_tile_pos)
		_set_tile_hover(tile_pos)
		hover_tile_pos = tile_pos

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var tile_pos: Vector2i = local_to_map(get_local_mouse_position())
		if get_cell_tile_data(tile_pos) != null:
			# TODO marcos: Implement tile click logic when Agus has interface implemented
			print("Clicked TileMap: ", name)
			print("Tile coordinates: ", tile_pos)

func _set_tile_hover(tile_pos: Vector2i) -> void:
	if get_cell_tile_data(tile_pos) != null:
		hover_tile_type = Vector2i(4, 0)
		_set_tile_type(tile_pos, 0, hover_tile_type)

func _reset_tile_hover(tile_pos: Vector2i) -> void:
	_set_tile_type(tile_pos, 0, hover_tile_type_bk)

func _set_tile_type(tile_pos: Vector2i, tile_set_id: int, atlas_coord: Vector2i) -> void:
	var tile := get_cell_tile_data(tile_pos)
	if tile:
		hover_tile_type_bk = get_cell_atlas_coords(tile_pos)
		set_cell(tile_pos, tile_set_id, atlas_coord)
