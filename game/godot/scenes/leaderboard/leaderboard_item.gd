extends HBoxContainer

class_name LeaderboardItem


func set_data(
	rank: String,
	wallet: String,
	steps: String
) -> void:
	var rank_text := $RankSection/RankText;
	var wallet_text := $WalletSection/WalletText;
	var steps_text := $StepsSection/StepsText;
	rank_text.text = rank;
	wallet_text.text = "[center]" + wallet + "[/center]";
	steps_text.text =  "[center]" + steps + "[/center]";
