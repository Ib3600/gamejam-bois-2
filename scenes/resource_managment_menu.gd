extends Control

# VERSION AVANCÉE: Gère à la fois l'ÉNERGIE et la NOURRITURE

@onready var grid: GridContainer = $PanelContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var energy_label: Label = $PanelContainer/VBoxContainer/EnergyLabel
@onready var food_label: Label = $FoodLabel
@onready var confirm_button: Button = $PanelContainer/VBoxContainer/ConfirmButton
@export var resource_item: PackedScene

var resource_items: Dictionary = {}
var energy_allocations: Dictionary = {}
var food_allocations: Dictionary = {}  # Nouveau: allocation de nourriture

var total_energy_available: float = 0.0
var energy_used: float = 0.0
var total_food_available: int = 0
var food_used: int = 0  # Nouveau: nourriture utilisée

# Données des habitants
var habitants_data: Array = [
	{
		"id": "marchand",
		"nom": "🏪 Marchand",
		"icon_path": "res://assets/npc/marchand.png",
		"description": "Boutique - Besoin: 10 énergie, 1 nourriture",
		"min_energy": 0,
		"max_energy": 20,
		"food_required": 1  # Nouveau: nourriture requise
	},
	{
		"id": "good_fairy",
		"nom": "✨ Bonne Fée",
		"icon_path": "res://assets/npc/good_fairy.png",
		"description": "Chambre - Besoin: 10 énergie, 1 nourriture",
		"min_energy": 0,
		"max_energy": 20,
		"food_required": 1
	},
	{
		"id": "evil_fairy",
		"nom": "🦇 Mauvaise Fée",
		"icon_path": "res://assets/npc/evil_fairy.png",
		"description": "Chambre - Besoin: 10 énergie, 1 nourriture",
		"min_energy": 0,
		"max_energy": 20,
		"food_required": 1
	},
	{
		"id": "pantin",
		"nom": "🪆 Pantin",
		"icon_path": "res://assets/npc/pantin.png",
		"description": "Atelier - Besoin: 10 énergie, 1 nourriture",
		"min_energy": 0,
		"max_energy": 20,
		"food_required": 1
	}
]

func _ready():
	visible = false
	confirm_button.pressed.connect(_on_confirm_pressed)
	setup_resource_menu()

func setup_resource_menu() -> void:
	"""Crée les items de gestion pour chaque habitant"""
	for i in range(habitants_data.size()):
		var data = habitants_data[i]
		var temp = resource_item.instantiate()
		
		temp.value_changed.connect(_on_item_value_changed.bind(data["id"]))
		
		grid.add_child(temp)
		temp.setup(data)
		
		resource_items[data["id"]] = temp
		energy_allocations[data["id"]] = 0.0
		food_allocations[data["id"]] = 0

func open_menu() -> void:
	"""Ouvre le menu de gestion en début/fin de journée"""
	visible = true
	
	# Récupère les ressources disponibles
	total_energy_available = Global.heat_stock
	total_food_available = Global.food_stock
	energy_used = 0.0
	food_used = 0
	
	# Réinitialise toutes les allocations
	for id in energy_allocations.keys():
		energy_allocations[id] = 0.0
		food_allocations[id] = 0
		if resource_items.has(id):
			resource_items[id].set_value(0)
	
	update_displays()
	confirm_button.disabled = false

func close_menu() -> void:
	"""Ferme le menu"""
	visible = false

func _on_item_value_changed(id: String, old_value: int, new_value: int) -> void:
	"""Appelé quand un habitant change sa valeur d'énergie"""
	var difference = new_value - old_value
	
	# Vérifie si on a assez d'énergie disponible
	if energy_used + difference > total_energy_available:
		if resource_items.has(id):
			resource_items[id].set_value(old_value)
		print("⚠️ Pas assez d'énergie disponible!")
		return
	
	# Nouveau: Gère automatiquement la nourriture
	# Si on donne de l'énergie (>0), on donne aussi de la nourriture
	var food_difference = 0
	if new_value > 0 and old_value == 0:
		# Passe de 0 à >0 = ajoute 1 nourriture
		food_difference = 1
	elif new_value == 0 and old_value > 0:
		# Passe de >0 à 0 = retire 1 nourriture
		food_difference = -1
	
	# Vérifie la nourriture disponible
	if food_used + food_difference > total_food_available:
		if resource_items.has(id):
			resource_items[id].set_value(old_value)
		print("⚠️ Pas assez de nourriture disponible!")
		return
	
	# Met à jour les allocations
	energy_allocations[id] = new_value
	energy_used += difference
	
	food_allocations[id] = 1 if new_value > 0 else 0
	food_used += food_difference
	
	update_displays()

