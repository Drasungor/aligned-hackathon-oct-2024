# Scene that manages user interactions with the map and
# keeps it updated. It also accesses the Rust code.

extends TileMapLayer

const BugDirection = preload("res://scripts/enums/bug_direction.gd").BugDirection

signal bug_movement(position: Vector2, direction: BugDirection)
signal game_ended(player_won: bool);

var hover_tile_pos := NO_HOVERED_TILE
var hover_tile_type: Vector2i
var hover_tile_type_bk := Vector2i(-1, -1)
var is_bug_moving := false

var bug_tile: Vector2i

const NO_HOVERED_TILE := Vector2i(-1, -1)
const HOVER_TILE_TYPE := Vector2i(4, 0)
const BLOCKED_TILE_TYPE := Vector2i(5, 0)

func _ready() -> void:
	var initial_bug_tile := GameContainer.get_bug_position()
	bug_movement.emit(
		_tile_position_to_global(initial_bug_tile),
		BugDirection.BottomRight
	)
	bug_tile = initial_bug_tile

	var blocked_tiles := GameContainer.get_blocked_tiles()
	for x in range(get_used_rect().size.x):
		for y in range(get_used_rect().size.y):
			var tile_pos := Vector2i(x, y)
			if blocked_tiles.has(tile_pos):
				_set_tile_blocked(tile_pos)


func _physics_process(_delta: float) -> void:
	var tile_pos := local_to_map(get_local_mouse_position())
	var tile_data := get_cell_tile_data(tile_pos)

	if tile_data and tile_pos != hover_tile_pos and get_cell_atlas_coords(tile_pos) != BLOCKED_TILE_TYPE:
		if hover_tile_pos != NO_HOVERED_TILE:
			_reset_tile_hover(hover_tile_pos)
		_set_tile_hover(tile_pos)
		hover_tile_pos = tile_pos
	elif !tile_data or get_cell_atlas_coords(tile_pos) == BLOCKED_TILE_TYPE:
		_reset_tile_hover(hover_tile_pos)
		hover_tile_pos = NO_HOVERED_TILE

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var tile_pos := local_to_map(get_local_mouse_position())
		
		if is_bug_moving:
			return
			
		var cell := get_cell_tile_data(tile_pos)
		var is_bug_position:= GameContainer.get_bug_position() == tile_pos
		if cell && (get_cell_atlas_coords(tile_pos) != BLOCKED_TILE_TYPE) && !is_bug_position:
			is_bug_moving = true
			print("Blocked tile:")
			print(tile_pos)
			var state_change_variant: Variant = GameContainer.change_state(tile_pos)
			if typeof(state_change_variant) == Variant.Type.TYPE_BOOL:
				print("game ended")
				game_ended.emit(state_change_variant);
			elif typeof(state_change_variant) == Variant.Type.TYPE_VECTOR2I:
				print("game updated")
				#var new_bug_tile: Vector2i = state_change_variant.get_vector2i()
				var new_bug_tile: Vector2i = state_change_variant
				print(new_bug_tile)
				bug_movement.emit(
					_tile_position_to_global(new_bug_tile),
					_get_bug_direction(new_bug_tile)
				)
				bug_tile = new_bug_tile
			else:
				print("unexpected response type")
			_set_tile_blocked(tile_pos)
			hover_tile_pos = NO_HOVERED_TILE


func _set_tile_hover(tile_pos: Vector2i) -> void:
	if get_cell_tile_data(tile_pos) != null and hover_tile_pos != tile_pos:
		_set_tile_type(tile_pos, 0, HOVER_TILE_TYPE)


func _reset_tile_hover(tile_pos: Vector2i) -> void:
	if hover_tile_pos == NO_HOVERED_TILE:
		return
	_set_tile_type(tile_pos, 0, hover_tile_type_bk)


func _on_directory_selected(path: String) -> void:
	var absolute_path: String = ProjectSettings.globalize_path(path)
	GameContainer.serialize_blocked_tiles(absolute_path)


func _set_tile_blocked(tile_pos: Vector2i) -> void:
	_set_tile_type(tile_pos, 0, BLOCKED_TILE_TYPE)


func _set_tile_type(tile_pos: Vector2i, tile_set_id: int, atlas_coord: Vector2i) -> void:
	var tile := get_cell_tile_data(tile_pos)
	if tile:
		hover_tile_type_bk = get_cell_atlas_coords(tile_pos)
		set_cell(tile_pos, tile_set_id, atlas_coord)


func _tile_position_to_global(tile_pos: Vector2i) -> Vector2:
	return to_global(map_to_local(tile_pos))


func _on_stop_bug_movement() -> void:
	is_bug_moving = false


func _get_bug_direction(destination_bug_tile: Vector2i) -> BugDirection:
	if bug_tile.y % 2 != 0:
		match destination_bug_tile - bug_tile:
			Vector2i(0, 1):
				return BugDirection.BottomLeft
			Vector2i(1, 1):
				return BugDirection.BottomRight
			Vector2i(0, -1):
				return BugDirection.TopLeft
			Vector2i(1, -1):
				return BugDirection.TopRight
			Vector2i(1, 0):
				return BugDirection.Right
			Vector2i(-1, 0):
				return BugDirection.Left
			_:
				return BugDirection.BottomRight # Avoid breaking the game
	else:
		match destination_bug_tile - bug_tile:
			Vector2i(0, 1):
				return BugDirection.BottomRight
			Vector2i(0, -1):
				return BugDirection.TopRight
			Vector2i(-1, 1):
				return BugDirection.BottomLeft
			Vector2i(-1, -1):
				return BugDirection.TopLeft
			Vector2i(-1, 0):
				return BugDirection.Left
			Vector2i(1, 0):
				return BugDirection.Right
			_:
				return BugDirection.BottomRight # Avoid breaking the game
