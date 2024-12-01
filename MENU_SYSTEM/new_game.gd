extends Control



func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://MENU_SYSTEM/main.tscn")



func _on_difficulty_value_changed(value: float) -> void:
	match value:
		0.0: %DifficultyLabel.text = "Difficulty: Noob"
		1.0: %DifficultyLabel.text = "Difficulty: Medium"
		2.0: %DifficultyLabel.text = "Difficulty: Hard"
		3.0: %DifficultyLabel.text = "Difficulty: Hardcore"


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://MAP_ELEMENTS/scenes/main_land.tscn")
