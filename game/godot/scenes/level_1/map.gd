extends TileMapLayer

signal bug_position(position: Vector2)

const INITIAL_HOVER_TILE := Vector2i(-1, -1)
const HOVER_TILE_TYPE := Vector2i(4, 0)
const BLOCKED_TILE_TYPE := Vector2i(5, 0)

var hover_tile_pos := INITIAL_HOVER_TILE
var hover_tile_type: Vector2i
var hover_tile_type_bk := Vector2i(-1, -1)

func _ready() -> void:
	bug_position.emit(_tile_position_to_global(GameContainer.get_bug_position()))
	var blocked_tiles := GameContainer.get_blocked_tiles()

	for x in range(get_used_rect().size.x):
		for y in range(get_used_rect().size.y):
			var tile_pos := Vector2i(x, y)
			if blocked_tiles.has(tile_pos):
				_set_tile_blocked(tile_pos)

func _physics_process(_delta: float) -> void:
	var tile_pos := local_to_map(get_local_mouse_position())

	if tile_pos != hover_tile_pos:
		if hover_tile_pos != INITIAL_HOVER_TILE:
			_reset_tile_hover(hover_tile_pos)
		_set_tile_hover(tile_pos)
		hover_tile_pos = tile_pos

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var tile_pos := local_to_map(get_local_mouse_position())
		var cell := get_cell_tile_data(tile_pos)
		print(tile_pos)
		if cell && (get_cell_atlas_coords(tile_pos) != BLOCKED_TILE_TYPE):
			print(get_cell_atlas_coords(tile_pos))
			bug_position.emit(_tile_position_to_global(GameContainer.change_state(tile_pos))) # TODO handle game ending as possible response

func _set_tile_hover(tile_pos: Vector2i) -> void:
	if get_cell_tile_data(tile_pos) != null:
		_set_tile_type(tile_pos, 0, HOVER_TILE_TYPE)

func _reset_tile_hover(tile_pos: Vector2i) -> void:
	_set_tile_type(tile_pos, 0, hover_tile_type_bk)

func _set_tile_blocked(tile_pos: Vector2i) -> void:
	_set_tile_type(tile_pos, 0, BLOCKED_TILE_TYPE)

func _set_tile_type(tile_pos: Vector2i, tile_set_id: int, atlas_coord: Vector2i) -> void:
	var tile := get_cell_tile_data(tile_pos)
	if tile:
		hover_tile_type_bk = get_cell_atlas_coords(tile_pos)
		set_cell(tile_pos, tile_set_id, atlas_coord)

func _tile_position_to_global(tile_pos: Vector2i) -> Vector2:
	return to_global(map_to_local(tile_pos))
