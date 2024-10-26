extends Control

@onready var reset_game_button := $VBoxContainer/ResetGameButton;
@onready var save_inputs_button := $VBoxContainer/SaveInputsButton;

var file_dialog: FileDialog

func _ready() -> void:
	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR  # Set to open directories only
	file_dialog.connect("dir_selected", Callable(self, "_on_directory_selected"))
	add_child(file_dialog)
	
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
