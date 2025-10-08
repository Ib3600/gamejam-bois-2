extends Control

# --- Références aux StoreItems ---
@onready var store_items: Array = [
	$StoreItem,
	$StoreItem2,
	$StoreItem3,
	$StoreItem4
]

@onready var validate_button: Button = $validate

# --- Dégâts et bonus ---
var damage_per_failure: int = 20
var heal_bonus: int = 5


func _ready():
	validate_button.pressed.connect(_on_validate_pressed)


func _on_validate_pressed():
	print("🧾 Validation des ressources...")

	for item in store_items:
		if not item:
			continue

		var name: String = item.character_name
		var heat: int = item.heat_value
		var food: int = item.food_value

		# Santé actuelle du PNJ
		var health_value: int = get_health_from_global(name)
		var besoins = Global.besoins_personnages.get(name, {"froid": 2, "faim": 2})

		print("→", name, "| Chaleur:", heat, "/", besoins.froid, "| Nourriture:", food, "/", besoins.faim)

		# --- Vérification des seuils ---
		if heat < besoins.froid or food < besoins.faim:
			health_value -= damage_per_failure
			print("💀", name, "a souffert du froid ou de la faim :", "-", damage_per_failure, "PV")
		else:
			health_value = min(health_value + heal_bonus, 120)
			print("❤️", name, "se sent mieux :", "+", heal_bonus, "PV")

		# Mise à jour
		set_health_in_global(name, clamp(health_value, 0, 120))

	# --- Après validation : passer au magasin ---
	_go_to_shop()


# ============================================================
# 🔧 Fonctions utilitaires
# ============================================================

func get_health_from_global(name: String) -> int:
	match name:
		"good_fairy":
			return Global.sante_good_fairy
		"evil_fairy":
			return Global.sante_evil_fairy
		"marchand":
			return Global.sante_marchand
		"pantin":
			return Global.sante_pantin
		_:
			return 0


func set_health_in_global(name: String, value: int) -> void:
	match name:
		"good_fairy":
			Global.sante_good_fairy = value
		"evil_fairy":
			Global.sante_evil_fairy = value
		"marchand":
			Global.sante_marchand = value
		"pantin":
			Global.sante_pantin = value
		_:
			pass


# ============================================================
# 🛍️ Passage au magasin (shop)
# ============================================================

func _go_to_shop():
	print("🕯️ Fin de la gestion. Passage au magasin du matin...")

	# Ici, on ne change PAS le jour encore : le shop le fera
	get_tree().change_scene_to_file("res://scenes/store.tscn")
