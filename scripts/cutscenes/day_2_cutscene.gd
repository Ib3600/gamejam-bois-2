extends Node2D

func _ready():
	$TextBox.fade_from_black()
	$TextBox.queue_text("Bonjour.", "marchand")
	$TextBox.queue_text("Je suis revenu.", "marchand")
	$TextBox.queue_text("La tempête s'est un peu calmé aujourd'hui.", "marchand")
	$TextBox.queue_text("Vous devriez pouvoir aller chercher des ressources plus loin.", "marchand")
	$TextBox.queue_text("Mais avant cela.", "marchand")
	$TextBox.queue_text("Faisons affaire.", "marchand")
	$TextBox.fade_to_black()
	$TextBox.change_scene("res://scenes/store.tscn")
