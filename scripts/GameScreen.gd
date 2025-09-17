extends Control

# Game data
var player_level: int = 1
var player_exp: int = 0
var exp_to_next: int = 10
var player_attack: int = 1
var gold: int = 0

# Current weapon
var current_weapon_index: int = 0
var weapons = [
	{"name": "Needle", "attack": 1, "unlock_level": 1, "texture": "res://assets/textures/weapon_needle.svg"},
	{"name": "Toothpick", "attack": 3, "unlock_level": 3, "texture": "res://assets/textures/weapon_toothpick.svg"},
	{"name": "Skewer", "attack": 6, "unlock_level": 6, "texture": "res://assets/textures/weapon_skewer.svg"},
	{"name": "Pencil", "attack": 10, "unlock_level": 10, "texture": "res://assets/textures/weapon_pencil.svg"},
	{"name": "Lance", "attack": 15, "unlock_level": 15, "texture": "res://assets/textures/weapon_lance.svg"}
]

# Current wall
var current_wall_index: int = 0
var walls = [
	{"name": "Paper Wall", "max_hp": 10, "texture": "res://assets/textures/paper_wall.svg"},
	{"name": "Wood Wall", "max_hp": 25, "texture": "res://assets/textures/wood_wall.svg"},
	{"name": "Brick Wall", "max_hp": 50, "texture": "res://assets/textures/brick_wall.svg"},
	{"name": "Steel Wall", "max_hp": 100, "texture": "res://assets/textures/steel_wall.svg"},
	{"name": "Diamond Wall", "max_hp": 200, "texture": "res://assets/textures/diamond_wall.svg"}
]

var current_wall_hp: int
var current_wall_max_hp: int

# Upgrade costs
var attack_upgrade_cost: int = 10

# UI references
@onready var level_label = $TopBar/StatsContainer/LeftStats/LevelContainer/LevelLabel
@onready var exp_label = $TopBar/StatsContainer/LeftStats/ExpContainer/ExpLabel
@onready var exp_bar = $TopBar/StatsContainer/LeftStats/ExpContainer/ExpBar
@onready var weapon_icon = $TopBar/StatsContainer/RightStats/WeaponContainer/WeaponIcon
@onready var weapon_label = $TopBar/StatsContainer/RightStats/WeaponContainer/WeaponLabel
@onready var attack_label = $TopBar/StatsContainer/RightStats/AttackContainer/AttackLabel
@onready var gold_label = $TopBar/StatsContainer/RightStats/GoldContainer/GoldLabel

@onready var wall_button = $GameArea/WallContainer/WallButton
@onready var wall_name_label = $GameArea/WallContainer/WallButton/WallOverlay/WallInfo/WallNameLabel
@onready var wall_health_bar = $GameArea/WallContainer/WallButton/WallOverlay/WallInfo/HealthContainer/HealthBar
@onready var wall_health_label = $GameArea/WallContainer/WallButton/WallOverlay/WallInfo/HealthContainer/HealthLabel

@onready var attack_upgrade_button = $BottomPanel/UpgradeContainer/AttackUpgrade/AttackUpgradeButton
@onready var weapon_upgrade_button = $BottomPanel/UpgradeContainer/WeaponUpgrade/WeaponUpgradeButton

func _ready():
	setup_wall()
	update_ui()

func setup_wall():
	var wall = walls[current_wall_index]
	current_wall_max_hp = wall["max_hp"]
	current_wall_hp = current_wall_max_hp
	
	# Update wall appearance
	wall_name_label.text = wall["name"]
	var wall_texture = load(wall["texture"])
	if wall_texture:
		wall_button.texture_normal = wall_texture
	
	# Update health display
	wall_health_bar.max_value = current_wall_max_hp
	wall_health_bar.value = current_wall_hp
	wall_health_label.text = "HP: " + str(current_wall_hp) + " / " + str(current_wall_max_hp)

func update_ui():
	# Top bar - Level and EXP
	level_label.text = "Level: " + str(player_level)
	exp_label.text = "EXP: " + str(player_exp) + " / " + str(exp_to_next)
	exp_bar.max_value = exp_to_next
	exp_bar.value = player_exp
	
	# Weapon display
	var current_weapon = weapons[current_weapon_index]
	weapon_label.text = current_weapon["name"]
	var weapon_texture = load(current_weapon["texture"])
	if weapon_texture:
		weapon_icon.texture = weapon_texture
	
	# Attack and Gold
	var total_attack = player_attack + current_weapon["attack"]
	attack_label.text = "Attack: " + str(total_attack)
	gold_label.text = "Gold: " + str(gold)
	
	# Update wall health
	wall_health_bar.value = current_wall_hp
	wall_health_label.text = "HP: " + str(current_wall_hp) + " / " + str(current_wall_max_hp)
	
	# Update upgrade buttons
	attack_upgrade_button.text = "Upgrade (Cost: " + str(attack_upgrade_cost) + ")"
	attack_upgrade_button.disabled = gold < attack_upgrade_cost
	
	# Update weapon unlock button
	var next_weapon_index = current_weapon_index + 1
	if next_weapon_index < weapons.size():
		var next_weapon = weapons[next_weapon_index]
		weapon_upgrade_button.text = "Unlock " + next_weapon["name"] + " (Level " + str(next_weapon["unlock_level"]) + ")"
		weapon_upgrade_button.disabled = player_level < next_weapon["unlock_level"]
	else:
		weapon_upgrade_button.text = "Max Weapon"
		weapon_upgrade_button.disabled = true

