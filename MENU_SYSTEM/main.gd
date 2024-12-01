extends Control


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://MENU_SYSTEM/select_saved.tscn")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://MENU_SYSTEM/new_game.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://MENU_SYSTEM/settings.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
