extends Control

@onready var level_label = $StatsPanel/StatsContainer/LevelLabel
@onready var weapon_label = $StatsPanel/StatsContainer/WeaponLabel
@onready var attack_label = $StatsPanel/StatsContainer/AttackLabel
@onready var exp_label = $StatsPanel/StatsContainer/ExpLabel
@onready var currency_label = $StatsPanel/StatsContainer/CurrencyLabel

func update_stats(level: int, weapon_name: String, attack_power: int, current_exp: int, exp_needed: int, mana_amount: int):
	level_label.text = "레벨: " + str(level)
	weapon_label.text = "무기: " + weapon_name
	attack_label.text = "공격력: " + str(attack_power)
	exp_label.text = "경험치: " + str(current_exp) + "/" + str(exp_needed)
	currency_label.text = "마나: " + str(mana_amount)