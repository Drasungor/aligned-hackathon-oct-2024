extends AnimatedSprite2D

class_name BugSprite

const WALKING_UP: String = "walking_up";
const WALKING_SIDEWAYS: String = "walking_sideways";
const WALKING_DOWN: String = "walking_down";

func stop_animation() -> void:
	stop();
	frame = 0;


func play_top_left_animation() -> void:
	play(WALKING_UP);
	flip_h = false;


func play_top_right_animation() -> void:
	play(WALKING_UP);
	flip_h = true;


func play_left_animation() -> void:
	play(WALKING_SIDEWAYS);
	flip_h = false;


func play_right_animation() -> void:
	play(WALKING_SIDEWAYS);
	flip_h = true;


func play_bottom_left_animation() -> void:
	play(WALKING_DOWN);
	flip_h = false;


func play_bottom_right_animation() -> void:
	play(WALKING_DOWN);
	flip_h = true;
