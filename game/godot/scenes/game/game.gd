extends Node2D

@onready var menu_scene := preload("res://scenes/menu/menu.tscn");
@onready var level_scene := preload("res://scenes/level/level.tscn");
@onready var leaderboard_scene := preload("res://scenes/leaderboard/Leaderboard.tscn");

var current_scene: Node = null;
@onready var back_to_menu_button: Button = $CanvasLayer2/BackToMenuButton;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_menu();
	back_to_menu_button.pressed.connect(self._on_back_to_menu_pressed);


func show_menu() -> void:
	if current_scene:
		current_scene.queue_free();
	current_scene = menu_scene.instantiate();
	add_child(current_scene);
	
	var start_button: Button = current_scene.get_node("Buttons/StartButton");
	start_button.pressed.connect(self._on_start_pressed);
	
	var leaderboard_button: Button = current_scene.get_node("Buttons/LeaderboardButton");
	leaderboard_button.pressed.connect(self._on_leaderboard_pressed);


func show_level() -> void:
	if current_scene:
		current_scene.queue_free();
	current_scene = level_scene.instantiate();
	add_child(current_scene);


func show_leaderboard() -> void:
	if current_scene:
		current_scene.queue_free();
	current_scene = leaderboard_scene.instantiate();
	$CanvasLayer.add_child(current_scene);


func _on_back_to_menu_pressed() -> void:
	show_menu();


func _on_start_pressed() -> void:
	show_level();


func _on_leaderboard_pressed() -> void:
	show_leaderboard();
