extends Node2D

@onready var menu_scene := preload("res://scenes/menu/menu.tscn");
@onready var level_scene := preload("res://scenes/level/level.tscn");
@onready var leaderboard_scene := preload("res://scenes/leaderboard/Leaderboard.tscn");

@onready var scenes_canva_layer := $UICanvaLayer/CenterContainer;

@onready var end_game_menu := $UICanvaLayer/CenterContainer/EndGameMenu;
@onready var end_game_menu_reset_button := $UICanvaLayer/CenterContainer/EndGameMenu/VBoxContainer/ResetGameButton;

@onready var back_to_menu_button := $UICanvaLayer/BackToMenuButton;

var current_scene: Node = null;

func _ready() -> void:
	end_game_menu.visible = false;
	show_menu();
	back_to_menu_button.pressed.connect(self._on_back_to_menu_pressed);
	end_game_menu_reset_button.pressed.connect(self._on_end_game_menu_reset_pressed);


func show_menu() -> void:
	end_game_menu.visible = false;
	if current_scene:
		current_scene.queue_free();
	current_scene = menu_scene.instantiate();
	scenes_canva_layer.add_child(current_scene);
	
	var start_button: Button = current_scene.get_node("Buttons/StartButton");
	start_button.pressed.connect(self._on_start_pressed);
	
	var leaderboard_button: Button = current_scene.get_node("Buttons/LeaderboardButton");
	leaderboard_button.pressed.connect(self._on_leaderboard_pressed);


func show_level() -> void:
	end_game_menu.visible = false;
	if current_scene:
		current_scene.queue_free();
	GameContainer.reset();
	current_scene = level_scene.instantiate();
	add_child(current_scene);
	
	current_scene.get_node("Map").game_ended.connect(self._on_level_game_ended);


func show_leaderboard() -> void:
	end_game_menu.visible = false;
	if current_scene:
		current_scene.queue_free();
	current_scene = leaderboard_scene.instantiate();
	scenes_canva_layer.add_child(current_scene);


func reset_game() -> void:
	GameContainer.reset();
	show_level();


func _on_back_to_menu_pressed() -> void:
	show_menu();


func _on_start_pressed() -> void:
	show_level();


func _on_leaderboard_pressed() -> void:
	show_leaderboard();


func _on_end_game_menu_reset_pressed() -> void:
	reset_game();


func _on_level_game_ended(player_won: bool) -> void:
	end_game_menu.display_game_result(player_won);
	end_game_menu.visible = true;