func update_displays() -> void:
	"""Met à jour l'affichage des ressources restantes"""
	# Énergie
	var remaining_energy = total_energy_available - energy_used
	energy_label.text = "🔥 Énergie: " + str(int(remaining_energy)) + " / " + str(int(total_energy_available))
	
	if remaining_energy <= 0:
		energy_label.modulate = Color(1, 0.8, 0)
	elif remaining_energy < 10:
		energy_label.modulate = Color(1, 1, 0.5)
	else:
		energy_label.modulate = Color(1, 1, 1)
	
	# Nourriture
	var remaining_food = total_food_available - food_used
	food_label.text = "🍖 Nourriture: " + str(remaining_food) + " / " + str(total_food_available)
	
	if remaining_food <= 0:
		food_label.modulate = Color(1, 0.8, 0)
	elif remaining_food < 2:
		food_label.modulate = Color(1, 1, 0.5)
	else:
		food_label.modulate = Color(1, 1, 1)

func _on_confirm_pressed() -> void:
	"""Valide les allocations et applique les effets"""
	print("\n=== 🌙 Allocation des ressources pour la nuit ===")
	
	# Applique les allocations à chaque habitant
	for id in energy_allocations.keys():
		var energy = energy_allocations[id]
		var food = food_allocations[id]
		apply_resources_to_habitant(id, energy, food)
	
	# Déduit les ressources utilisées
	Global.heat_stock -= energy_used
	Global.food_stock -= food_used
	
	print("Ressources restantes:")
	print("  🔥 Énergie: " + str(Global.heat_stock))
	print("  🍖 Nourriture: " + str(Global.food_stock))
	print("================================================\n")
	
	# Passe à la fin de journée
	Global.fin_de_journee()
	
	# Reprend le jeu
	get_tree().paused = false
	
	# Ferme le menu
	close_menu()

func apply_resources_to_habitant(id: String, energy: float, food: int) -> void:
	"""Applique l'énergie et la nourriture allouées à un habitant"""
	var nom = ""
	for data in habitants_data:
		if data["id"] == id:
			nom = data["nom"]
			break
	
	print(nom + " reçoit " + str(energy) + " énergie + " + str(food) + " nourriture")
	
	# Détermine les états
	var seuil_froid = 10.0
	var a_froid = energy < seuil_froid
	var a_faim = food < 1
	
	# Met à jour l'état de l'habitant dans Global
	match id:
		"marchand":
			Global.etat_marchand[0] = a_froid
			Global.etat_marchand[1] = a_faim
			afficher_etat(nom, a_froid, a_faim)
		"good_fairy":
			Global.etat_good_fairy[0] = a_froid
			Global.etat_good_fairy[1] = a_faim
			afficher_etat(nom, a_froid, a_faim)
		"evil_fairy":
			Global.etat_evil_fairy[0] = a_froid
			Global.etat_evil_fairy[1] = a_faim
			afficher_etat(nom, a_froid, a_faim)
		"pantin":
			Global.etat_pantin[0] = a_froid
			Global.etat_pantin[1] = a_faim
			afficher_etat(nom, a_froid, a_faim)

func afficher_etat(nom: String, a_froid: bool, a_faim: bool) -> void:
	"""Affiche l'état de l'habitant dans la console"""
	if not a_froid and not a_faim:
		print("  ✅ " + nom + " sera en pleine forme!")
	else:
		var problemes = []
		if a_froid:
			problemes.append("❄️ froid")
		if a_faim:
			problemes.append("🍖 faim")
		print("  ⚠️ " + nom + " aura " + ", ".join(problemes))
