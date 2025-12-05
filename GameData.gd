extends Node


var balance: float = 100.0 
var current_bet: float = 0.12 
var current_rtp: float = 0.9
var current_difficulty_name: String = "Easy"


var current_step: int = 0


var JACKPOT_LIMITS = {
	"Easy": 27,
	"Normal": 20,
	"Hard": 10,
	"Extreme": 5
}



var MULTIPLIERS = {
	"Easy": [
		1.02, 1.05, 1.08, 1.12, 1.15, 1.19, 1.23, 1.27, 1.31, 1.35,
		1.40, 1.45, 1.50, 1.55, 1.61, 1.67, 1.73, 1.80, 1.87, 1.95,
		2.05, 2.15, 2.25, 2.40, 2.60, 3.00, 5.00 
	],
	"Normal": [
		1.10, 1.22, 1.35, 1.50, 1.65, 1.83, 2.03, 2.25, 2.50, 2.80,
		3.15, 3.55, 4.00, 4.50, 5.10, 5.80, 6.60, 7.50, 9.00, 15.0 
	],
	"Hard": [
		1.50, 2.25, 3.40, 5.10, 7.65, 11.5, 17.2, 25.8, 38.7, 100.0 
	],
	"Extreme": [
		3.00, 9.00, 27.0, 81.0, 500.0 
	]
}

func set_difficulty(rtp_value: float, name: String):
	current_rtp = rtp_value
	current_difficulty_name = name
	print("Mode: ", name, " | Target Jackpot: ", JACKPOT_LIMITS[name])

func get_current_win_value() -> float:
	var list_multi = MULTIPLIERS[current_difficulty_name]
	
	
	var index = clamp(current_step - 1, 0, list_multi.size() - 1)
	return current_bet * list_multi[index]


func is_jackpot_reached() -> bool:
	var target = JACKPOT_LIMITS[current_difficulty_name]
	return current_step >= target
