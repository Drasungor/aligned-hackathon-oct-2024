extends Control

class_name Leaderboard

@onready var leaderboard_item_scene := preload("res://scenes/leaderboard/LeaderboardItem.tscn")

@onready var leaderboard_list := $VBoxContainer/ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_data()


func add_item(
	rank: String,
	wallet: String,
	steps: String,
	updates: String
) -> void:
	var leaderboard_item: LeaderboardItem = leaderboard_item_scene.instantiate()
	leaderboard_item.set_data(rank, wallet, steps, updates);
	leaderboard_list.add_child(leaderboard_item);


func add_data() -> void:
	var records: Array = get_data();
	for i : int in range(records.size()):
		add_item(
			"#%d" % (i + 1),
			records[i]["record_holder"],
			str(records[i]["steps_amount"]),
			str(records[i]["updates_counter"])
		)


func get_data() -> Array:
	var records: Array = GameContainer.get_leaderboad();
	
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
