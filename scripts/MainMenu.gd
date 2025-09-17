extends Control

func _on_play_pressed():
	print("게임 시작!")
	get_tree().change_scene_to_file("res://scenes/GameScreen.tscn")

func _on_settings_pressed():
	print("설정 화면")
	# 추후 설정 화면 구현

func _on_quit_pressed():
	print("게임 종료")
	get_tree().quit()