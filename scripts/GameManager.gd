extends Control

# Game state variables
var player_level: int = 1
var player_exp: int = 0
var exp_to_next_level: int = 10
var player_attack: int = 1
var mana: int = 0

# Current weapon
var current_weapon_index: int = 0
var weapons = [
	{"name": "바늘", "attack": 1},
	{"name": "이쑤시개", "attack": 2},
	{"name": "꼬챙이", "attack": 4},
	{"name": "연필", "attack": 6},
	{"name": "랜스", "attack": 10}
]

# Current wall
var current_wall_index: int = 0
var walls = [
	{"name": "종이 벽", "max_hp": 10, "color": Color(0.9, 0.8, 0.6)},
	{"name": "이쑤시개 벽", "max_hp": 5, "color": Color(0.8, 0.6, 0.4)},
	{"name": "나무 벽", "max_hp": 20, "color": Color(0.6, 0.4, 0.2)},
	{"name": "기름종이 벽", "max_hp": 15, "color": Color(0.4, 0.4, 0.4)},
	{"name": "벽돌 벽", "max_hp": 50, "color": Color(0.7, 0.3, 0.2)},
	{"name": "암반 벽", "max_hp": 100, "color": Color(0.3, 0.3, 0.3)},
	{"name": "강철 벽", "max_hp": 200, "color": Color(0.6, 0.6, 0.7)}
]

var current_wall_hp: int
var current_wall_max_hp: int

# UI references
@onready var wall_rect = $GameArea/Wall/WallRect
@onready var wall_label = $GameArea/Wall/WallLabel
@onready var hit_progress = $GameArea/Wall/HitProgress
@onready var ui = $UI

func _ready():
	setup_current_wall()
	update_ui()

func setup_current_wall():
	var wall_data = walls[current_wall_index]
	current_wall_max_hp = wall_data["max_hp"]
	current_wall_hp = current_wall_max_hp
	
	wall_label.text = wall_data["name"]
	wall_rect.color = wall_data["color"]
	hit_progress.max_value = current_wall_max_hp
	hit_progress.value = current_wall_hp

func _on_wall_input(event):
	if event is InputEventScreenTouch and event.pressed:
		hit_wall()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hit_wall()

func hit_wall():
	var damage = player_attack + weapons[current_weapon_index]["attack"]
	current_wall_hp -= damage
	
	# Update progress bar
	hit_progress.value = current_wall_hp
	
	# Check if wall is destroyed
	if current_wall_hp <= 0:
		wall_destroyed()
	
	# Visual feedback
	create_damage_effect(damage)

func wall_destroyed():
	# Give experience
	var exp_gained = walls[current_wall_index]["max_hp"] / 2
	gain_experience(exp_gained)
	
	# Give mana
	var mana_gained = randi() % 3 + 1
	mana += mana_gained
	
	# Move to next wall or loop back
	current_wall_index = (current_wall_index + 1) % walls.size()
	setup_current_wall()
	update_ui()
	
	# Show destruction effect
	create_destroy_effect()

func gain_experience(amount: int):
	player_exp += amount
	
	# Check for level up
	while player_exp >= exp_to_next_level:
		level_up()

func level_up():
	player_exp -= exp_to_next_level
	player_level += 1
	player_attack += 1
	exp_to_next_level = int(exp_to_next_level * 1.2)
	
	# Check for weapon upgrade
	check_weapon_upgrade()
	
	# Visual feedback
	create_levelup_effect()

func check_weapon_upgrade():
	# Upgrade weapon every 5 levels
	var target_weapon_index = min((player_level - 1) / 5, weapons.size() - 1)
	if target_weapon_index > current_weapon_index:
		current_weapon_index = target_weapon_index
		create_weapon_upgrade_effect()

func update_ui():
	ui.update_stats(player_level, weapons[current_weapon_index]["name"], 
					player_attack + weapons[current_weapon_index]["attack"], 
					player_exp, exp_to_next_level, mana)

func create_damage_effect(damage: int):
	var label = Label.new()
	label.text = "-" + str(damage)
	label.add_theme_color_override("font_color", Color.RED)
	label.position = Vector2(randf_range(-50, 50), randf_range(-30, -10))
	$GameArea/Wall.add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "position", label.position + Vector2(0, -50), 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)

func create_destroy_effect():
	var label = Label.new()
	label.text = "벽 파괴!"
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.position = Vector2(-50, -50)
	$GameArea/Wall.add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "scale", Vector2(1.5, 1.5), 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)

func create_levelup_effect():
	var label = Label.new()
	label.text = "레벨 업!"
	label.add_theme_color_override("font_color", Color.GREEN)
	label.position = Vector2(-50, -100)
	add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "scale", Vector2(2.0, 2.0), 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)

func create_weapon_upgrade_effect():
	var label = Label.new()
	label.text = "무기 업그레이드!"
	label.add_theme_color_override("font_color", Color.CYAN)
	label.position = Vector2(-80, -150)
	add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "scale", Vector2(1.8, 1.8), 0.7)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.2)
	tween.tween_callback(label.queue_free)