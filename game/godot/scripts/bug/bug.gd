extends Node2D

class_name BugCharacter

const MovingDirectionScript = preload("res://scripts/moving_direction.gd")
const MovingDirection = MovingDirectionScript.MovingDirection

@onready var bug_sprite: BugSprite = $BugSprite;

var map: TileMapLayer;

var is_moving := false;
var next_position: Vector2;
var velocity := 200;

const DISTANCE_TOLERANCE := 0.1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if !is_moving:
		return;
	
	position = position.move_toward(next_position, delta * velocity);
	if position.distance_to(next_position) < DISTANCE_TOLERANCE:
		position = next_position;
		bug_sprite.stop_animation();
		is_moving = false;


func move(direction: MovingDirection) -> void:
	if is_moving:
		return;
	
	var direction_vector: Vector2;
	var current_tile: Vector2 = map.local_to_map(position);

	match direction:
		MovingDirection.TopLeft:
			if int(current_tile.y) % 2 == 0:
				direction_vector = Vector2(-1, -1);
			else:
				direction_vector = Vector2(0, -1);
			bug_sprite.play_top_left_animation();
		MovingDirection.TopRight:
			if int(current_tile.y) % 2 == 0:
				direction_vector = Vector2(0, -1);
			else:
				direction_vector = Vector2(1, -1);
			bug_sprite.play_bottom_right_animation();
		MovingDirection.Left:
			direction_vector = Vector2(-1, 0);
			bug_sprite.play_left_animation();
		MovingDirection.Right:
			direction_vector = Vector2(1, 0);
			bug_sprite.play_right_animation();
		MovingDirection.BottomLeft:
			if int(current_tile.y) % 2 == 0:
				direction_vector = Vector2(-1, 1);
			else:
				direction_vector = Vector2(0, 1);
			bug_sprite.play_bottom_left_animation();
		MovingDirection.BottomRight:
			if int(current_tile.y) % 2 == 0:
				direction_vector = Vector2(0, 1);
			else:
				direction_vector = Vector2(1, 1);
			bug_sprite.play_bottom_right_animation();
	calculate_next_tile(direction_vector);
	is_moving = true;


func calculate_next_tile(direction: Vector2) -> void:
	var current_tile: Vector2 = map.local_to_map(position);
	var next_tile: Vector2 = current_tile + direction;
	#position = map.map_to_local(next_tile);
	next_position = map.map_to_local(next_tile);


func set_map(_map: TileMapLayer) -> void:
	map = _map;
