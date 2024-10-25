extends Node2D

@onready var menu_scene := preload("res://scenes/menu/menu.tscn");
@onready var level_scene := preload("res://scenes/level/level.tscn");

var current_scene: Node = null;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_menu();


func show_menu() -> void:
	if current_scene:
		current_scene.queue_free()
	current_scene = menu_scene.instantiate();
	add_child(current_scene)
	
	var start_button: Button = current_scene.get_node("Buttons/StartButton")  # Declara el tipo de start_button
	start_button.pressed.connect(self._on_start_pressed)


func _on_start_pressed() -> void:
	print("level");
