extends AnimatedSprite2D

var is_reversed := false

func _ready() -> void:
	play()
	connect("animation_finished", self._on_animation_finished)

func _on_animation_finished() -> void:
	if is_reversed:
		play()
	else:
		play_backwards()
	is_reversed = not is_reversed
