extends Control

# Game state variables
var player_level: int = 1
var player_exp: int = 0
var exp_to_next_level: int = 10
var player_attack: int = 1
var mana: int = 0
var total_walls_destroyed: int = 0

# Current weapon
var current_weapon_index: int = 0
var weapons = [
	{"name": "바늘", "attack": 1, "emoji": "📍"},
	{"name": "이쑤시개", "attack": 2, "emoji": "🦷"},
	{"name": "꼬챙이", "attack": 4, "emoji": "🍢"},
	{"name": "연필", "attack": 6, "emoji": "✏️"},
	{"name": "랜스", "attack": 10, "emoji": "🏹"}
]

# Current wall
var current_wall_index: int = 0
var walls = [
	{"name": "종이 벽", "max_hp": 10, "color": Color(0.9, 0.9, 0.7), "emoji": "📄"},
	{"name": "나무 벽", "max_hp": 25, "color": Color(0.6, 0.4, 0.2), "emoji": "🪵"},
	{"name": "벽돌 벽", "max_hp": 50, "color": Color(0.8, 0.4, 0.3), "emoji": "🧱"},
	{"name": "강철 벽", "max_hp": 100, "color": Color(0.7, 0.7, 0.8), "emoji": "🔩"},
	{"name": "다이아몬드 벽", "max_hp": 200, "color": Color(0.8, 0.9, 1.0), "emoji": "💎"},
	{"name": "마법 벽", "max_hp": 400, "color": Color(0.6, 0.2, 0.8), "emoji": "🔮"},
	{"name": "우주 벽", "max_hp": 800, "color": Color(0.1, 0.1, 0.3), "emoji": "🌌"}
]

var current_wall_hp: int
var current_wall_max_hp: int

# UI references
@onready var wall_button = $GameArea/Wall
@onready var wall_label = $GameArea/Wall/WallLabel
@onready var hit_progress = $GameArea/Wall/HitProgress
@onready var hits_label = $GameArea/Wall/HitsLabel
@onready var particle_container = $GameArea/ParticleContainer
@onready var ui = $UI

# Audio system (we'll add placeholder effects)
var hit_sounds = ["punch", "crack", "smash"]
var destroy_sounds = ["break", "shatter", "boom"]

func _ready():
	print("🎮 하늘을 뚫어라 게임 시작!")
	setup_current_wall()
	update_ui()
	create_welcome_effect()

func setup_current_wall():
	var wall_data = walls[current_wall_index]
	current_wall_max_hp = wall_data["max_hp"]
	current_wall_hp = current_wall_max_hp
	
	# Update wall appearance
	wall_label.text = wall_data["emoji"] + " " + wall_data["name"] + " " + wall_data["emoji"]
	var style_box = wall_button.get_theme_stylebox("normal").duplicate()
	style_box.bg_color = wall_data["color"]
	wall_button.add_theme_stylebox_override("normal", style_box)
	
	# Update progress bar
	hit_progress.max_value = current_wall_max_hp
	hit_progress.value = current_wall_hp
	hits_label.text = "HP: " + str(current_wall_hp) + "/" + str(current_wall_max_hp)
	
	print("🎯 새로운 벽: ", wall_data["name"], " HP:", current_wall_max_hp)

func _on_wall_pressed():
	print("🔨 벽을 공격!")
	hit_wall()

func hit_wall():
	var base_damage = player_attack + weapons[current_weapon_index]["attack"]
	
	# Random critical hit chance (10%)
	var is_critical = randf() < 0.1
	var damage = base_damage * (2 if is_critical else 1)
	
	current_wall_hp -= damage
	current_wall_hp = max(0, current_wall_hp)
	
	# Update UI
	hit_progress.value = current_wall_hp
	hits_label.text = "HP: " + str(current_wall_hp) + "/" + str(current_wall_max_hp)
	
	# Visual and audio feedback
	create_damage_effect(damage, is_critical)
	wall_shake_effect()
	play_hit_sound()
	
	print("💥 데미지: ", damage, (" (크리티컬!)" if is_critical else ""))
	
	# Check if wall is destroyed
	if current_wall_hp <= 0:
		wall_destroyed()

func wall_destroyed():
	total_walls_destroyed += 1
	
	# Give experience based on wall difficulty
	var exp_gained = max(5, walls[current_wall_index]["max_hp"] / 3)
	gain_experience(exp_gained)
	
	# Give mana (higher chance for rare materials)
	var mana_gained = randi() % 5 + 2
	mana += mana_gained
	
	print("🎉 벽 파괴! 경험치 +", exp_gained, " 마나 +", mana_gained)
	
	# Show destruction effect first
	create_destroy_effect()
	play_destroy_sound()
	
	# Wait a bit then move to next wall
	await get_tree().create_timer(0.8).timeout
	
	# Progress to harder walls over time
	if total_walls_destroyed % 3 == 0 and current_wall_index < walls.size() - 1:
		current_wall_index += 1
		print("🔥 더 어려운 벽이 나타났습니다!")
	
	setup_current_wall()
	update_ui()

func gain_experience(amount: int):
	player_exp += amount
	print("📈 경험치 획득: +", amount, " (총: ", player_exp, "/", exp_to_next_level, ")")
	
	# Check for level up
	while player_exp >= exp_to_next_level:
		level_up()

func level_up():
	player_exp -= exp_to_next_level
	player_level += 1
	player_attack += 2  # Increased attack gain
	exp_to_next_level = int(exp_to_next_level * 1.3)
	
	print("⭐ 레벨 업! 레벨 ", player_level, " 공격력 +2")
	
	# Check for weapon upgrade
	check_weapon_upgrade()
	
	# Visual feedback
	create_levelup_effect()

