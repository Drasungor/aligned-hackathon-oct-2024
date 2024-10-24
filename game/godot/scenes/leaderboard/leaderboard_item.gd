extends HBoxContainer

class_name LeaderboardItem


func set_data(
	rank: String,
	nickname: String,
	wallet: String,
	steps: String
) -> void:
	var rank_text := $NicknameSection/MarginContainer/HBoxContainer/RankText;
	var nickname_text := $NicknameSection/MarginContainer/HBoxContainer/NicknameText;
	var wallet_text := $WalletSection/WalletText;
	var steps_text := $StepsSection/StepsText;
	rank_text.text = rank;
	nickname_text.text = nickname;
	wallet_text.text = "[center]" + wallet + "[/center]";
	steps_text.text =  "[center]" + steps + "[/center]";
