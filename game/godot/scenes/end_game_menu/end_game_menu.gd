extends Control

@onready var result_text := $Modal/VBoxContainer/ResultText
@onready var reset_game_button := $Modal/VBoxContainer/ResetGameButton;
@onready var save_inputs_button := $Modal/VBoxContainer/SaveInputsButton;

var file_dialog: FileDialog

func _ready() -> void:
	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR  # Set to open directories only
	file_dialog.connect("dir_selected", Callable(self, "_on_directory_selected"))
	add_child(file_dialog)
	
	reset_game_button.set_text("Restart");
	save_inputs_button.set_text("Save inputs")
	
	connect_buttons();


func connect_buttons() -> void:
	reset_game_button.pressed.connect(self._on_reset_game_button_pressed);
	save_inputs_button.pressed.connect(self._on_save_inputs_button_pressed);


func _on_reset_game_button_pressed() -> void:
	GameContainer.reset()


func _on_save_inputs_button_pressed() -> void:
	open_directory_selector();


func _on_directory_selected(path: String) -> void:
	var absolute_path: String = ProjectSettings.globalize_path(path)
	GameContainer.serialize_blocked_tiles(absolute_path)


func open_directory_selector() -> void:
	file_dialog.set_size(Vector2(600, 400))
	file_dialog.popup_centered()


func display_game_result(result: bool) -> void:
	var result_word: String;
	if result:
		result_word = "won";
	else:
		result_word = "lost";
	result_text.text = "[center][b]" + "You " + result_word + "[/b][/center]" ;
	save_inputs_button.visible = result;