func check_weapon_upgrade():
	# Upgrade weapon every 3 levels (faster progression)
	var target_weapon_index = min((player_level - 1) / 3, weapons.size() - 1)
	if target_weapon_index > current_weapon_index:
		current_weapon_index = target_weapon_index
		var weapon = weapons[current_weapon_index]
		print("⚔️ 무기 업그레이드! ", weapon["emoji"], " ", weapon["name"])
		create_weapon_upgrade_effect()

func update_ui():
	var weapon = weapons[current_weapon_index]
	var total_attack = player_attack + weapon["attack"]
	ui.update_stats(player_level, weapon["emoji"] + " " + weapon["name"], 
					total_attack, player_exp, exp_to_next_level, mana)

func create_damage_effect(damage: int, is_critical: bool = false):
	var label = Label.new()
	label.text = "-" + str(damage) + ("!" if is_critical else "")
	label.add_theme_font_size_override("font_size", 24 if is_critical else 18)
	label.add_theme_color_override("font_color", Color.YELLOW if is_critical else Color.RED)
	label.position = Vector2(randf_range(-80, 80), randf_range(-40, -20))
	label.z_index = 10
	particle_container.add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "position", label.position + Vector2(0, -80), 1.2)
	tween.parallel().tween_property(label, "scale", Vector2(1.5, 1.5) if is_critical else Vector2(1.2, 1.2), 0.2)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.2)
	tween.tween_callback(label.queue_free)
	
	# Add hit particles
	for i in range(3 if is_critical else 2):
		create_hit_particle()

func create_destroy_effect():
	var wall_data = walls[current_wall_index]
	var label = Label.new()
	label.text = "💥 " + wall_data["name"] + " 파괴! 💥"
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color.GOLD)
	label.position = Vector2(-120, -100)
	label.z_index = 10
	particle_container.add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "scale", Vector2(1.8, 1.8), 0.6)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.5)
	tween.tween_callback(label.queue_free)
	
	# Create explosion particles
	for i in range(8):
		create_explosion_particle()

func create_levelup_effect():
	var label = Label.new()
	label.text = "⭐ 레벨 " + str(player_level) + " 달성! ⭐"
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color.LIME_GREEN)
	label.position = Vector2(-150, -200)
	label.z_index = 10
	particle_container.add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "scale", Vector2(2.2, 2.2), 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.5)
	tween.tween_callback(label.queue_free)
	
	# Level up particles
	for i in range(12):
		create_star_particle()

func create_weapon_upgrade_effect():
	var weapon = weapons[current_weapon_index]
	var label = Label.new()
	label.text = "🎉 새 무기: " + weapon["emoji"] + " " + weapon["name"] + "! 🎉"
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", Color.CYAN)
	label.position = Vector2(-150, -180)
	label.z_index = 10
	particle_container.add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "scale", Vector2(2.0, 2.0), 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.4)
	tween.tween_callback(label.queue_free)

# New visual effects
func create_welcome_effect():
	var label = Label.new()
	label.text = "🏹 모험을 시작하세요! 🏹"
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.position = Vector2(-120, -250)
	label.z_index = 10
	particle_container.add_child(label)
	
	var tween = create_tween()
	tween.tween_delay(2.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)

func wall_shake_effect():
	var original_pos = wall_button.position
	var tween = create_tween()
	tween.tween_property(wall_button, "position", original_pos + Vector2(randf_range(-5, 5), randf_range(-5, 5)), 0.1)
	tween.tween_property(wall_button, "position", original_pos, 0.1)

func create_hit_particle():
	var particle = ColorRect.new()
	particle.size = Vector2(4, 4)
	particle.color = Color(randf(), randf(), randf())
	particle.position = Vector2(randf_range(-20, 20), randf_range(-20, 20))
	particle.z_index = 5
	particle_container.add_child(particle)
	
	var tween = create_tween()
	var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	tween.parallel().tween_property(particle, "position", particle.position + direction * randf_range(30, 60), 0.8)
	tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.8)
	tween.tween_callback(particle.queue_free)

func create_explosion_particle():
	var particle = ColorRect.new()
	particle.size = Vector2(8, 8)
	particle.color = Color(1, randf_range(0.3, 0.8), 0)
	particle.position = Vector2(0, 0)
	particle.z_index = 5
	particle_container.add_child(particle)
	
	var direction = Vector2(cos(randf() * TAU), sin(randf() * TAU))
	var tween = create_tween()
	tween.parallel().tween_property(particle, "position", direction * randf_range(50, 100), 1.0)
	tween.parallel().tween_property(particle, "modulate:a", 0.0, 1.0)
	tween.tween_callback(particle.queue_free)

func create_star_particle():
	var label = Label.new()
	label.text = "⭐"
	label.add_theme_font_size_override("font_size", 16)
	label.position = Vector2(randf_range(-50, 50), randf_range(-50, 50))
	label.z_index = 8
	particle_container.add_child(label)
	
	var tween = create_tween()
	var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	tween.parallel().tween_property(label, "position", label.position + direction * randf_range(80, 120), 1.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.5)
	tween.tween_callback(label.queue_free)

# Audio placeholder functions
func play_hit_sound():
	var sound_name = hit_sounds[randi() % hit_sounds.size()]
	print("🔊 효과음: ", sound_name)

func play_destroy_sound():
	var sound_name = destroy_sounds[randi() % destroy_sounds.size()]
	print("🔊 파괴음: ", sound_name)