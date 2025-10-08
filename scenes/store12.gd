extends Control
@onready var grid : GridContainer = $ScrollContainer/GridContainer
@export var store_item : PackedScene
var store_item_id: int = 0
var store_items: Dictionary = {}  # Références aux items instanciés
var item_levels: Dictionary = {}  # Suivi du niveau actuel de chaque item

#region Données du Magasin
var store_data: Array = [
	{
		"icon_path": "res://assets/store/moufles_size1(2).png",
		"heading_1": "Moufles",
		"heading_2": "Bah ça fait le travail de moufles.",
		"custom_button_text": "15 Argent",
		"cost": 15,
		"effect_type": "cold_resistance",
		"effect_value": 1
	},
	{
		"icon_path": "res://assets/store/coat_right_size.png",
		"heading_1": "Manteau en fourrure",
		"heading_2": "Ce manteau tout doux te tiendras chaud.",
		"custom_button_text": "50 Argent",
		"cost": 50,
		"effect_type": "coat_level",
		"effect_value": 1
	},
	{
		"icon_path": "res://assets/store/bottes_right_size.png",
		"heading_1": "Bottes",
		"heading_2": "Cette solide paire de botte en laine de chamoix sauveras tes pieds des engelures.",
		"custom_button_text": "30 Argent",
		"cost": 30,
		"effect_type": "cold_resistance",
		"effect_value": 1
	},
	{
		"icon_path": "res://assets/store/couverture_right_size.png",
		"heading_1": "Couverture",
		"heading_2": "Rah làlà le plaisir de se blottir sous la couette quand il fait froid dehors",
		"custom_button_text": "25 Argent",
		"cost": 25,
		"effect_type": "max_heat",
		"effect_value": 20
	},
	{
		"icon_path": "res://assets/store/hache_right_size.png",
		"heading_1": "Hache",
		"heading_2": "Excellent pour se curer les dents.",
		"custom_button_text": "10 argent",
		"has_levels": true,
		"max_level": 3,
		"effect_type": "axe_level",
		"levels": [
			{
				"heading_1": "Hache Lvl 1",
				"heading_2": "Excellent pour se curer les dents.",
				"custom_button_text": "10 argent",
				"cost": 10,
				"effect_value": 1
			},
			{
				"heading_1": "Hache Lvl 2",
				"heading_2": "Excellent pour se faire une blague à un ami.",
				"custom_button_text": "20 argent",
				"cost": 20,
				"effect_value": 2
			},
			{
				"heading_1": "Hache Lvl 3",
				"heading_2": "La hache ultime qui casse tout.",
				"custom_button_text": "30 argent",
				"cost": 30,
				"effect_value": 3
			}
		]
	},
	{
		"icon_path": "res://assets/store/chimney2_right_size.png",
		"heading_1": "Cheminée améliorée",
		"heading_2": "Découvrez la Chimney3000™, la révolution du confort thermoconnecté.",
		"custom_button_text": "100 argent",
		"cost": 100,
		"effect_type": "heat_efficiency",
		"effect_value": 2
	},
	{
		"icon_path": "res://assets/meat.png",
		"heading_1": "Viande",
		"heading_2": "Pack de viande fraîche.",
		"custom_button_text": "15 Argent",
		"cost": 15,
		"effect_type": "food",
		"effect_value": 5
	},
	{
		"icon_path": "res://assets/Wood_right_size.png",
		"heading_1": "Bois",
		"heading_2": "Un morceau de bois pour alimenter le feu.",
		"custom_button_text": "1 Argent",
		"cost": 1,
		"effect_type": "wood",
		"effect_value": 1,
		"permanent": true
	}
]
#endregion

func _ready():
	setup_store()
	
func setup_store() -> void:
	for data in store_data:
		var temp = store_item.instantiate()
		temp.item_buy_pressed.connect(on_item_buy_pressed)
		grid.add_child(temp)
		
		# Initialise les données de l'item selon s'il a des niveaux
		var display_data = data
		if data.get("has_levels", false):
			display_data = get_level_data(data, 0)
			item_levels[store_item_id] = 0  # Commence au niveau 0 (premier niveau)
		
		temp.setup(display_data, store_item_id)
		store_items[store_item_id] = temp
		store_item_id += 1

