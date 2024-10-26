extends Node2D

@onready var menu_scene := preload("res://scenes/menu/menu.tscn");
@onready var level_scene := preload("res://scenes/level/level.tscn");
@onready var leaderboard_scene := preload("res://scenes/leaderboard/Leaderboard.tscn");

@onready var end_game_menu := $EndGameMenuCanvasLayer;
@onready var end_game_menu_reset_button := $EndGameMenuCanvasLayer/EndGameMenu/VBoxContainer/ResetGameButton;

@onready var back_to_menu_button: Button = $CanvasLayer2/BackToMenuButton;

var current_scene: Node = null;

# Called when the node enters the scene tree for the first time.
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
	add_child(current_scene);
	
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
	$CanvasLayer.add_child(current_scene);


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
	end_game_menu.get_node("EndGameMenu/VBoxContainer/SaveInputsButton").visible = player_won;
	end_game_menu.visible = true;
