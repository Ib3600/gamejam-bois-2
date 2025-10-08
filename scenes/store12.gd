extends Control

@onready var grid: GridContainer = $ScrollContainer/GridContainer
@export var store_item: PackedScene
@onready var finish_button: Button = $Button # Bouton "Terminer"

var store_item_id: int = 0
var store_items: Dictionary = {}
var item_levels: Dictionary = {}

#region Données du Magasin
var store_data: Array = [
	{
		"icon_path": "res://assets/store/moufles_size1(2).png",
		"heading_1": "Moufles",
		"heading_2": "Bah ça fait le travail de moufles.",
		"custom_button_text": "3 G",
		"cost": 3,
		"effect_type": "cold_resistance",
		"effect_value": 1
	},
	{
		"icon_path": "res://assets/store/coat_right_size.png",
		"heading_1": "Manteau en fourrure",
		"heading_2": "Ce manteau tout doux te tiendra chaud.",
		"custom_button_text": "3 Argent",
		"cost": 3,
		"effect_type": "coat_level",
		"effect_value": 1
	},
	{
		"icon_path": "res://assets/store/bottes_right_size.png",
		"heading_1": "Bottes",
		"heading_2": "Ces bottes solides sauveront tes pieds des engelures.",
		"custom_button_text": "3 Argent",
		"cost": 3,
		"effect_type": "cold_resistance",
		"effect_value": 1
	},
	{
		"icon_path": "res://assets/store/hache_right_size.png",
		"heading_1": "Hache",
		"heading_2": "Excellent pour se curer les dents.",
		"custom_button_text": "3 Argent",
		"has_levels": true,
		"max_level": 3,
		"effect_type": "axe_level",
		"levels": [
			{
				"heading_1": "Hache Lvl 1",
				"heading_2": "Excellent pour se curer les dents.",
				"custom_button_text": "2 Argent",
				"cost": 2,
				"effect_value": 1
			},
			{
				"heading_1": "Hache Lvl 2",
				"heading_2": "Excellent pour casser quelques arbres.",
				"custom_button_text": "3 Argent",
				"cost": 3,
				"effect_value": 1
			},
			{
				"heading_1": "Hache Lvl 3",
				"heading_2": "La hache ultime qui fend tout.",
				"custom_button_text": "4 Argent",
				"cost": 4,
				"effect_value": 3
			}
		]
	},
	{
		"icon_path": "res://assets/store/chimney2_right_size.png",
		"heading_1": "Cuisine",
		"heading_2": "Découvrez la cuisine",
		"custom_button_text": "3 argent",
		"cost": 3,
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
	finish_button.pressed.connect(_on_finish_pressed)


# ============================================================
# 🏪 Configuration du magasin
# ============================================================
func setup_store() -> void:
	for data in store_data:
		var temp = store_item.instantiate()
		temp.item_buy_pressed.connect(on_item_buy_pressed)
		grid.add_child(temp)

		var display_data = data
		if data.get("has_levels", false):
			display_data = get_level_data(data, 0)
			item_levels[store_item_id] = 0

		temp.setup(display_data, store_item_id)
		store_items[store_item_id] = temp
		store_item_id += 1


func get_level_data(item_data: Dictionary, level: int) -> Dictionary:
	var level_data = item_data["levels"][level].duplicate()
	level_data["icon_path"] = item_data["icon_path"]
	level_data["effect_type"] = item_data.get("effect_type")
	return level_data


# ============================================================
#  Achat d'objets
# ============================================================
func on_item_buy_pressed(id: int) -> void:
	var item_data = store_data[id]
	var cost: int = 0
	var effect_type: String = ""
	var effect_value = 0
	var item_name: String = ""
	var is_permanent = item_data.get("permanent", false)

	# Récupère les infos du bon niveau
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

	if Global.money < cost:
		print("Pas assez d'argent ! Coût:", cost, "| Argent dispo:", Global.money)
		return

	Global.money -= cost
	print(item_name, "acheté pour", cost, "argent.")
	apply_item_effect(effect_type, effect_value)

	if item_data.get("has_levels", false):
		var current_level = item_levels[id]
		current_level += 1
		if current_level < item_data["max_level"]:
			item_levels[id] = current_level
			var next_level_data = get_level_data(item_data, current_level)
			store_items[id].setup(next_level_data, id)
		else:
			store_items[id].queue_free()
			store_items.erase(id)
			item_levels.erase(id)
	elif not is_permanent:
		if store_items.has(id):
			store_items[id].queue_free()
			store_items.erase(id)


# ============================================================
# 🎁 Application des effets d'achat
# ============================================================
func apply_item_effect(effect_type: String, value) -> void:
	match effect_type:
		"coat_level":
			Global.niveau_manteau += value
		"axe_level":
			Global.niveau_hache = value
		"cold_resistance":
			Global.niveau_manteau += value * 0.5
		"heat_efficiency":
			Global.heat_efficiency += value
		"food":
			Global.food_stock += value
		"wood":
			Global.wood_stock += value
		_:
			print("Effet inconnu:", effect_type)


# ============================================================
# 🌅 Fin du magasin → Lancer le jour suivant
# ============================================================
func _on_finish_pressed():
	print("🛒 Fin du magasin. Passage au jour suivant...")

	# Incrémente le jour
	Global.current_day += 1
	print("🌞 Jour", Global.current_day, "commence !")

	# Change de scène selon le jour
	match Global.current_day:
		2:
			get_tree().change_scene_to_file("res://scenes/day2.tscn")
		3:
			get_tree().change_scene_to_file("res://scenes/day3.tscn")
		4:
			get_tree().change_scene_to_file("res://scenes/day4.tscn")
		_:
			print("Aucune scène définie pour ce jour.")
