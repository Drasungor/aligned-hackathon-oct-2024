extends Node2D

class_name BugCharacter

const BugDirection = preload("res://scripts/enums/bug_direction.gd").BugDirection

signal stop_bug_movement()

@onready var bug_sprite: BugSprite = $BugSprite;

var is_moving := false;
var next_position := Vector2(-1, -1);

const VELOCITY := 200;
const DISTANCE_TOLERANCE := 0.1;

func _physics_process(delta: float) -> void:
	if !is_moving:
		return;

	position = position.move_toward(next_position, delta * VELOCITY);
	if position.distance_to(next_position) < DISTANCE_TOLERANCE:
		position = next_position;
		bug_sprite.stop_animation();
		is_moving = false;
		stop_bug_movement.emit()


func move(direction: BugDirection) -> void:
	is_moving = true

	match direction:
		BugDirection.TopLeft:
			bug_sprite.play_top_left_animation()
		BugDirection.TopRight:
			bug_sprite.play_top_right_animation()
		BugDirection.Left:
			bug_sprite.play_left_animation()
		BugDirection.Right:
			bug_sprite.play_right_animation()
		BugDirection.BottomLeft:
			bug_sprite.play_bottom_left_animation()
		BugDirection.BottomRight:
			bug_sprite.play_bottom_right_animation()


func _on_bug_movement(bug_position: Vector2, bug_direction: BugDirection) -> void:
	# Initialization
	if next_position == Vector2(-1, -1):
		position = bug_position
		next_position = bug_position

	next_position = bug_position;
	if next_position != position:
		move(bug_direction)
