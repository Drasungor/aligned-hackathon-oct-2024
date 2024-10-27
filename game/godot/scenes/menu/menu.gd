extends Control


@onready var start_button := $Buttons/StartButton;
@onready var leaderboard_button := $Buttons/LeaderboardButton;
@onready var quit_button := $Buttons/QuitButton;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.set_text("Start");
	leaderboard_button.set_text("Leaderboard")
	quit_button.set_text("Quit")
