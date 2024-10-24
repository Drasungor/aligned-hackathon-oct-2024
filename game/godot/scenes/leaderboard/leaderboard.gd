extends Control

class_name Leaderboard

@onready var leaderboard_item_scene := preload("res://scenes/leaderboard/LeaderboardItem.tscn")

@onready var leaderboard_list := $ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_item("#1",
	"ElBichitoAlineado",
	"0x2981e1dD10168a1187Cf39D36b48465715Aab85D",
	"30");
	add_item("#1",
	"ElBichitoAlineado",
	"0x2981e1dD10168a1187Cf39D36b48465715Aab85D",
	"30");
	print(get_data());

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_item(
	rank: String,
	nickname: String,
	wallet: String,
	steps: String
) -> void:
	var leaderboard_item: LeaderboardItem = leaderboard_item_scene.instantiate()
	leaderboard_item.set_data(rank, nickname, wallet, steps);
	leaderboard_list.add_child(leaderboard_item);


func get_data() -> Array:
	var records: Array = GameContainer.get_leaderboad();
	#var records := [
	#{ "steps_amount": 5, "record_holder": "0x2981…b85d", "updates_counter": 1 },
	#{ "steps_amount": 3, "record_holder": "0x2981…b85d", "updates_counter": 2 },
	#{ "steps_amount": 5, "record_holder": "0x2981…b85d", "updates_counter": 3 },
	#]
	
	var callable: Callable = Callable(self, "compare_records")
	records.sort_custom(callable);
	return records;


func compare_records(a: Dictionary, b: Dictionary) -> int:
	if a["steps_amount"] > b["steps_amount"]:
		return -1
	elif a["steps_amount"] < b["steps_amount"]:
		return 1
	else:
		if a["updates_counter"] > b["updates_counter"]:
			return -1
		elif a["updates_counter"] < b["updates_counter"]:
			return 1
	return 0
