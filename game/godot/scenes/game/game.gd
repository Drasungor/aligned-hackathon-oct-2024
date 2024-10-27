extends Node2D

@onready var menu_scene := preload("res://scenes/menu/menu.tscn");
@onready var level_scene := preload("res://scenes/level/level.tscn");
@onready var leaderboard_scene := preload("res://scenes/leaderboard/Leaderboard.tscn");

@onready var scenes_canva_layer := $UICanvaLayer/CenterContainer;

@onready var end_game_menu := $UICanvaLayer/CenterContainer/EndGameMenu;
@onready var end_game_menu_reset_button := $UICanvaLayer/CenterContainer/EndGameMenu/Modal/VBoxContainer/ResetGameButton;

@onready var back_to_menu_button := $UICanvaLayer/BackToMenuButton;

var current_scene: Node = null;

func _ready() -> void:
	end_game_menu.visible = false;
	show_menu();
	back_to_menu_button.pressed.connect(self._on_back_to_menu_pressed);
	end_game_menu_reset_button.pressed.connect(self._on_end_game_menu_reset_pressed);


func show_menu() -> void:
	end_game_menu.visible = false;
	back_to_menu_button.visible = false;
	
	if current_scene:
		current_scene.queue_free();
	current_scene = menu_scene.instantiate();
	scenes_canva_layer.add_child(current_scene);
	
	var start_button := current_scene.get_node("HBoxContainer/VBoxContainer/Buttons/StartButton");
	start_button.pressed.connect(self._on_start_pressed);
	
	var leaderboard_button := current_scene.get_node("HBoxContainer/VBoxContainer/Buttons/LeaderboardButton");
	leaderboard_button.pressed.connect(self._on_leaderboard_pressed);
	
	var quit_button := current_scene.get_node("HBoxContainer/VBoxContainer/Buttons/QuitButton");
	quit_button.pressed.connect(self._on_quit_pressed);


func show_level() -> void:
	end_game_menu.visible = false;
	back_to_menu_button.visible = true;
	
	if current_scene:
		current_scene.queue_free();
	GameContainer.reset();
	current_scene = level_scene.instantiate();
	
	var map := current_scene.get_node("Map");
	var bug := current_scene.get_node("Bug");
	map.game_ended.connect(self._on_level_game_ended);
	map.bug_movement.connect(bug._on_bug_movement);
	bug.stop_bug_movement.connect(map._on_stop_bug_movement);
	
	add_child(current_scene);


func show_leaderboard() -> void:
	end_game_menu.visible = false;
	back_to_menu_button.visible = true;
	
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


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_end_game_menu_reset_pressed() -> void:
	reset_game();


func _on_level_game_ended(player_won: bool) -> void:
	end_game_menu.display_game_result(player_won);
	end_game_menu.visible = true;