func _on_wall_pressed():
	var current_weapon = weapons[current_weapon_index]
	var damage = player_attack + current_weapon["attack"]
	
	# Add some visual feedback
	create_hit_effect(damage)
	
	current_wall_hp -= damage
	current_wall_hp = max(0, current_wall_hp)
	
	print("Dealt ", damage, " damage!")
	
	if current_wall_hp <= 0:
		wall_destroyed()
	
	update_ui()

func create_hit_effect(damage: int):
	# Simple screen shake effect
	var original_pos = wall_button.position
	var tween = create_tween()
	tween.tween_property(wall_button, "position", original_pos + Vector2(randf_range(-5, 5), randf_range(-5, 5)), 0.1)
	tween.tween_property(wall_button, "position", original_pos, 0.1)
	
	# Damage number effect
	var damage_label = Label.new()
	damage_label.text = "-" + str(damage)
	damage_label.add_theme_font_size_override("font_size", 24)
	damage_label.add_theme_color_override("font_color", Color.RED)
	damage_label.position = wall_button.global_position + Vector2(randf_range(-50, 50), randf_range(-30, 30))
	damage_label.z_index = 100
	get_tree().current_scene.add_child(damage_label)
	
	var damage_tween = create_tween()
	damage_tween.parallel().tween_property(damage_label, "position", damage_label.position + Vector2(0, -50), 1.0)
	damage_tween.parallel().tween_property(damage_label, "modulate:a", 0.0, 1.0)
	damage_tween.tween_callback(damage_label.queue_free)

func wall_destroyed():
	# Give rewards
	var wall = walls[current_wall_index]
	var exp_gained = wall["max_hp"] / 2
	var gold_gained = wall["max_hp"] / 5
	
	player_exp += exp_gained
	gold += gold_gained
	
	print("Wall destroyed! +", exp_gained, " EXP, +", gold_gained, " Gold")
	
	# Create destruction effect
	create_destroy_effect()
	
	# Check for level up
	while player_exp >= exp_to_next:
		level_up()
	
	# Move to next wall (cycle through available walls)
	current_wall_index = (current_wall_index + 1) % walls.size()
	
	# Wait a bit before showing the next wall
	await get_tree().create_timer(0.5).timeout
	setup_wall()

func create_destroy_effect():
	var destroy_label = Label.new()
	destroy_label.text = "💥 DESTROYED! 💥"
	destroy_label.add_theme_font_size_override("font_size", 32)
	destroy_label.add_theme_color_override("font_color", Color.GOLD)
	destroy_label.position = wall_button.global_position + Vector2(-100, -50)
	destroy_label.z_index = 100
	get_tree().current_scene.add_child(destroy_label)
	
	var destroy_tween = create_tween()
	destroy_tween.parallel().tween_property(destroy_label, "scale", Vector2(1.5, 1.5), 0.5)
	destroy_tween.parallel().tween_property(destroy_label, "modulate:a", 0.0, 1.0)
	destroy_tween.tween_callback(destroy_label.queue_free)

func level_up():
	player_exp -= exp_to_next
	player_level += 1
	player_attack += 1
	exp_to_next = int(exp_to_next * 1.2)
	
	print("Level up! Now level ", player_level)
	
	# Level up effect
	var levelup_label = Label.new()
	levelup_label.text = "⭐ LEVEL UP! ⭐"
	levelup_label.add_theme_font_size_override("font_size", 36)
	levelup_label.add_theme_color_override("font_color", Color.LIME_GREEN)
	levelup_label.position = Vector2(get_viewport().size.x / 2 - 150, get_viewport().size.y / 2 - 100)
	levelup_label.z_index = 100
	get_tree().current_scene.add_child(levelup_label)
	
	var levelup_tween = create_tween()
	levelup_tween.parallel().tween_property(levelup_label, "scale", Vector2(1.8, 1.8), 0.8)
	levelup_tween.parallel().tween_property(levelup_label, "modulate:a", 0.0, 1.5)
	levelup_tween.tween_callback(levelup_label.queue_free)

func _on_attack_upgrade_pressed():
	if gold >= attack_upgrade_cost:
		gold -= attack_upgrade_cost
		player_attack += 1
		attack_upgrade_cost = int(attack_upgrade_cost * 1.5)
		print("Attack upgraded! New attack: ", player_attack)
		update_ui()

func _on_weapon_upgrade_pressed():
	var next_weapon_index = current_weapon_index + 1
	if next_weapon_index < weapons.size():
		var next_weapon = weapons[next_weapon_index]
		if player_level >= next_weapon["unlock_level"]:
			current_weapon_index = next_weapon_index
			print("Weapon upgraded to: ", next_weapon["name"])
			
			# Weapon upgrade effect
			var weapon_label = Label.new()
			weapon_label.text = "⚔️ NEW WEAPON: " + next_weapon["name"] + "! ⚔️"
			weapon_label.add_theme_font_size_override("font_size", 28)
			weapon_label.add_theme_color_override("font_color", Color.CYAN)
			weapon_label.position = Vector2(get_viewport().size.x / 2 - 200, get_viewport().size.y / 2 - 150)
			weapon_label.z_index = 100
			get_tree().current_scene.add_child(weapon_label)
			
			var weapon_tween = create_tween()
			weapon_tween.parallel().tween_property(weapon_label, "scale", Vector2(1.6, 1.6), 0.8)
			weapon_tween.parallel().tween_property(weapon_label, "modulate:a", 0.0, 1.5)
			weapon_tween.tween_callback(weapon_label.queue_free)
			
			update_ui()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")