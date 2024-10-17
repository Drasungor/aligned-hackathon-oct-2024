extends Node2D

class_name BugCharacter

const MovingDirectionScript = preload("res://scripts/moving_direction.gd")
const MovingDirection = MovingDirectionScript.MovingDirection

@onready var bug_sprite: BugSprite = $BugSprite;

var is_moving := false;
var next_position: Vector2

const VELOCITY := 200;
const DISTANCE_TOLERANCE := 0.1;

func _ready() -> void:
	position = Vector2(1344, 437);
	next_position = position;

func _physics_process(delta: float) -> void:
	if !is_moving:
		return;

	position = position.move_toward(next_position, delta * VELOCITY);
	if position.distance_to(next_position) < DISTANCE_TOLERANCE:
		position = next_position;
		bug_sprite.stop_animation();
		is_moving = false;

# TODO marcos: check this function
func move(direction: MovingDirection) -> void:
	if is_moving:
		return;
	
	var direction_vector: Vector2;
	var current_tile := GameContainer.get_bug_position();

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
	is_moving = true;

func _on_bug_position(bug_position: Vector2) -> void:
	next_position = bug_position;
	if next_position != position:
		is_moving = true
