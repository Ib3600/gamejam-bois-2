extends Control

var intro = load("res://scenes/cutscenes/intro_cutscene.tscn")
func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://scenes/cutscenes/intro_cutscene.tscn")
	print("test")
