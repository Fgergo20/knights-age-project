extends Control

func _ready() -> void:
	pass

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://MENU_SYSTEM/main.tscn")


func _on_new_pressed() -> void:
	get_tree().change_scene_to_file("res://MENU_SYSTEM/new_game.tscn")
