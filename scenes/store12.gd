extends Control
@onready var grid : GridContainer = $ScrollContainer/GridContainer
@export var store_item : PackedScene
var store_item_id: int = 0
var store_items: Dictionary = {}  # Store references to instantiated items
var item_levels: Dictionary = {}  # Track current level of each item

#region Data for Store
var store_data: Array = [
	{
		"icon_path": "res://assets/store/moufles_size1(2).png",
		"heading_1" : "Moufles",
		"heading_2" : "Bah ça fait le travail de moufles.",
		"custom_button_text": "XX Argent"
	}
	,
	{
		"icon_path": "res://assets/store/coat_right_size.png",
		"heading_1" : "Manteau en fourrure",
		"heading_2" : "Ce manteau tout doux te tiendras chaud.",
		"custom_button_text": "XX Argent"
	},
	{
		"icon_path": "res://assets/store/bottes_right_size.png",
		"heading_1" : "Bottes",
		"heading_2" : "Cette solide paire de botte en laine de chamoix sauveras tes pieds des engelures.",
		"custom_button_text": "XX Argent"
	},
	{
		"icon_path": "res://assets/store/couverture_right_size.png",
		"heading_1" : "100 Coins",
		"heading_2" : "Rah làlà le plaisir de se blottir sous la couette quand il fait froid dehors",
		"custom_button_text": "XX argent"
	},
	{
		"icon_path": "res://assets/store/hache_right_size.png",
		"heading_1" : "Hache",
		"heading_2" : "Excellent pour se curer les dents.",
		"custom_button_text": "XX argent",
		"has_levels": true,
		"max_level": 3,
		"levels": [
			{
				"heading_1": "Hache Lvl 1",
				"heading_2": "Excellent pour se curer les dents.",
				"custom_button_text": "10 argent"
			},
			{
				"heading_1": "Hache Lvl 2",
				"heading_2": "Excellent pour se faire une blague à un ami.",
				"custom_button_text": "20 argent"
			},
			{
				"heading_1": "Hache Lvl 3",
				"heading_2": "La hache ultime qui casse tout.",
				"custom_button_text": "30 argent"
			}
		]
	},
	{
		"icon_path": "res://assets/store/chimney2_right_size.png",
		"heading_1" : "100 Coins",
		"heading_2" : "Découvrez la Chimney3000™, la révolution du confort thermoconnecté.",
		"custom_button_text": "XX argent"
	},
	{
		"icon_path": "res://assets/meat.png",
		"heading_1" : "100 Coins",
		"heading_2" : "value pack.",
		"custom_button_text": "10 Diamonds"
	},
	{
		"icon_path": "res://assets/meat.png",
		"heading_1" : "100 Coins",
		"heading_2" : "value pack.",
		"custom_button_text": "10 Diamonds"
	},
	{
		"icon_path": "res://assets/meat.png",
		"heading_1" : "100 Coins",
		"heading_2" : "value pack.",
		"custom_button_text": "10 Diamonds"
	},
	{
		"icon_path": "res://assets/meat.png",
		"heading_1" : "100 Coins",
		"heading_2" : "value pack.",
		"custom_button_text": "10 Diamonds"
	},
	{
		"icon_path": "res://assets/meat.png",
		"heading_1" : "100 Coins",
		"heading_2" : "value pack.",
		"custom_button_text": "10 Diamonds"
	},
	{
		"icon_path": "res://assets/meat.png",
		"heading_1" : "100 Coins",
		"heading_2" : "value pack.",
		"custom_button_text": "10 Diamonds"
	},
	{
		"icon_path": "res://assets/meat.png",
		"heading_1" : "100 Coins",
		"heading_2" : "value pack.",
		"custom_button_text": "10 Diamonds"
	},
	{
		"icon_path": "res://assets/meat.png",
		"heading_1" : "100 Coins",
		"heading_2" : "value pack.",
		"custom_button_text": "10 Diamonds"
	},
	{
		"icon_path": "res://assets/meat.png",
		"heading_1" : "100 Coins",
		"heading_2" : "value pack.",
		"custom_button_text": "10 Diamonds"
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
		
		# Initialize item data based on whether it has levels
		var display_data = data
		if data.get("has_levels", false):
			display_data = get_level_data(data, 0)
			item_levels[store_item_id] = 0  # Start at level 0 (first level)
		
		temp.setup(display_data, store_item_id)
		store_items[store_item_id] = temp
		store_item_id += 1

func get_level_data(item_data: Dictionary, level: int) -> Dictionary:
	var level_data = item_data["levels"][level].duplicate()
	level_data["icon_path"] = item_data["icon_path"]
	return level_data
		
func on_item_buy_pressed(id : int) -> void:
	var item_data = store_data[id]
	
	# Check if item has levels
	if item_data.get("has_levels", false):
		var current_level = item_levels[id]
		print(item_data["levels"][current_level].get("heading_1") + " bought.")
		
		# Move to next level
		current_level += 1
		
		# Check if there are more levels
		if current_level < item_data["max_level"]:
			item_levels[id] = current_level
			# Update the item to show next level
			var next_level_data = get_level_data(item_data, current_level)
			store_items[id].setup(next_level_data, id)
		else:
			# Max level reached, remove item
			store_items[id].queue_free()
			store_items.erase(id)
			item_levels.erase(id)
	else:
		# Regular item - just remove it
		print(item_data.get("heading_1") + " bought.")
		if store_items.has(id):
			store_items[id].queue_free()
			store_items.erase(id)
