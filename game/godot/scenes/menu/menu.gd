extends Control


@onready var start_button := $HBoxContainer/VBoxContainer/Buttons/StartButton;
@onready var leaderboard_button := $HBoxContainer/VBoxContainer/Buttons/LeaderboardButton;
@onready var quit_button := $HBoxContainer/VBoxContainer/Buttons/QuitButton;

@onready var bug := $HBoxContainer/Panel/MenuBug;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.set_text("Start");
	leaderboard_button.set_text("Leaderboard")
	quit_button.set_text("Quit")
	
	bug.play();
