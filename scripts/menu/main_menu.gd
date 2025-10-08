extends Control

var intro = load("res://scenes/cutscenes/intro_cutscene.tscn")
func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://scenes/cutscenes/intro_cutscene.tscn")
	print("test")

func _ready():
	Textbox.fade_from_black()

func _input(event):
	
	if event is InputEventMouseButton and event.pressed:
		print("clic détecté à :", event.position)