func get_level_data(item_data: Dictionary, level: int) -> Dictionary:
	var level_data = item_data["levels"][level].duplicate()
	level_data["icon_path"] = item_data["icon_path"]
	level_data["effect_type"] = item_data.get("effect_type")
	return level_data
		
func on_item_buy_pressed(id: int) -> void:
	var item_data = store_data[id]
	var cost: int = 0
	var effect_type: String = ""
	var effect_value = 0
	var item_name: String = ""
	var is_permanent = item_data.get("permanent", false)
	
	# Récupère les données selon si l'item a des niveaux
	if item_data.get("has_levels", false):
		var current_level = item_levels[id]
		var level_data = item_data["levels"][current_level]
		cost = level_data.get("cost", 0)
		effect_type = item_data.get("effect_type", "")
		effect_value = level_data.get("effect_value", 0)
		item_name = level_data.get("heading_1", "")
	else:
		cost = item_data.get("cost", 0)
		effect_type = item_data.get("effect_type", "")
		effect_value = item_data.get("effect_value", 0)
		item_name = item_data.get("heading_1", "")
	
	# Vérifie si le joueur a assez d'argent
	if Global.money < cost:
		print("Pas assez d'argent! Coût: " + str(cost) + ", Disponible: " + str(Global.money))
		# Optionnel: Afficher un message au joueur
		return
	
	# Déduit le coût
	Global.money -= cost
	print(item_name + " acheté pour " + str(cost) + " argent.")
	
	# Applique l'effet
	apply_item_effect(effect_type, effect_value)
	
	# Gère la progression/suppression de l'item
	if item_data.get("has_levels", false):
		var current_level = item_levels[id]
		current_level += 1
		
		# Vérifie s'il y a d'autres niveaux
		if current_level < item_data["max_level"]:
			item_levels[id] = current_level
			# Met à jour l'item pour afficher le prochain niveau
			var next_level_data = get_level_data(item_data, current_level)
			store_items[id].setup(next_level_data, id)
		else:
			# Niveau max atteint, supprime l'item
			store_items[id].queue_free()
			store_items.erase(id)
			item_levels.erase(id)
	elif not is_permanent:
		# Item normal - le supprime simplement
		if store_items.has(id):
			store_items[id].queue_free()
			store_items.erase(id)

func apply_item_effect(effect_type: String, value) -> void:
	"""Applique l'effet de l'item acheté aux caractéristiques du joueur"""
	match effect_type:
		"coat_level":
			# Augmente le niveau du manteau (réduit la perte de chaleur)
			Global.niveau_manteau += value
			print("Niveau manteau: " + str(Global.niveau_manteau))
		"axe_level":
			# Définit le niveau de la hache
			Global.niveau_hache = value
			print("Niveau hache: " + str(Global.niveau_hache))
		"cold_resistance":
			# Réduit la perte de froid (s'accumule avec le manteau)
			# Les moufles, bottes, etc. ajoutent une résistance supplémentaire
			Global.niveau_manteau += value * 0.5
			print("Résistance au froid améliorée")
		"max_heat":
			# Augmente la chaleur maximale du joueur
			Global.max_player_heat += value
			print("Chaleur maximale augmentée de " + str(value) + " (nouveau max: " + str(Global.max_player_heat) + ")")
		"heat_efficiency":
			# Améliore l'efficacité du chauffage
			Global.heat_efficiency += value
			print("Efficacité de chauffage améliorée (x" + str(Global.heat_efficiency) + ")")
		"food":
			# Ajoute de la nourriture au stock
			Global.food_stock += value
			print("Nourriture ajoutée: " + str(value))
		"wood":
			# Ajoute du bois au stock
			Global.wood_stock += value
			print("Bois ajouté: " + str(value))
		"hp_boost":
			# Augmente les points de vie maximum
			Global.player_hp += value
			print("Points de vie augmentés: " + str(value))
		_:
			print("Effet inconnu: " + effect_type)
