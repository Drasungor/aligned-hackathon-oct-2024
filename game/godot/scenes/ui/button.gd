extends TextureButton

@onready var label := $Text;

var OFFSET := 7;

func _ready() -> void:
	button_down.connect(_on_button_down);
	button_up.connect(_on_button_up);


func set_text(_text: String) -> void:
	label.text = "[center][b]" + _text + "[/b][/center]";


func _on_button_down() -> void:
	label.position.y += OFFSET;


func _on_button_up() -> void:
	label.position.y -= OFFSET;
