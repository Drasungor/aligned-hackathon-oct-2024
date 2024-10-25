extends HBoxContainer

class_name LeaderboardItem


func set_data(
	rank: String,
	wallet: String,
	steps: String,
	updates: String
) -> void:
	var rank_text := $RankSection/RankText;
	var wallet_text := $WalletSection/WalletText;
	var steps_text := $StepsSection/StepsText;
	var updates_text := $UpdatesSection/UpdatesText;
	rank_text.text = rank;
	wallet_text.text = "[center]" + wallet + "[/center]";
	steps_text.text =  "[center]" + steps + "[/center]";
	updates_text.text =  "[center]" + updates + "[/center]";
