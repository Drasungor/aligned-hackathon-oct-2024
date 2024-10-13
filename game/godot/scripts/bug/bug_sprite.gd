extends AnimatedSprite2D

class_name BugSprite

const WALKING_UP: String = "walking_up";
const WALKING_SIDEWAYS: String = "walking_sideways";
const WALKING_DOWN: String = "walking_down";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func stop_animation() -> void:
	stop();
	frame = 0;


# UP
func play_top_left_animation() -> void:
	play(WALKING_UP);


func play_top_right_animation() -> void:
	play(WALKING_UP);
	flip_h = true;


# SIDEWAYS
func play_left_animation() -> void:
	play(WALKING_SIDEWAYS);


func play_right_animation() -> void:
	play(WALKING_SIDEWAYS);
	flip_h = true;


# DOWN
func play_bottom_left_animation() -> void:
	play(WALKING_DOWN);


func play_bottom_right_animation() -> void:
	play(WALKING_DOWN);
	flip_h = true;
