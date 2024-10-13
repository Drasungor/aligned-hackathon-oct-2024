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
	match direction:
		MovingDirection.TopLeft:
			print("topleft");
		MovingDirection.TopRight:
			print("topright");
		MovingDirection.Left:
			direction_vector = Vector2(-1, 0);
			calculate_next_tile(direction_vector)
			print("left");
		MovingDirection.Right:
			direction_vector = Vector2(1, 0);
			calculate_next_tile(direction_vector)
			print("right");
		MovingDirection.BottomLeft:
			print("bottomleft");
		MovingDirection.BottomRight:
			print("bottomright");


func calculate_next_tile(direction: Vector2) -> void:
	var current_tile: Vector2 = map.local_to_map(position);
	print("ct ",current_tile)
	var next_tile: Vector2 = current_tile + direction;
	print("nt ",next_tile)
	position = map.map_to_local(next_tile);
	return;

func set_map(_map: TileMapLayer) -> void:
	map = _map;
