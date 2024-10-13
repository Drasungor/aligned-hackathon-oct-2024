extends Node2D

class_name BugCharacter

const MovingDirectionScript = preload("res://scripts/moving_direction.gd")
const MovingDirection = MovingDirectionScript.MovingDirection

var map: TileMapLayer;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func move(direction: MovingDirection) -> void:
	var direction_vector: Vector2;
	var current_tile: Vector2 = map.local_to_map(position);

	match direction:
		MovingDirection.TopLeft:
			if int(current_tile.y) % 2 == 0:
				direction_vector = Vector2(-1, -1);
			else:
				direction_vector = Vector2(0, -1);
		MovingDirection.TopRight:
			if int(current_tile.y) % 2 == 0:
				direction_vector = Vector2(0, -1);
			else:
				direction_vector = Vector2(1, -1);
		MovingDirection.Left:
			direction_vector = Vector2(-1, 0);
		MovingDirection.Right:
			direction_vector = Vector2(1, 0);
		MovingDirection.BottomLeft:
			if int(current_tile.y) % 2 == 0:
				direction_vector = Vector2(-1, 1);
			else:
				direction_vector = Vector2(0, 1);
		MovingDirection.BottomRight:
			if int(current_tile.y) % 2 == 0:
				direction_vector = Vector2(0, 1);
			else:
				direction_vector = Vector2(1, 1);
	calculate_next_tile(direction_vector);


func calculate_next_tile(direction: Vector2) -> void:
	var current_tile: Vector2 = map.local_to_map(position);
	var next_tile: Vector2 = current_tile + direction;
	position = map.map_to_local(next_tile);


func set_map(_map: TileMapLayer) -> void:
	map = _map;
